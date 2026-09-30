// OpenRouter model chain shared by the Edge Functions.

// Free model IDs change often, so the list can be replaced without a code
// change: `supabase secrets set AI_MODELS=modelA,modelB,modelC`.
export const DEFAULT_MODELS = [
  'google/gemma-4-31b-it:free',
  'nvidia/nemotron-3-super-120b-a12b:free',
  'qwen/qwen3.8-27b:free',
]

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
        console.info(`Answered by model: ${model}`)
        return { content, model }
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
