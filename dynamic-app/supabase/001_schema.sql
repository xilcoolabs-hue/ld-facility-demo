begin;
create extension if not exists pgcrypto;
create table if not exists public.admin_users (user_id uuid primary key references auth.users(id) on delete cascade, created_at timestamptz not null default now());
create table if not exists public.services (id uuid primary key default gen_random_uuid(),title text not null check(length(title) between 1 and 120),description text not null,details text not null default '',image_url text not null,alt text not null,sort_order integer not null default 0,active boolean not null default true,created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists public.site_settings(id text primary key default 'main' check(id='main'),data jsonb not null default '{}'::jsonb,updated_at timestamptz not null default now());
create table if not exists public.enquiries (id uuid primary key default gen_random_uuid(),request_id uuid not null unique,name text not null,email text not null,phone text not null,suburb text not null,service text not null,property text not null,message text not null,status text not null default 'new' check(status in ('new','contacted','in_progress','closed','archived')),notes text not null default '',email_status text not null default 'pending' check(email_status in ('pending','sent')),email_sent_at timestamptz,consent_at timestamptz not null,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),updated_by uuid references auth.users(id) on delete set null);
create index if not exists enquiries_status_created on public.enquiries(status,created_at desc);
create table if not exists public.rate_limits(key text not null,window_start bigint not null,hits integer not null default 1,primary key(key,window_start));
alter table public.admin_users enable row level security;
alter table public.services enable row level security;
alter table public.site_settings enable row level security;
alter table public.enquiries enable row level security;
alter table public.rate_limits enable row level security;
revoke all on public.admin_users,public.services,public.site_settings,public.enquiries,public.rate_limits from anon,authenticated;
grant all on public.admin_users,public.services,public.site_settings,public.enquiries,public.rate_limits to service_role;
-- Only the server holds the service-role key. No public or authenticated client can read enquiries directly.
create or replace function public.consume_rate_limit(p_key text,p_limit integer,p_window integer) returns boolean language plpgsql security definer set search_path=public as $$
declare w bigint; n integer;
begin
 if p_window<1 or p_limit<1 then return false; end if;
 w:=floor(extract(epoch from now())/p_window)::bigint;
 insert into public.rate_limits(key,window_start,hits) values(p_key,w,1) on conflict(key,window_start) do update set hits=public.rate_limits.hits+1 returning hits into n;
 delete from public.rate_limits where window_start < floor(extract(epoch from now())/p_window)::bigint-192;
 return n<=p_limit;
end;$$;
revoke all on function public.consume_rate_limit(text,integer,integer) from public,anon,authenticated;
grant execute on function public.consume_rate_limit(text,integer,integer) to service_role;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('site-images','site-images',true,3145728,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
-- No storage write policies for anon/authenticated: uploads go through the admin-only API.
commit;
