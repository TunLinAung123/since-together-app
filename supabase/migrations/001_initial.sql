-- =============================================
-- Together App — Full Database Migration
-- =============================================

-- =============================================
-- 1. PROFILES
-- =============================================
create table profiles (
  id uuid references auth.users(id) primary key,
  display_name text,
  avatar_url text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Users can view own profile"
  on profiles for select
  using (
    auth.uid() = id
    or exists (
      select 1 from couples
      where (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
      and (couples.user1_id = profiles.id or couples.user2_id = profiles.id)
    )
  );

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

create policy "Service can insert profiles"
  on profiles for insert
  with check (true);

-- =============================================
-- 2. COUPLES
-- =============================================
create table couples (
  id uuid default gen_random_uuid() primary key,
  user1_id uuid references profiles(id),
  user2_id uuid references profiles(id),
  invite_code text unique default lower(substring(md5(random()::text), 1, 8)),
  anniversary_date date,
  created_at timestamptz default now()
);

alter table couples enable row level security;

create policy "Users can select own couple"
  on couples for select
  using (
    auth.uid() = user1_id
    or auth.uid() = user2_id
    or user2_id is null
  );

create policy "Users can insert couple"
  on couples for insert
  with check (auth.uid() = user1_id);

create policy "Users can update couple"
  on couples for update
  using (
    auth.uid() = user1_id
    or auth.uid() = user2_id
  )
  with check (true);

-- =============================================
-- 3. MESSAGES
-- =============================================
create table messages (
  id uuid default gen_random_uuid() primary key,
  couple_id uuid references couples(id) on delete cascade,
  sender_id uuid references profiles(id),
  content text not null,
  created_at timestamptz default now()
);

alter table messages enable row level security;

create policy "Couple members can read messages"
  on messages for select
  using (
    exists (
      select 1 from couples
      where couples.id = messages.couple_id
      and (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
    )
  );

create policy "Couple members can send messages"
  on messages for insert
  with check (
    sender_id = auth.uid() and
    exists (
      select 1 from couples
      where couples.id = messages.couple_id
      and (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
    )
  );

-- =============================================
-- 4. PHOTOS
-- =============================================
create table photos (
  id uuid default gen_random_uuid() primary key,
  couple_id uuid references couples(id) on delete cascade,
  uploaded_by uuid references profiles(id),
  storage_path text not null,
  caption text,
  taken_at date,
  created_at timestamptz default now()
);

alter table photos enable row level security;

create policy "Couple members can manage photos"
  on photos for all
  using (
    exists (
      select 1 from couples
      where couples.id = photos.couple_id
      and (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
    )
  );

-- =============================================
-- 5. EVENTS
-- =============================================
create table events (
  id uuid default gen_random_uuid() primary key,
  couple_id uuid references couples(id) on delete cascade,
  title text not null,
  description text,
  event_date date not null,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

alter table events enable row level security;

create policy "Couple members can manage events"
  on events for all
  using (
    exists (
      select 1 from couples
      where couples.id = events.couple_id
      and (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
    )
  );

-- =============================================
-- 6. GOALS
-- =============================================
create table goals (
  id uuid default gen_random_uuid() primary key,
  couple_id uuid references couples(id) on delete cascade,
  title text not null,
  is_completed boolean default false,
  completed_at timestamptz,
  created_by uuid references profiles(id),
  created_at timestamptz default now()
);

alter table goals enable row level security;

create policy "Couple members can manage goals"
  on goals for all
  using (
    exists (
      select 1 from couples
      where couples.id = goals.couple_id
      and (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
    )
  );

-- =============================================
-- 7. LOCATIONS
-- =============================================
create table locations (
  id uuid default gen_random_uuid() primary key,
  couple_id uuid references couples(id) on delete cascade,
  user_id uuid references profiles(id),
  latitude double precision not null,
  longitude double precision not null,
  updated_at timestamptz default now(),
  constraint locations_couple_user_unique unique (couple_id, user_id)
);

alter table locations enable row level security;

create policy "Couple members can manage locations"
  on locations for all
  using (
    exists (
      select 1 from couples
      where couples.id = locations.couple_id
      and (couples.user1_id = auth.uid() or couples.user2_id = auth.uid())
    )
  );

-- =============================================
-- 8. STORAGE POLICIES
-- =============================================
create policy "Couple members can upload photos"
  on storage.objects for insert
  with check (
    bucket_id = 'photos'
    and auth.role() = 'authenticated'
  );

create policy "Anyone can view photos"
  on storage.objects for select
  using (bucket_id = 'photos');

-- =============================================
-- 9. REALTIME
-- =============================================
alter publication supabase_realtime add table messages;
alter publication supabase_realtime add table events;
alter publication supabase_realtime add table goals;
alter publication supabase_realtime add table locations;

-- =============================================
-- 10. TRIGGER — Auto create profile on signup
-- =============================================
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', 'User')
  );
  return new;
exception
  when others then
    raise log 'Error in handle_new_user: %', sqlerrm;
    return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();