// deno test --allow-env supabase/functions/_shared/openrouter_test.ts
import { assertEquals, assertThrows } from 'jsr:@std/assert@1'
import { cleanText, DEFAULT_MODELS, extractJson, looksDegenerate, modelList } from './openrouter.ts'

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

Deno.test('premium users get AI_MODELS_PREMIUM when set', () => {
  Deno.env.delete('AI_MODELS')
  Deno.env.delete('AI_MODELS_PREMIUM')
  assertEquals(modelList(true), DEFAULT_MODELS, 'no premium list: same as free')
  Deno.env.set('AI_MODELS_PREMIUM', 'paid/model')
  assertEquals(modelList(true), ['paid/model'])
  assertEquals(modelList(false), DEFAULT_MODELS)
  Deno.env.delete('AI_MODELS_PREMIUM')
})

Deno.test('looksDegenerate catches a model repeating itself', () => {
  assertEquals(
    looksDegenerate('Fixed bugs in the Flutter app, fixed bugs in the Flutter app, fixed bugs in the Flutter app'),
    true,
  )
  assertEquals(looksDegenerate('Resolved bugs in the Flutter app while collaborating with the backend team.'), false)
  // Short list items may repeat a word without being degenerate.
  assertEquals(looksDegenerate('Matching skills\n- Flutter\n- Dart\nMissing skills\n- Kotlin\n- Riverpod'), false)
})
