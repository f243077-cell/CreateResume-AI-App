// Identifies the caller from their JWT. Any userId in the request body is
// ignored (brief S2).

import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2'

export type Caller = {
  userId: string
  /** Acts as the user: RLS and column grants apply. */
  user: SupabaseClient
  /** Service role: for refunds, logs and replays only. */
  admin: SupabaseClient
}

export async function authenticate(req: Request): Promise<Caller | null> {
  const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '')
  if (!token) return null

  const url = Deno.env.get('SUPABASE_URL') ?? ''
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  const noSession = { persistSession: false, autoRefreshToken: false }

  const user = createClient(url, anonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: noSession,
  })
  const { data } = await user.auth.getUser(token)
  if (!data.user) return null

  const admin = createClient(url, serviceKey, { auth: noSession })
  return { userId: data.user.id, user, admin }
}
