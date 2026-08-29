begin;

select plan(14);

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'coffee_logs', 'coffee_logs table exists');
select col_is_pk('public', 'profiles', 'id', 'profiles.id is the primary key');
select col_is_pk('public', 'coffee_logs', 'id', 'coffee_logs.id is the primary key');

insert into auth.users (id, email, created_at, updated_at)
values
  ('11111111-1111-4111-8111-111111111111', 'owner@example.test', now(), now()),
  ('22222222-2222-4222-8222-222222222222', 'other@example.test', now(), now());

set local role authenticated;
set local request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';

insert into public.coffee_logs (user_id, created_at)
values ('11111111-1111-4111-8111-111111111111', now());

select is(
  (select count(*)::bigint from public.coffee_logs),
  1::bigint,
  'owner can read their coffee log'
);

reset role;
set local role authenticated;
set local request.jwt.claim.sub = '22222222-2222-4222-8222-222222222222';

select is(
  (select count(*)::bigint from public.coffee_logs),
  0::bigint,
  'another user cannot read the owner coffee log'
);

select is(
  (
    with changed as (
      update public.coffee_logs
      set created_at = now()
      where user_id = '11111111-1111-4111-8111-111111111111'
      returning id
    )
    select count(*)::bigint from changed
  ),
  0::bigint,
  'another user cannot update the owner coffee log'
);

delete from public.coffee_logs
where user_id = '11111111-1111-4111-8111-111111111111';

reset role;

select is(
  (select count(*)::bigint from public.coffee_logs),
  1::bigint,
  'another user cannot delete the owner coffee log'
);

set local role authenticated;
set local request.jwt.claim.sub = '22222222-2222-4222-8222-222222222222';

insert into public.coffee_logs (user_id, created_at)
values ('22222222-2222-4222-8222-222222222222', '2026-08-28 09:00:00+00');

select is(
  (select count(*)::bigint from public.delete_latest_coffee()),
  1::bigint,
  'delete_latest_coffee deletes the current user latest log'
);

reset role;

select is(
  (
    select count(*)::bigint
    from public.coffee_logs
    where user_id = '11111111-1111-4111-8111-111111111111'
  ),
  1::bigint,
  'deleting another user latest log leaves the owner log untouched'
);

set local role authenticated;
set local request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';

select is(
  (
    with changed as (
      update public.coffee_logs
      set created_at = now() - interval '1 hour'
      where user_id = '11111111-1111-4111-8111-111111111111'
      returning id
    )
    select count(*)::bigint from changed
  ),
  1::bigint,
  'owner can correct a coffee from the last 24 hours'
);

insert into public.coffee_logs (user_id, created_at)
values (
  '11111111-1111-4111-8111-111111111111',
  now() - interval '25 hours'
);

select is(
  (
    with changed as (
      update public.coffee_logs
      set created_at = now()
      where user_id = '11111111-1111-4111-8111-111111111111'
        and created_at < now() - interval '24 hours'
      returning id
    )
    select count(*)::bigint from changed
  ),
  0::bigint,
  'owner cannot correct a coffee older than 24 hours'
);

select lives_ok(
  $$select public.delete_own_account()$$,
  'an authenticated user can delete their own account'
);

reset role;

select is(
  (
    select count(*)::bigint
    from auth.users
    where id = '11111111-1111-4111-8111-111111111111'
  ),
  0::bigint,
  'account deletion removes the authenticated user'
);

select * from finish();
rollback;
