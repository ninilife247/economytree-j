-- 경제나무: 사용자별 학습 기록(진도 + 퀴즈 풀이) 저장 테이블
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 Run.

create table if not exists public.learning_progress (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb       not null default '{}'::jsonb,  -- { progress: {terms, weeks}, quiz: {answered, wrong} }
  updated_at timestamptz not null default now()
);

-- 본인 기록만 읽고 쓸 수 있게 한다 (anon 키가 공개돼도 안전한 이유)
alter table public.learning_progress enable row level security;

drop policy if exists "본인 기록 조회" on public.learning_progress;
drop policy if exists "본인 기록 생성" on public.learning_progress;
drop policy if exists "본인 기록 수정" on public.learning_progress;

create policy "본인 기록 조회" on public.learning_progress
  for select to authenticated using ((select auth.uid()) = user_id);

create policy "본인 기록 생성" on public.learning_progress
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "본인 기록 수정" on public.learning_progress
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
