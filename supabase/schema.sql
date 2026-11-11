-- Run this once in Supabase: Dashboard > SQL Editor > New query > paste > Run.

-- ========== Admins ==========
create table if not exists public.admins (
  email text primary key
);
-- >>> Put the admin's login email here (same email you create under Authentication > Users)
insert into public.admins (email) values ('agent@example.com') on conflict do nothing;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where lower(email) = lower(auth.jwt() ->> 'email'));
$$;
grant execute on function public.is_admin() to anon, authenticated;

-- ========== Content tables ==========
create table if not exists public.profile (
  id uuid primary key default gen_random_uuid(),
  name text, designation text, profile_image text, about text, experience text, expertise text,
  phone text, whatsapp text, location text, hero_headline text, hero_text text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.policies (
  id uuid primary key default gen_random_uuid(),
  title text not null, short_description text, image_url text, brochure_url text, category text,
  is_published boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  title text not null, description text, icon text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null, testimonial text,
  is_published boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- ========== Row Level Security ==========
alter table public.admins       enable row level security;  -- no policies: not readable from the browser
alter table public.profile      enable row level security;
alter table public.policies     enable row level security;
alter table public.services     enable row level security;
alter table public.testimonials enable row level security;

-- Visitors see the profile and only published / active items. Admin sees and edits everything.
drop policy if exists "read profile" on public.profile;
create policy "read profile" on public.profile for select using (true);
drop policy if exists "read policies" on public.policies;
create policy "read policies" on public.policies for select using (is_published or public.is_admin());
drop policy if exists "read services" on public.services;
create policy "read services" on public.services for select using (is_active or public.is_admin());
drop policy if exists "read testimonials" on public.testimonials;
create policy "read testimonials" on public.testimonials for select using (is_published or public.is_admin());

do $$ declare t text; begin
  foreach t in array array['profile','policies','services','testimonials'] loop
    execute format('drop policy if exists "admin write" on public.%I', t);
    execute format('create policy "admin write" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

-- ========== File storage (photos, policy PDFs) ==========
insert into storage.buckets (id, name, public) values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists "media public read" on storage.objects;
create policy "media public read" on storage.objects for select using (bucket_id = 'media');
drop policy if exists "media admin insert" on storage.objects;
create policy "media admin insert" on storage.objects for insert to authenticated with check (bucket_id = 'media' and public.is_admin());
drop policy if exists "media admin update" on storage.objects;
create policy "media admin update" on storage.objects for update to authenticated using (bucket_id = 'media' and public.is_admin());
drop policy if exists "media admin delete" on storage.objects;
create policy "media admin delete" on storage.objects for delete to authenticated using (bucket_id = 'media' and public.is_admin());
