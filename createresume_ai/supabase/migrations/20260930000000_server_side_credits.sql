-- Server-side credits (brief S1, S2, S3).
--
-- Before: the app wrote credit_balance and subscription_status itself, so
-- any signed-in user could PATCH their own profile to unlimited credits.
-- After: clients may update only harmless profile columns; credits change
-- only through consume_credits (callable by the signed-in user, can only
-- lower their own balance) and refund_credits (service role only, used by
-- the Edge Functions when an AI call fails).
--
-- Assumes the tables described in supabase_database_service.dart:
--   profiles(id, email, full_name, subscription_status, credit_balance, ...)
--   ai_logs(id, user_id, tool_used, credits_consumed, input_summary, created_at)
-- Verify against the live schema (`supabase db pull`) before applying.

-- ── ai_logs: idempotency, replay and which model answered ─────────────
alter table public.ai_logs
  add column if not exists idempotency_key text,
  add column if not exists model text,
  add column if not exists response jsonb;

create unique index if not exists ai_logs_user_idempotency_key
  on public.ai_logs (user_id, idempotency_key)
  where idempotency_key is not null;

-- Used for the per-user rate limit (recent calls).
create index if not exists ai_logs_user_created_at
  on public.ai_logs (user_id, created_at desc);

-- ── Privileges ─────────────────────────────────────────────────────────
-- Profiles: no client inserts (the trigger below creates rows) and updates
-- only on these columns. credit_balance and subscription_status are
-- deliberately missing.
revoke insert, update on public.profiles from anon, authenticated;
grant update (full_name, photo_url, ai_writing_style, theme_preference,
              phone, location, job_title, linkedin, github, leetcode)
  on public.profiles to authenticated;

-- ai_logs: written only by the functions below or the service role.
revoke insert, update, delete on public.ai_logs from anon, authenticated;

-- ── Profile row on sign-up (replaces the client-side upserts) ─────────
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, subscription_status, credit_balance)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(
      nullif(new.raw_user_meta_data ->> 'full_name', ''),
      nullif(new.raw_user_meta_data ->> 'name', ''),
      nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
      'User'
    ),
    'free',
    3 -- free starter credits
  )
  on conflict (id) do nothing;
  return new;
end
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Users who signed up before this migration but never got a profile row
-- (the app used to create it on first fetch).
insert into public.profiles (id, email, full_name, subscription_status, credit_balance)
select
  u.id,
  coalesce(u.email, ''),
  coalesce(
    nullif(u.raw_user_meta_data ->> 'full_name', ''),
    nullif(u.raw_user_meta_data ->> 'name', ''),
    nullif(split_part(coalesce(u.email, ''), '@', 1), ''),
    'User'
  ),
  'free',
  3
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- ── consume_credits: atomic check-and-deduct plus a log row ────────────
-- Two parallel calls cannot both succeed on the same credits: the UPDATE
-- only matches while the balance is high enough.
create or replace function public.consume_credits(
  p_amount int,
  p_tool text,
  p_idempotency_key text default null
)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance int;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;
  -- A negative amount would add credits.
  if p_amount is null or p_amount < 1 then
    raise exception 'invalid_amount';
  end if;

  update profiles
     set credit_balance = credit_balance - p_amount
   where id = auth.uid()
     and credit_balance >= p_amount
  returning credit_balance into v_balance;

  if not found then
    raise exception 'insufficient_credits';
  end if;

  insert into ai_logs (user_id, tool_used, credits_consumed, idempotency_key)
  values (auth.uid(), p_tool, p_amount, p_idempotency_key);

  return v_balance;
end
$$;

revoke all on function public.consume_credits(int, text, text) from public, anon;
grant execute on function public.consume_credits(int, text, text) to authenticated;

-- ── refund_credits: service role only ──────────────────────────────────
-- Also removes the log row for the failed call so a retry with the same
-- idempotency key is charged normally.
create or replace function public.refund_credits(
  p_user uuid,
  p_amount int,
  p_idempotency_key text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_amount is null or p_amount < 1 then
    raise exception 'invalid_amount';
  end if;

  update profiles
     set credit_balance = credit_balance + p_amount
   where id = p_user;

  if p_idempotency_key is not null then
    delete from ai_logs
     where user_id = p_user
       and idempotency_key = p_idempotency_key;
  end if;
end
$$;

revoke all on function public.refund_credits(uuid, int, text) from public, anon, authenticated;
grant execute on function public.refund_credits(uuid, int, text) to service_role;
