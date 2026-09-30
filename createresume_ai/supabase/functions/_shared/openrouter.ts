// OpenRouter model chain shared by the Edge Functions.

// Free model IDs change often, so the list can be replaced without a code
// change: `supabase secrets set AI_MODELS=modelA,modelB,modelC`.
// Free models are often rate-limited upstream (429), so try several. A live
// test hit 429 on all three of an earlier, shorter list at once.
export const DEFAULT_MODELS = [
  'google/gemma-4-31b-it:free',
  'nvidia/nemotron-3-super-120b-a12b:free',
  'google/gemma-4-26b-a4b-it:free',
  'nvidia/nemotron-3-ultra-550b-a55b:free',
  'qwen/qwen3.8-27b:free',
  'dots-studio/dots-3-note-preview:free',
]

/**
 * True when a model answer is stuck repeating itself (the same clause of
 * three or more words appearing three or more times), which some free
 * models do. Such answers are rejected so the next model is tried.
 */
export function looksDegenerate(text: string): boolean {
  const counts = new Map<string, number>()
  for (const part of text.toLowerCase().split(/[,.;:\n]+/)) {
    const clause = part.replace(/[^a-z0-9 ]+/g, ' ').replace(/\s+/g, ' ').trim()
    if (clause.split(' ').length < 3) continue
    const n = (counts.get(clause) ?? 0) + 1
    if (n >= 3) return true
    counts.set(clause, n)
  }
  return false
}

function envList(name: string): string[] {
  return (Deno.env.get(name) ?? '')
    .split(',')
    .map((m) => m.trim())
    .filter(Boolean)
}

/**
 * Models to try, in order. Premium users get AI_MODELS_PREMIUM (for example
 * a stronger paid model) when that secret is set; everyone else, and premium
 * users without it, get AI_MODELS or the free defaults.
 */
export function modelList(premium = false): string[] {
  const premiumModels = premium ? envList('AI_MODELS_PREMIUM') : []
  if (premiumModels.length > 0) return premiumModels
  const models = envList('AI_MODELS')
  return models.length > 0 ? models : DEFAULT_MODELS
}

export type ChatMessage = { role: 'system' | 'user' | 'assistant'; content: string }

/** Tries each model in turn; returns the first non-empty answer. */
export async function callModels(
  apiKey: string,
  messages: ChatMessage[],
  opts: {
    maxTokens: number
    temperature: number
    timeoutMs?: number
    /** Ask for a JSON object (ignored by models that do not support it). */
    json?: boolean
    models?: string[]
    /** Rejects an answer so the next model is tried (default: not degenerate). */
    accept?: (content: string) => boolean
  },
): Promise<{ content: string; model: string }> {
  let lastError = ''

  for (const model of opts.models ?? modelList()) {
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), opts.timeoutMs ?? 20000)
    try {
      const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://createresume.ai',
          'X-Title': 'CreateResume AI',
        },
        body: JSON.stringify({
          model,
          messages,
          temperature: opts.temperature,
          max_tokens: opts.maxTokens,
          ...(opts.json ? { response_format: { type: 'json_object' } } : {}),
        }),
        signal: controller.signal,
      })
      if (!response.ok) {
        lastError = await response.text()
        console.error(`Model "${model}" failed:`, lastError)
        continue
      }
      const data = await response.json()
      const content = data.choices?.[0]?.message?.content
      if (typeof content === 'string' && content.trim()) {
        const accept = opts.accept ?? ((c: string) => !looksDegenerate(c))
        if (accept(content)) {
          console.info(`Answered by model: ${model}`)
          return { content, model }
        }
        lastError = `rejected answer from ${model}`
        console.warn(`Model "${model}" gave an unusable answer; trying the next one`)
        continue
      }
      lastError = 'empty response'
    } catch (err) {
      lastError = err instanceof Error ? err.message : String(err)
      console.error(`Model "${model}" request failed/timed out:`, lastError)
    } finally {
      clearTimeout(timeoutId)
    }
  }
  throw new Error(`All AI models are currently unavailable. Last error: ${lastError}`)
}

/** Parses the JSON object in a model answer, ignoring any wrapper text. */
export function extractJson(text: string): Record<string, unknown> {
  const start = text.indexOf('{')
  const end = text.lastIndexOf('}')
  if (start < 0 || end <= start) throw new Error('AI response contained no JSON object')
  const parsed = JSON.parse(text.slice(start, end + 1))
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('AI response JSON was not an object')
  }
  return parsed as Record<string, unknown>
}

/** Removes wrappers models sometimes add around plain-text answers. */
export function cleanText(text: string): string {
  let result = text.trim()
  result = result.replace(/^```[a-z]*\s*/i, '').replace(/\s*```$/, '')
  if (result.length > 1 && result.startsWith('"') && result.endsWith('"')) {
    result = result.slice(1, -1)
  }
  return result.trim()
}
