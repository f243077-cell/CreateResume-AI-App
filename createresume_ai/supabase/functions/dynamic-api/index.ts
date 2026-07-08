// @ts-nocheck
// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

interface ReqPayload {
  description: string;
  careerStage: string;
  jobTitle: string;
  userId: string;
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

console.info("dynamic-api function started");

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ success: false, error: 'Method not allowed' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { description, careerStage, jobTitle, userId }: ReqPayload = await req.json()

    if (!description || !careerStage || !jobTitle || !userId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get OpenRouter API key from Supabase secrets
    const openRouterApiKey = Deno.env.get('OPENROUTER_API_KEY')
    if (!openRouterApiKey) {
      console.error('OPENROUTER_API_KEY secret not set. Run: supabase secrets set OPENROUTER_API_KEY=your_key')
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'OpenRouter API key not configured. Please set the OPENROUTER_API_KEY secret in Supabase.' 
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
const systemPrompt = `You are a professional resume writer creating a detailed, ATS-optimized resume. Return ONLY a valid JSON object with NO markdown, NO code blocks, NO extra text. Be thorough and specific throughout — avoid short, generic, or vague content in every section. Base all details on what the user's description implies; do not invent facts, employers, numbers, or achievements that aren't reasonably supported by their input. Where the user's description doesn't give enough detail for a rich answer, expand using reasonable, clearly-scoped professional phrasing (responsibilities, tools, scope of work) rather than inventing specific metrics that weren't mentioned.

The JSON must have exactly this structure:
{
  fullName: string,
  jobTitle: string,
  email: string (extract from description or use placeholder),
  phone: string (extract or use placeholder),
  location: string (extract or use placeholder),
  summary: string (4-6 sentences, professional and detailed — cover years of experience, core technical strengths, domain expertise, and what makes this candidate stand out; ATS-optimized with relevant keywords),
  skills: [{ name: string, level: 'beginner'|'intermediate'|'expert', category: string (group name like 'Languages', 'Backend & Distributed Systems', 'Databases & Caching', 'DevOps & Infrastructure', 'Tools & Frameworks' — choose categories that fit; be comprehensive, 12-18 skills total spread across 4-6 categories, inferring reasonable related tools/technologies commonly used alongside what the user mentioned) }],
  workExperiences: [{
    company: string,
    role: string,
    startDate: string,
    endDate: string,
    isCurrently: boolean,
    description: string (5-7 detailed bullet points as a single string separated by newlines, each starting with a strong action verb; describe the specific systems, scale, technologies, and responsibilities involved; include a quantified result — metrics, percentage, dollar amount, scale, or time saved — ONLY where the user's description reasonably supports one; otherwise focus on technical depth and scope rather than fabricating a number)
  }],
  educations: [{
    institution: string,
    degree: string,
    field: string,
    startDate: string,
    endDate: string,
    gpa: string
  }],
  projects: [{
    name: string,
    description: string (3-4 detailed bullet points as a single string separated by newlines, each starting with an action verb; explain the architecture, technologies, and specific technical decisions involved, and the outcome or purpose of the project),
    techStack: [string] (5-8 relevant technologies),
    url: string
  }],
  honors: [{ title: string, description: string, certificateUrl: string }] (0-4 honors/awards/certifications if the description mentions any achievements, competitions, hackathons, or recognitions — otherwise return an empty array)
}`

    const userPrompt = `Career Stage: ${careerStage}\nTarget Job Title: ${jobTitle}\n\nUser Description:\n${description}\n\nGenerate a complete resume based on this information.`

    // Try multiple free models in sequence — free-tier providers can be
    // intermittently rate-limited or unavailable, so we fall back rather
    // than fail on the first hiccup.
    const modelsToTry = [
      'openai/gpt-oss-20b:free',
      'meta-llama/llama-3.3-70b-instruct:free',
      'qwen/qwen-2.5-7b-instruct:free',
    ]

    let openRouterData: any = null
    let lastError = ''

    for (const model of modelsToTry) {
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 20000) // 20s per model

      let openRouterResponse
      try {
        openRouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${openRouterApiKey}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://createresume.ai',
            'X-Title': 'CreateResume AI',
          },
          body: JSON.stringify({
            model,
            messages: [
              { role: 'system', content: systemPrompt },
              { role: 'user', content: userPrompt }
            ],
            temperature: 0.7,
            max_tokens: 4000,
          }),
          signal: controller.signal,
        })
      } catch (err) {
        clearTimeout(timeoutId)
        lastError = err instanceof Error ? err.message : String(err)
        console.error(`Model "${model}" request failed/timed out:`, lastError)
        continue
      }
      clearTimeout(timeoutId)

      if (openRouterResponse.ok) {
        openRouterData = await openRouterResponse.json()
        console.info(`Resume generated successfully using model: ${model}`)
        break
      }

      lastError = await openRouterResponse.text()
      console.error(`Model "${model}" failed:`, lastError)
    }

    if (!openRouterData) {
      return new Response(
        JSON.stringify({
          success: false,
          error: `All AI models are currently unavailable. Last error: ${lastError}`
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const aiContent = openRouterData.choices?.[0]?.message?.content

    if (!aiContent) {
      return new Response(
        JSON.stringify({ success: false, error: 'No content in AI response' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Clean the response - remove markdown code blocks if present
    let cleanedContent = aiContent.trim()
    if (cleanedContent.startsWith('```json')) {
      cleanedContent = cleanedContent.slice(7)
    }
    if (cleanedContent.startsWith('```')) {
      cleanedContent = cleanedContent.slice(3)
    }
    if (cleanedContent.endsWith('```')) {
      cleanedContent = cleanedContent.slice(0, -3)
    }
    cleanedContent = cleanedContent.trim()

    // Parse JSON
    let resumeData
    try {
      resumeData = JSON.parse(cleanedContent)
    } catch (parseError) {
      console.error('JSON parse error:', parseError)
      console.error('Content that failed to parse:', cleanedContent)
      return new Response(
        JSON.stringify({ success: false, error: 'AI response parse failed' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate required fields
    const requiredFields = ['fullName', 'jobTitle', 'email', 'summary', 'skills', 'workExperiences', 'educations', 'projects']
    for (const field of requiredFields) {
      if (!resumeData[field]) {
        return new Response(
          JSON.stringify({ success: false, error: `Missing required field: ${field}` }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    return new Response(
      JSON.stringify({ success: true, resume: resumeData }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Edge function error:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error instanceof Error ? error.message : 'Internal server error' 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})