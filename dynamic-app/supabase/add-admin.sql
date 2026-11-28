-- First create/invite the owner's user in Supabase Authentication > Users.
-- Replace OWNER_EMAIL_HERE. Never put a password in this file.
insert into public.admin_users(user_id)
select id from auth.users where lower(email)=lower('OWNER_EMAIL_HERE')
on conflict(user_id) do nothing;
-- Verify exactly one row was added or already exists:
select u.email from public.admin_users a join auth.users u on u.id=a.user_id;
