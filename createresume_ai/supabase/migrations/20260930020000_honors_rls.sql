-- honors: let users write honors on their own resumes.
--
-- A live test of save_resume showed that inserting into honors was rejected
-- by row-level security ("new row violates row-level security policy for
-- table honors") while the other child tables accepted the same rows. So
-- saving any resume with honors failed (save_resume rolls the whole save
-- back), and the app's earlier direct inserts would have failed the same way.
--
-- This adds the same rule the other child sections follow: a row is
-- accessible when its parent resume belongs to the caller. Policies are
-- permissive (OR-ed), so existing honors policies keep working; this grants
-- nothing beyond the owner's own rows.

alter table public.honors enable row level security;

drop policy if exists "Users manage honors of own resumes" on public.honors;
create policy "Users manage honors of own resumes"
  on public.honors
  for all
  to authenticated
  using (
    exists (
      select 1 from public.resumes r
       where r.id = honors.resume_id
         and r.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.resumes r
       where r.id = honors.resume_id
         and r.user_id = auth.uid()
    )
  );
