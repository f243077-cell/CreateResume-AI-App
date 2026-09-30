// Shared HTTP helpers for the Edge Functions.

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type, idempotency-key',
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

/** Trimmed string field from a request body, cut to [max] characters. */
export function field(body: Record<string, unknown>, name: string, max: number): string {
  const value = body[name]
  return typeof value === 'string' ? value.trim().slice(0, max) : ''
}

/** The client's Idempotency-Key, or a fresh one when it sent none. */
export function idempotencyKey(req: Request): string {
  const key = (req.headers.get('Idempotency-Key') ?? '').trim()
  return key && key.length <= 100 ? key : crypto.randomUUID()
}
