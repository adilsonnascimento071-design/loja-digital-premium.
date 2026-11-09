-- Loja Digital Premium | Supabase
-- Execute no SQL Editor do projeto Supabase.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'customer' check (role in ('customer','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null default '',
  category text not null default 'Geral',
  price_usd numeric(10,2) not null check (price_usd >= 0),
  cover_url text,
  file_path text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  customer_name text not null,
  customer_email text not null,
  currency char(3) not null default 'USD' check (currency = 'USD'),
  subtotal_usd numeric(10,2) not null check (subtotal_usd >= 0),
  status text not null default 'pending' check (status in ('pending','paid','failed','refunded','cancelled')),
  payment_provider text,
  provider_reference text,
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  unit_price_usd numeric(10,2) not null check (unit_price_usd >= 0),
  quantity integer not null check (quantity > 0),
  unique(order_id, product_id)
);

create index if not exists orders_user_id_idx on public.orders(user_id);
create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists order_items_order_id_idx on public.order_items(order_id);
create index if not exists products_active_idx on public.products(is_active);

create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin');
$$;

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "Users read own profile" on public.profiles;
create policy "Users read own profile" on public.profiles for select to authenticated
using (id = auth.uid() or public.is_admin());
drop policy if exists "Admins manage profiles" on public.profiles;
create policy "Admins manage profiles" on public.profiles for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Public read active products" on public.products;
create policy "Public read active products" on public.products for select to anon, authenticated
using (is_active = true or public.is_admin());
drop policy if exists "Admins manage products" on public.products;
create policy "Admins manage products" on public.products for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Customers read own orders" on public.orders;
create policy "Customers read own orders" on public.orders for select to authenticated
using (user_id = auth.uid() or public.is_admin());
drop policy if exists "Admins manage orders" on public.orders;
create policy "Admins manage orders" on public.orders for all to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Customers read own order items" on public.order_items;
create policy "Customers read own order items" on public.order_items for select to authenticated
using (exists(select 1 from public.orders o where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));
drop policy if exists "Admins manage order items" on public.order_items;
create policy "Admins manage order items" on public.order_items for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- Cria automaticamente o perfil básico quando alguém se regista.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles(id, full_name)
  values(new.id, coalesce(new.raw_user_meta_data->>'full_name',''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Bucket privado: os ficheiros digitais nunca devem ser públicos.
insert into storage.buckets(id, name, public)
values ('digital-products','digital-products',false)
on conflict (id) do update set public = false;

drop policy if exists "Admins upload digital files" on storage.objects;
create policy "Admins upload digital files" on storage.objects for insert to authenticated
with check (bucket_id = 'digital-products' and public.is_admin());
drop policy if exists "Admins update digital files" on storage.objects;
create policy "Admins update digital files" on storage.objects for update to authenticated
using (bucket_id = 'digital-products' and public.is_admin())
with check (bucket_id = 'digital-products' and public.is_admin());
drop policy if exists "Admins delete digital files" on storage.objects;
create policy "Admins delete digital files" on storage.objects for delete to authenticated
using (bucket_id = 'digital-products' and public.is_admin());

-- Após criar a conta do proprietário, promover o respetivo utilizador a administrador:
-- update public.profiles set role = 'admin' where id = (select id from auth.users where email = 'O_TEU_EMAIL');
