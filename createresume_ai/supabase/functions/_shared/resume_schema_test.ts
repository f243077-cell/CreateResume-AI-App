// deno test supabase/functions/_shared/resume_schema_test.ts
import { assertEquals, assertRejects } from 'jsr:@std/assert@1'
import { checkResume, type Completion, generateValidResume } from './resume_schema.ts'

const valid = {
  fullName: 'Ana', jobTitle: 'Engineer', email: 'a@b.test', summary: 'Builds apps.',
  skills: [{ name: 'Dart', level: 'expert', category: 'Languages' }],
  workExperiences: [{ company: 'Nexa', role: 'Dev', startDate: '2022-03', endDate: null, isCurrently: true, description: 'Built X' }],
  educations: [{ institution: 'FAST', degree: 'BS', field: 'CS', startDate: '2017-09', endDate: '2021-05' }],
  projects: [{ name: 'App', description: 'd', techStack: ['Flutter'], url: '' }],
  honors: [],
}

Deno.test('a well-formed resume passes, even inside wrapper text', () => {
  const r = checkResume('Here you go:\n```json\n' + JSON.stringify(valid) + '\n```')
  assertEquals(r.ok, true)
})

Deno.test('wrong shapes are reported with their paths', () => {
  const bad = { ...valid, skills: 'Dart, Go', workExperiences: [{ company: 'Nexa' }] }
  const r = checkResume(JSON.stringify(bad))
  assertEquals(r.ok, false)
  if (!r.ok) {
    assertEquals(r.problems.includes('skills'), true)
    assertEquals(r.problems.includes('workExperiences.0.role'), true)
  }
})

function fakeModel(answers: string[]): Completion & { calls: number; lastMessages?: unknown[] } {
  const fn = (async (messages) => {
    fn.lastMessages = messages
    return { content: answers[fn.calls++], model: 'm' }
  }) as Completion & { calls: number; lastMessages?: unknown[] }
  fn.calls = 0
  return fn
}

Deno.test('a valid first answer needs no repair call', async () => {
  const model = fakeModel([JSON.stringify(valid)])
  const r = await generateValidResume(model, [{ role: 'user', content: 'x' }])
  assertEquals(model.calls, 1)
  assertEquals(r.payload.fullName, 'Ana')
})

Deno.test('an invalid answer gets one repair call quoting the problems', async () => {
  const model = fakeModel(['not json at all', JSON.stringify(valid)])
  const r = await generateValidResume(model, [{ role: 'user', content: 'x' }])
  assertEquals(model.calls, 2)
  assertEquals(r.payload.jobTitle, 'Engineer')
  const last = (model.lastMessages as { role: string; content: string }[]).at(-1)!
  assertEquals(last.role, 'user')
  assertEquals(last.content.includes('not valid'), true)
})

Deno.test('still invalid after the repair: throws (caller refunds)', async () => {
  const model = fakeModel(['{}', '{"fullName": "Ana"}'])
  await assertRejects(() => generateValidResume(model, [{ role: 'user', content: 'x' }]))
  assertEquals(model.calls, 2)
})
