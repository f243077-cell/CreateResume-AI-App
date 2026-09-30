// Validation and one repair attempt for AI-generated resume JSON (brief E7).

import { z } from 'npm:zod@3'
import { type ChatMessage, extractJson } from './openrouter.ts'

const text = z.string()
const optionalText = z.string().nullish()

// Loose where the app is lenient (it maps missing values), strict on the
// shape: every section present and of the right type.
export const resumeSchema = z.object({
  fullName: text.min(1),
  jobTitle: text.min(1),
  email: text,
  phone: optionalText,
  location: optionalText,
  summary: text.min(1),
  skills: z.array(z.object({
    name: text.min(1),
    level: optionalText,
    category: optionalText,
  }).passthrough()).min(1),
  workExperiences: z.array(z.object({
    company: text,
    role: text,
    startDate: optionalText,
    endDate: optionalText,
    isCurrently: z.boolean().nullish(),
    description: text,
  }).passthrough()),
  educations: z.array(z.object({
    institution: text,
    degree: text,
    field: optionalText,
    startDate: optionalText,
    endDate: optionalText,
  }).passthrough()),
  projects: z.array(z.object({
    name: text,
    description: text,
    techStack: z.array(text).nullish(),
    url: optionalText,
  }).passthrough()),
  honors: z.array(z.object({
    title: text,
    description: optionalText,
    certificateUrl: optionalText,
  }).passthrough()).nullish(),
}).passthrough()

export type Completion = (messages: ChatMessage[]) => Promise<{ content: string; model: string }>

/** Parses and validates; returns the resume or a description of the problems. */
export function checkResume(content: string): { ok: true; resume: Record<string, unknown> } | { ok: false; problems: string } {
  let parsed: Record<string, unknown>
  try {
    parsed = extractJson(content)
  } catch (e) {
    return { ok: false, problems: e instanceof Error ? e.message : String(e) }
  }
  const result = resumeSchema.safeParse(parsed)
  if (result.success) return { ok: true, resume: result.data }
  const problems = result.error.issues
    .slice(0, 10)
    .map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`)
    .join('; ')
  return { ok: false, problems }
}

/**
 * Asks the model for a resume and, if the answer is not valid, makes one
 * repair call quoting the problems. Throws if it is still invalid (the
 * caller refunds the credits).
 */
export async function generateValidResume(
  complete: Completion,
  messages: ChatMessage[],
): Promise<{ payload: Record<string, unknown>; model: string }> {
  const first = await complete(messages)
  const firstCheck = checkResume(first.content)
  if (firstCheck.ok) return { payload: firstCheck.resume, model: first.model }

  console.warn('AI resume JSON invalid, asking for a repair:', firstCheck.problems)
  const repaired = await complete([
    ...messages,
    { role: 'assistant', content: first.content.slice(0, 12000) },
    {
      role: 'user',
      content: `Your answer was not valid: ${firstCheck.problems}. Return ONLY the corrected JSON object with exactly the required structure, no other text.`,
    },
  ])
  const secondCheck = checkResume(repaired.content)
  if (secondCheck.ok) return { payload: secondCheck.resume, model: repaired.model }
  throw new Error(`AI response did not match the resume structure: ${secondCheck.problems}`)
}
