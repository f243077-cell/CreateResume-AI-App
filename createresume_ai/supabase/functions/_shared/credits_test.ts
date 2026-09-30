// deno test supabase/functions/_shared/credits_test.ts
import { assertEquals } from 'jsr:@std/assert@1'
import {
  chargeAndRun,
  type CreditStore,
  DuplicateRequestError,
  InsufficientCreditsError,
} from './credits.ts'

/** In-memory store mirroring the SQL functions' behaviour. */
function fakeStore(balance: number, opts: { recent?: number } = {}) {
  const logs = new Map<string, { amount: number; response: unknown }>()
  const store: CreditStore & { balanceNow: () => number; logs: typeof logs } = {
    balanceNow: () => balance,
    logs,
    findResponse: (_u, key) => Promise.resolve(logs.get(key)?.response ?? null),
    recentCalls: () => Promise.resolve(opts.recent ?? logs.size),
    consume(amount, _tool, key) {
      if (logs.has(key)) return Promise.reject(new DuplicateRequestError())
      if (balance < amount) return Promise.reject(new InsufficientCreditsError())
      balance -= amount
      logs.set(key, { amount, response: null })
      return Promise.resolve(balance)
    },
    logFree(_u, _tool, key) {
      if (logs.has(key)) return Promise.reject(new DuplicateRequestError())
      logs.set(key, { amount: 0, response: null })
      return Promise.resolve()
    },
    balance: () => Promise.resolve(balance),
    refund(_u, amount, key) {
      balance += amount
      logs.delete(key)
      return Promise.resolve()
    },
    saveResponse(_u, key, response) {
      logs.get(key)!.response = response
      return Promise.resolve()
    },
  }
  return store
}

const opts = (key: string, amount = 2) => ({ userId: 'u1', tool: 'generate_resume', amount, idempotencyKey: key })
const ok = (payload: unknown) => () => Promise.resolve({ payload, model: 'm' })

Deno.test('charges before the model and returns the remaining balance', async () => {
  const store = fakeStore(3)
  let balanceSeenByModel = -1
  const result = await chargeAndRun(store, opts('k1'), () => {
    balanceSeenByModel = store.balanceNow()
    return Promise.resolve({ payload: { a: 1 }, model: 'm' })
  })
  assertEquals(balanceSeenByModel, 1, 'charged before the model ran')
  assertEquals(result, { ok: true, payload: { a: 1 }, creditsRemaining: 1, replayed: false })
})

Deno.test('model failure refunds the credits and removes the log row', async () => {
  const store = fakeStore(3)
  const result = await chargeAndRun(store, opts('k1'), () => Promise.reject(new Error('all models down')))
  assertEquals(result.ok, false)
  if (!result.ok) {
    assertEquals(result.status, 502)
    assertEquals(result.body.error, 'all models down')
  }
  assertEquals(store.balanceNow(), 3)
  assertEquals(store.logs.size, 0)
})

Deno.test('not enough credits returns 402 and never calls the model', async () => {
  const store = fakeStore(1)
  let called = false
  const result = await chargeAndRun(store, opts('k1'), () => {
    called = true
    return Promise.resolve({ payload: {}, model: 'm' })
  })
  assertEquals(called, false)
  assertEquals(result, {
    ok: false,
    status: 402,
    body: { success: false, error: 'insufficient_credits', required: 2, available: 1 },
  })
})

Deno.test('a retry with the same key is replayed without a second charge', async () => {
  const store = fakeStore(5)
  await chargeAndRun(store, opts('k1'), ok({ resume: 1 }))
  let calls = 0
  const retry = await chargeAndRun(store, opts('k1'), () => {
    calls++
    return Promise.resolve({ payload: { resume: 2 }, model: 'm' })
  })
  assertEquals(calls, 0)
  assertEquals(retry, { ok: true, payload: { resume: 1 }, creditsRemaining: 3, replayed: true })
  assertEquals(store.balanceNow(), 3)
})

Deno.test('a parallel request with an in-flight key gets 409', async () => {
  const store = fakeStore(5)
  store.logs.set('k1', { amount: 2, response: null }) // charged, no response yet
  const result = await chargeAndRun(store, opts('k1'), ok({}))
  assertEquals(result.ok ? 0 : result.status, 409)
  assertEquals(store.balanceNow(), 5)
})

Deno.test('rate limit returns 429 before charging', async () => {
  const store = fakeStore(5, { recent: 6 })
  const result = await chargeAndRun(store, opts('k1'), ok({}))
  assertEquals(result.ok ? 0 : result.status, 429)
  assertEquals(store.balanceNow(), 5)
})

Deno.test('free actions are logged but not charged; failures clear the log', async () => {
  const store = fakeStore(0)
  const good = await chargeAndRun(store, opts('k1', 0), ok('better text'))
  assertEquals(good, { ok: true, payload: 'better text', creditsRemaining: null, replayed: false })
  assertEquals(store.logs.has('k1'), true)

  const bad = await chargeAndRun(store, opts('k2', 0), () => Promise.reject(new Error('x')))
  assertEquals(bad.ok, false)
  assertEquals(store.logs.has('k2'), false)
  assertEquals(store.balanceNow(), 0)
})
