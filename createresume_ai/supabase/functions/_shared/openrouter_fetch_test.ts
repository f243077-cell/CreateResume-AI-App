// deno test --allow-env supabase/functions/_shared/openrouter_fetch_test.ts
// callModels against a stubbed fetch: JSON-mode fallback, deadline, and the
// per-model summary when everything fails.
import { assert, assertEquals, assertRejects } from 'jsr:@std/assert@1'
import { callModels } from './openrouter.ts'

type Reply = { status: number; body?: unknown } | 'hang'

function stubFetch(replies: Record<string, Reply[]>) {
  const seen: { model: string; json: boolean }[] = []
  const original = globalThis.fetch
  globalThis.fetch = ((_url: string, init: RequestInit) => {
    const body = JSON.parse(init.body as string)
    seen.push({ model: body.model, json: 'response_format' in body })
    const reply = replies[body.model].shift()!
    if (reply === 'hang') {
      return new Promise((_, reject) =>
        init.signal!.addEventListener('abort', () => reject(new DOMException('aborted', 'AbortError')))
      )
    }
    return Promise.resolve(new Response(JSON.stringify(reply.body ?? { error: 'x' }), { status: reply.status }))
  }) as typeof fetch
  return { seen, restore: () => (globalThis.fetch = original) }
}

const answer = (text: string) => ({ status: 200, body: { choices: [{ message: { content: text } }] } })
const msgs = [{ role: 'user' as const, content: 'x' }]

Deno.test('a model that rejects JSON mode is retried without it', async () => {
  const f = stubFetch({ a: [{ status: 400 }, answer('{"ok":true}')] })
  try {
    const r = await callModels('k', msgs, { maxTokens: 10, temperature: 0, json: true, models: ['a'] })
    assertEquals(r, { content: '{"ok":true}', model: 'a' })
    assertEquals(f.seen, [{ model: 'a', json: true }, { model: 'a', json: false }])
  } finally {
    f.restore()
  }
})

Deno.test('a slow model times out and the next one answers', async () => {
  const f = stubFetch({ slow: ['hang'], fast: [answer('Led the team.')] })
  try {
    const r = await callModels('k', msgs, { maxTokens: 10, temperature: 0, models: ['slow', 'fast'], timeoutMs: 50 })
    assertEquals(r.model, 'fast')
  } finally {
    f.restore()
  }
})

Deno.test('when every model fails the error lists each outcome', async () => {
  const f = stubFetch({ a: [{ status: 429 }], b: ['hang'], c: [answer('same thing here, same thing here, same thing here')] })
  try {
    const err = await assertRejects(() =>
      callModels('k', msgs, { maxTokens: 10, temperature: 0, models: ['a', 'b', 'c'], timeoutMs: 50 })
    )
    const message = (err as Error).message
    assert(message.includes('a: HTTP 429'), message)
    assert(message.includes('b: timed out'), message)
    assert(message.includes('c: repeating answer'), message)
  } finally {
    f.restore()
  }
})

Deno.test('the shared deadline stops trying further models', async () => {
  const f = stubFetch({ a: [{ status: 429 }], b: [answer('Led the team.')] })
  try {
    const err = await assertRejects(() =>
      callModels('k', msgs, { maxTokens: 10, temperature: 0, models: ['a', 'b'], deadline: Date.now() + 1000 })
    )
    assert((err as Error).message.includes('skipped (out of time)'))
    assertEquals(f.seen.length, 0, 'under 5 s left: no model is started')
  } finally {
    f.restore()
  }
})
