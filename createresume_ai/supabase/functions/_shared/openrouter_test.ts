// deno test --allow-env supabase/functions/_shared/openrouter_test.ts
import { assertEquals, assertThrows } from 'jsr:@std/assert@1'
import { cleanText, DEFAULT_MODELS, extractJson, modelList } from './openrouter.ts'

Deno.test('extractJson ignores wrapper text and code fences', () => {
  assertEquals(extractJson('```json\n{"a": {"b": 1}}\n```'), { a: { b: 1 } })
  assertEquals(extractJson('Here is your resume:\n{"a": 1}\nHope it helps!'), { a: 1 })
})

Deno.test('extractJson rejects answers without an object', () => {
  assertThrows(() => extractJson('Sorry, I cannot help.'))
  assertThrows(() => extractJson('{not json}'))
})

Deno.test('modelList reads AI_MODELS, else the defaults', () => {
  Deno.env.delete('AI_MODELS')
  assertEquals(modelList(), DEFAULT_MODELS)
  Deno.env.set('AI_MODELS', ' a/b:free , c/d ,, ')
  assertEquals(modelList(), ['a/b:free', 'c/d'])
  Deno.env.delete('AI_MODELS')
})

Deno.test('cleanText strips fences and wrapping quotes', () => {
  assertEquals(cleanText('```\nLed X\n```'), 'Led X')
  assertEquals(cleanText('"Led X"'), 'Led X')
})
