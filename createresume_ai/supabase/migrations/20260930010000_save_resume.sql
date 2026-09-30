-- save_resume: one transactional round trip for creating or updating a
-- resume and its five child sections (brief E2).
--
-- Before: an update was 1 UPDATE + 5 DELETEs + up to 5 INSERTs from the app,
-- not in a transaction. If the app died or a request failed between the
-- deletes and the inserts, the user's experience or skills were gone.
--
-- Runs as the caller (security invoker), so the existing RLS policies and
-- privileges apply exactly as they did to the app's direct requests. Child
-- rows are replaced (delete + insert) inside the transaction, which needs
-- only the privileges the app already used, not new UPDATE policies.
--
-- Values are converted with jsonb_populate_record(set), so each column keeps
-- its real type. The payload uses the column names the app already writes.

-- Child rows from the payload, without the keys save_resume sets itself.
-- (The app sends resume_id '' for freshly generated children, which is not a
-- valid uuid.)
create or replace function public.save_resume_child_rows(p_resume jsonb, p_key text)
returns jsonb
language sql
immutable
set search_path = public
as $$
  select coalesce(jsonb_agg(e - 'resume_id' - 'created_at' - 'updated_at'), '[]'::jsonb)
    from jsonb_array_elements(coalesce(p_resume -> p_key, '[]'::jsonb)) e
$$;

create or replace function public.save_resume(p_resume jsonb)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  r resumes;
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  -- The owner is always the caller; ignore any user_id or timestamps sent.
  r := jsonb_populate_record(null::resumes, p_resume - 'user_id' - 'created_at' - 'updated_at');
  if r.id is null then
    raise exception 'resume id is required';
  end if;

  insert into resumes as t (id, user_id, title, template_id, summary, ats_score, is_published, updated_at)
  values (r.id, v_user, r.title, r.template_id, r.summary, r.ats_score,
          coalesce(r.is_published, false), now())
  on conflict (id) do update
     set title = excluded.title,
         template_id = excluded.template_id,
         summary = excluded.summary,
         ats_score = excluded.ats_score,
         is_published = excluded.is_published,
         updated_at = now()
   where t.user_id = v_user;

  -- The conflict branch skips rows owned by someone else; refuse instead of
  -- touching their child rows.
  if not exists (select 1 from resumes where id = r.id and user_id = v_user) then
    raise exception 'resume_not_found';
  end if;

  delete from work_experiences where resume_id = r.id;
  insert into work_experiences (id, resume_id, company, role, start_date, end_date, is_current, description, order_index)
  select c.id, r.id, c.company, c.role, c.start_date, c.end_date,
         coalesce(c.is_current, false), coalesce(c.description, ''), coalesce(c.order_index, 0)
    from jsonb_populate_recordset(null::work_experiences, save_resume_child_rows(p_resume, 'work_experiences')) c;

  delete from educations where resume_id = r.id;
  insert into educations (id, resume_id, institution, degree, field, start_date, end_date, gpa, order_index)
  select c.id, r.id, c.institution, c.degree, c.field, c.start_date, c.end_date,
         c.gpa, coalesce(c.order_index, 0)
    from jsonb_populate_recordset(null::educations, save_resume_child_rows(p_resume, 'educations')) c;

  delete from skills where resume_id = r.id;
  insert into skills (id, resume_id, name, level, category, order_index)
  select c.id, r.id, c.name, c.level, c.category, coalesce(c.order_index, 0)
    from jsonb_populate_recordset(null::skills, save_resume_child_rows(p_resume, 'skills')) c;

  delete from projects where resume_id = r.id;
  insert into projects (id, resume_id, name, description, tech_stack, url, order_index)
  select c.id, r.id, c.name, coalesce(c.description, ''), c.tech_stack, c.url, coalesce(c.order_index, 0)
    from jsonb_populate_recordset(null::projects, save_resume_child_rows(p_resume, 'projects')) c;

  delete from honors where resume_id = r.id;
  insert into honors (id, resume_id, title, description, certificate_url, order_index)
  select c.id, r.id, c.title, c.description, c.certificate_url, coalesce(c.order_index, 0)
    from jsonb_populate_recordset(null::honors, save_resume_child_rows(p_resume, 'honors')) c;

  return r.id;
end
$$;

revoke all on function public.save_resume(jsonb) from public, anon;
grant execute on function public.save_resume(jsonb) to authenticated;
