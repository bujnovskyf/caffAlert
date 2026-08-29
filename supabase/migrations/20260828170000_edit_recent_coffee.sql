grant update on table public.coffee_logs to authenticated;

create policy "Users can update recent coffee logs"
  on public.coffee_logs
  for update
  to authenticated
  using (
    (select auth.uid()) = user_id
    and created_at >= now() - interval '24 hours'
  )
  with check (
    (select auth.uid()) = user_id
    and created_at >= now() - interval '24 hours'
    and created_at <= now()
  );
