create table if not exists public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 role text not null default 'user' check(role in('user','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.materials(
 id uuid primary key default gen_random_uuid(),
 title text not null, subject text not null, description text, url text,
 created_by uuid references public.profiles(id) on delete set null,
 created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
alter table public.materials enable row level security;
create or replace function public.is_admin() returns boolean language sql security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;
create policy "profiles own read" on public.profiles for select to authenticated using(id=auth.uid());
create policy "profiles admin update" on public.profiles for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "materials read" on public.materials for select to authenticated using(true);
create policy "materials admin insert" on public.materials for insert to authenticated with check(public.is_admin());
create policy "materials admin delete" on public.materials for delete to authenticated using(public.is_admin());

-- Birinchi adminni Auth orqali yaratgach, uning UUID sini quyidagiga qo‘ying:
-- insert into public.profiles(id,full_name,role) values('USER-UUID','Rahbar','admin');