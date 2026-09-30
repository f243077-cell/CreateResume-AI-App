// Charging for AI calls (brief S1-S3).
//
// Order for every paid request:
//   1. Same Idempotency-Key seen before with a stored result: return it, no charge.
//   2. Rate limit: too many calls in the last minute -> 429.
//   3. consume_credits (atomic). Not enough credits -> 402.
//   4. Run the model. Any failure -> refund_credits, then return the error.
//   5. Store the result against the key so a retry is replayed, not re-run.

import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'

export class InsufficientCreditsError extends Error {}
export class DuplicateRequestError extends Error {}

/** Storage operations used by [chargeAndRun]; faked in tests. */
export interface CreditStore {
  findResponse(userId: string, key: string): Promise<unknown | null>
  recentCalls(userId: string, withinMs: number): Promise<number>
  /** Deducts and logs; returns the new balance. */
  consume(amount: number, tool: string, key: string): Promise<number>
  /** Logs a free call (counts toward the rate limit). */
  logFree(userId: string, tool: string, key: string): Promise<void>
  balance(userId: string): Promise<number>
  /** Undoes [consume] or [logFree] for a failed call. */
  refund(userId: string, amount: number, key: string): Promise<void>
  saveResponse(userId: string, key: string, response: unknown, model: string): Promise<void>
}

export type ChargeOptions = {
  userId: string
  tool: string
  /** 0 for free actions. */
  amount: number
  idempotencyKey: string
  rateLimitPerMinute?: number
}

export type ChargeResult<T> =
  | { ok: true; payload: T; creditsRemaining: number | null; replayed: boolean }
  | { ok: false; status: number; body: Record<string, unknown> }

export async function chargeAndRun<T>(
  store: CreditStore,
  opts: ChargeOptions,
  run: () => Promise<{ payload: T; model: string }>,
): Promise<ChargeResult<T>> {
  const { userId, tool, amount, idempotencyKey: key } = opts
  const limit = opts.rateLimitPerMinute ?? 6

  const previous = await store.findResponse(userId, key)
  if (previous !== null) {
    return {
      ok: true,
      payload: previous as T,
      creditsRemaining: await store.balance(userId),
      replayed: true,
    }
  }

  if ((await store.recentCalls(userId, 60_000)) >= limit) {
    return { ok: false, status: 429, body: { success: false, error: 'rate_limited' } }
  }

  let balance: number | null = null
  try {
    if (amount > 0) {
      balance = await store.consume(amount, tool, key)
    } else {
      await store.logFree(userId, tool, key)
    }
  } catch (e) {
    if (e instanceof InsufficientCreditsError) {
      return {
        ok: false,
        status: 402,
        body: {
          success: false,
          error: 'insufficient_credits',
          required: amount,
          available: await store.balance(userId),
        },
      }
    }
    if (e instanceof DuplicateRequestError) {
      // Same key is being processed by a parallel request.
      return { ok: false, status: 409, body: { success: false, error: 'duplicate_request' } }
    }
    throw e
  }

  let result: { payload: T; model: string }
  try {
    result = await run()
  } catch (e) {
    await store.refund(userId, amount, key)
    const message = e instanceof Error ? e.message : String(e)
    return { ok: false, status: 502, body: { success: false, error: message } }
  }

  try {
    await store.saveResponse(userId, key, result.payload, result.model)
  } catch (e) {
    // The user has their result; only replay is lost.
    console.error('Could not store AI response for replay:', e)
  }

  return { ok: true, payload: result.payload, creditsRemaining: balance, replayed: false }
}

/** [CreditStore] backed by the database functions in the credits migration. */
export function supabaseCreditStore(user: SupabaseClient, admin: SupabaseClient): CreditStore {
  const isDuplicate = (e: { code?: string } | null) => e?.code === '23505'

  return {
    async findResponse(userId, key) {
      const { data, error } = await admin
        .from('ai_logs')
        .select('response')
        .eq('user_id', userId)
        .eq('idempotency_key', key)
        .not('response', 'is', null)
        .maybeSingle()
      if (error) throw new Error(error.message)
      return data?.response ?? null
    },

    async recentCalls(userId, withinMs) {
      const since = new Date(Date.now() - withinMs).toISOString()
      const { count, error } = await admin
        .from('ai_logs')
        .select('id', { count: 'exact', head: true })
        .eq('user_id', userId)
        .gte('created_at', since)
      if (error) throw new Error(error.message)
      return count ?? 0
    },

    async consume(amount, tool, key) {
      // Runs as the user: consume_credits only touches auth.uid()'s balance.
      const { data, error } = await user.rpc('consume_credits', {
        p_amount: amount,
        p_tool: tool,
        p_idempotency_key: key,
      })
      if (error) {
        if (error.message.includes('insufficient_credits')) throw new InsufficientCreditsError()
        if (isDuplicate(error)) throw new DuplicateRequestError()
        throw new Error(error.message)
      }
      return data as number
    },

    async logFree(userId, tool, key) {
      const { error } = await admin.from('ai_logs').insert({
        user_id: userId,
        tool_used: tool,
        credits_consumed: 0,
        idempotency_key: key,
      })
      if (error) {
        if (isDuplicate(error)) throw new DuplicateRequestError()
        throw new Error(error.message)
      }
    },

    async balance(userId) {
      const { data, error } = await admin
        .from('profiles')
        .select('credit_balance')
        .eq('id', userId)
        .single()
      if (error) throw new Error(error.message)
      return data.credit_balance as number
    },

    async refund(userId, amount, key) {
      const { error } = amount > 0
        ? await admin.rpc('refund_credits', {
          p_user: userId,
          p_amount: amount,
          p_idempotency_key: key,
        })
        : await admin.from('ai_logs').delete().eq('user_id', userId).eq('idempotency_key', key)
      if (error) console.error('Refund failed:', error.message)
    },

    async saveResponse(userId, key, response, model) {
      const { error } = await admin
        .from('ai_logs')
        .update({ response, model })
        .eq('user_id', userId)
        .eq('idempotency_key', key)
      if (error) throw new Error(error.message)
    },
  }
}
