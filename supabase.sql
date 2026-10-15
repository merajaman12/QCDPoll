-- Run in Supabase SQL Editor.
-- For a new project/table. If you already created the earlier picnic_responses table,
-- use the migration notes at the bottom instead of running this whole script blindly.

create table if not exists public.picnic_responses (
  id bigint generated always as identity primary key,
  full_name text not null check (length(trim(full_name)) between 1 and 100),
  whatsapp_number text not null,
  time_option text not null check (time_option in ('2:30pm - 7pm', '2:30pm - 9pm')),
  menu_opinion text not null default '',
  comment_text text not null default '',
  created_at timestamptz not null default now(),
  constraint picnic_responses_whatsapp_unique unique (whatsapp_number)
);

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.picnic_responses enable row level security;
alter table public.admin_users enable row level security;

-- Drop known earlier policy names before recreating them.
drop policy if exists "Anyone can submit picnic response" on public.picnic_responses;
drop policy if exists "Only admins can read picnic responses" on public.picnic_responses;
drop policy if exists "Admins can read own admin membership" on public.admin_users;

create policy "Anyone can submit picnic response"
on public.picnic_responses for insert
to anon, authenticated
with check (time_option in ('2:30pm - 7pm', '2:30pm - 9pm')
  and length(trim(full_name)) between 1 and 100
  and whatsapp_number ~ '^\\+[1-9][0-9]{7,14}$');

create policy "Only admins can read picnic responses"
on public.picnic_responses for select
to authenticated
using (exists (
  select 1 from public.admin_users a where a.user_id = auth.uid()
));

create policy "Admins can read own admin membership"
on public.admin_users for select
to authenticated
using (user_id = auth.uid());

-- After creating an admin user in Supabase Authentication > Users, copy its UUID and run:
-- insert into public.admin_users (user_id) values ('PASTE-ADMIN-USER-UUID-HERE');

-- MIGRATION for an earlier version of this poll:
-- If picnic_responses already exists, run these statements separately as needed:
-- alter table public.picnic_responses add column if not exists full_name text;
-- alter table public.picnic_responses add column if not exists whatsapp_number text;
-- alter table public.picnic_responses alter column full_name set not null; -- only after backfilling existing rows
-- alter table public.picnic_responses add constraint picnic_responses_whatsapp_unique unique (whatsapp_number);
-- Existing rows need unique, valid full_name and whatsapp_number values before setting NOT NULL/unique.
-- Never expose a Supabase service_role key in frontend code.
