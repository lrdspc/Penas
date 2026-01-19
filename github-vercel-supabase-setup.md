# 🚀 CONFIGURAÇÃO DEFINITIVA: GITHUB + VERCEL + SUPABASE

> **Guia Profissional Completo | Atualizado para 2025**  
> Stack: Next.js 15.1 + Supabase + Vercel + TypeScript + PWA

---

## 📋 ÍNDICE

- [1. Visão Geral da Arquitetura](#1-visão-geral-da-arquitetura)
- [2. Estrutura do Repositório GitHub](#2-estrutura-do-repositório-github)
- [3. Configuração Supabase](#3-configuração-supabase)
- [4. Integração Next.js + Supabase](#4-integração-nextjs--supabase)
- [5. Deploy Vercel](#5-deploy-vercel)
- [6. Gestão de Secrets](#6-gestão-de-secrets-e-variáveis)
- [7. CI/CD e Automação](#7-cicd-e-automação)
- [8. Segurança e RLS](#8-segurança-e-row-level-security)
- [9. Monitoring](#9-monitoring-e-performance)
- [10. Troubleshooting](#10-troubleshooting-comum)

---

## 1. VISÃO GERAL DA ARQUITETURA

```
┌─────────────────────────────────────────────────────────┐
│                    GITHUB REPOSITORY                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │  main (production) ──→ Auto deploy to Vercel     │  │
│  │  develop (staging)  ──→ Preview deployment        │  │
│  │  feature/* ─────────→ PR previews                 │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↓
              ┌──────────────────────┐
              │   VERCEL PLATFORM    │
              │  • Edge Functions    │
              │  • Global CDN        │
              │  • Auto HTTPS        │
              │  • Preview URLs      │
              └──────────────────────┘
                         ↓
              ┌──────────────────────┐
              │   SUPABASE CLOUD     │
              │  • PostgreSQL 14+    │
              │  • Auth (JWT)        │
              │  • Realtime          │
              │  • Storage           │
              │  • Edge Functions    │
              └──────────────────────┘
```

### 🎯 Fluxo de Deploy

1. **Developer** → Push code to GitHub
2. **GitHub** → Trigger webhook to Vercel
3. **Vercel** → Build Next.js app + Deploy to Edge
4. **App** → Connect to Supabase via environment variables
5. **Users** → Access via HTTPS (automatic SSL)

---

## 2. ESTRUTURA DO REPOSITÓRIO GITHUB

### 📁 Estrutura Completa do Projeto

```
projeto-treinos-pwa/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # Testes e linting
│   │   ├── preview.yml               # Deploy preview
│   │   └── production.yml            # Deploy production
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
│
├── app/                              # Next.js 15 App Router
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── signup/page.tsx
│   │   └── invite/[token]/page.tsx
│   ├── (student)/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── workout/
│   │       └── [id]/play/page.tsx
│   ├── (trainer)/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── students/page.tsx
│   ├── api/
│   │   ├── auth/[...nextauth]/route.ts
│   │   └── webhooks/route.ts
│   ├── layout.tsx
│   ├── globals.css
│   └── not-found.tsx
│
├── components/
│   ├── client/
│   │   ├── WorkoutPlayer.tsx
│   │   ├── Timer.tsx
│   │   └── HapticButton.tsx
│   └── server/
│       ├── StudentsList.tsx
│       └── WorkoutsList.tsx
│
├── lib/
│   ├── supabase/
│   │   ├── client.ts              # Browser client
│   │   ├── server.ts              # Server client
│   │   ├── middleware.ts          # Middleware client
│   │   └── queries/
│   │       ├── workouts.ts
│   │       └── students.ts
│   ├── workers/
│   │   └── timer.worker.ts
│   ├── utils.ts
│   └── constants.ts
│
├── hooks/
│   ├── useWakeLock.ts
│   ├── useHaptic.ts
│   └── useAuth.ts
│
├── types/
│   ├── database.ts                # Supabase generated types
│   └── index.ts
│
├── public/
│   ├── manifest.json
│   ├── service-worker.js
│   └── icons/
│
├── supabase/
│   ├── migrations/
│   │   ├── 20250101000000_initial_schema.sql
│   │   ├── 20250102000000_add_rls_policies.sql
│   │   └── 20250103000000_add_indexes.sql
│   ├── seed.sql
│   ├── config.toml
│   └── .gitignore
│
├── .env.example                   # Template de variáveis
├── .env.local                     # Variáveis locais (gitignored)
├── .gitignore
├── .eslintrc.json
├── .prettierrc
├── next.config.ts
├── tsconfig.json
├── tailwind.config.ts
├── package.json
├── pnpm-lock.yaml
└── README.md
```

### 🔐 Arquivo `.gitignore` Essencial

```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Production
/build
/.next/
/out/
.vercel

# Environment Variables
.env
.env.local
.env*.local
!.env.example

# Supabase
.branches
.temp

# Debugging
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# PWA
public/sw.js
public/workbox-*.js

# Testing
coverage/
.nyc_output

# Misc
*.pem
.cache
```

### 📝 `.env.example` Template

```bash
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application
NEXT_PUBLIC_APP_URL=http://localhost:3000
NODE_ENV=development

# PWA Push Notifications
NEXT_PUBLIC_VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=your-vapid-private-key

# Vercel Analytics (auto-injected in production)
# VERCEL_URL is automatically available
# VERCEL_ENV is automatically available
```

---

## 3. CONFIGURAÇÃO SUPABASE

### 🎯 Setup Inicial do Projeto Supabase

#### Passo 1: Criar Projeto no Supabase

1. Acesse [https://supabase.com](https://supabase.com)
2. Clique em **"New Project"**
3. Configurações recomendadas:
   - **Name:** `treinos-pwa-production`
   - **Database Password:** Gerado automaticamente (SALVE!)
   - **Region:** Escolha mais próximo dos usuários (ex: South America - São Paulo)
   - **Pricing Plan:** Free tier para MVP, Pro para produção

#### Passo 2: Executar Migrations

##### Migration 1: Schema Inicial (`20250101000000_initial_schema.sql`)

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  user_type TEXT CHECK (user_type IN ('trainer', 'student')) NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  profile_photo_url TEXT,
  status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Trainer-Student relationship
CREATE TABLE trainer_students (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  invite_token TEXT UNIQUE NOT NULL,
  invite_expires_at TIMESTAMPTZ NOT NULL,
  invited_at TIMESTAMPTZ DEFAULT now(),
  accepted_at TIMESTAMPTZ,
  status TEXT CHECK (status IN ('pending', 'active', 'inactive')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(trainer_id, student_id)
);

-- Exercises library
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  muscle_groups TEXT[], -- Array: ['peito', 'triceps']
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  video_url TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Workouts
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  is_template BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Workout exercises (junction table)
CREATE TABLE workout_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES exercises(id) NOT NULL,
  order_num INT NOT NULL,
  sets INT NOT NULL,
  reps INT NOT NULL,
  rest_seconds INT DEFAULT 60,
  weight_kg DECIMAL(6,2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Student assigned workouts
CREATE TABLE student_workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  workout_id UUID REFERENCES workouts(id) NOT NULL,
  assigned_date DATE NOT NULL,
  completed_date TIMESTAMPTZ,
  status TEXT CHECK (status IN ('pending', 'in_progress', 'completed', 'abandoned')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Workout sessions (execution history)
CREATE TABLE workout_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  student_workout_id UUID REFERENCES student_workouts(id),
  started_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ,
  total_duration_seconds INT,
  status TEXT CHECK (status IN ('in_progress', 'completed', 'abandoned')) DEFAULT 'in_progress',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Session exercises (detailed execution)
CREATE TABLE session_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_session_id UUID REFERENCES workout_sessions(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES exercises(id),
  order_num INT NOT NULL,
  sets_completed INT NOT NULL,
  reps_per_set INT[], -- Array: [10, 10, 9, 10]
  weight_kg DECIMAL(6,2),
  notes TEXT,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Assessments (physical evaluations)
CREATE TABLE assessments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  assessment_date DATE NOT NULL,
  height_cm DECIMAL(5,2),
  weight_kg DECIMAL(6,2),
  body_fat_percent DECIMAL(5,2),
  chest_cm DECIMAL(6,2),
  waist_cm DECIMAL(6,2),
  hip_cm DECIMAL(6,2),
  arm_cm DECIMAL(6,2),
  leg_cm DECIMAL(6,2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Push subscriptions
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  subscription JSONB NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, subscription)
);

-- Offline sync queue
CREATE TABLE offline_sync_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  action TEXT NOT NULL,
  table_name TEXT NOT NULL,
  record_id UUID,
  payload JSONB NOT NULL,
  status TEXT CHECK (status IN ('pending', 'synced', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ
);
```

##### Migration 2: Indexes e Performance (`20250102000000_add_indexes.sql`)

```sql
-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);

-- Trainer-Students
CREATE INDEX idx_trainer_students_trainer_id ON trainer_students(trainer_id);
CREATE INDEX idx_trainer_students_student_id ON trainer_students(student_id);
CREATE INDEX idx_trainer_students_invite_token ON trainer_students(invite_token);
CREATE INDEX idx_trainer_students_status ON trainer_students(status);

-- Exercises
CREATE INDEX idx_exercises_trainer_id ON exercises(trainer_id);
CREATE INDEX idx_exercises_muscle_groups ON exercises USING GIN(muscle_groups);

-- Workouts
CREATE INDEX idx_workouts_trainer_id ON workouts(trainer_id);
CREATE INDEX idx_workouts_is_template ON workouts(is_template);

-- Workout Exercises
CREATE INDEX idx_workout_exercises_workout_id ON workout_exercises(workout_id);
CREATE INDEX idx_workout_exercises_exercise_id ON workout_exercises(exercise_id);

-- Student Workouts
CREATE INDEX idx_student_workouts_student_id ON student_workouts(student_id);
CREATE INDEX idx_student_workouts_workout_id ON student_workouts(workout_id);
CREATE INDEX idx_student_workouts_assigned_date ON student_workouts(assigned_date);
CREATE INDEX idx_student_workouts_status ON student_workouts(status);

-- Workout Sessions
CREATE INDEX idx_workout_sessions_student_id ON workout_sessions(student_id);
CREATE INDEX idx_workout_sessions_student_workout_id ON workout_sessions(student_workout_id);
CREATE INDEX idx_workout_sessions_started_at ON workout_sessions(started_at);

-- Assessments
CREATE INDEX idx_assessments_trainer_id ON assessments(trainer_id);
CREATE INDEX idx_assessments_student_id ON assessments(student_id);
CREATE INDEX idx_assessments_date ON assessments(assessment_date);

-- Sync Queue
CREATE INDEX idx_sync_queue_user_id ON offline_sync_queue(user_id);
CREATE INDEX idx_sync_queue_status ON offline_sync_queue(status);
```

##### Migration 3: Row Level Security (`20250103000000_add_rls.sql`)

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE trainer_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE offline_sync_queue ENABLE ROW LEVEL SECURITY;

-- Users: Can view own profile
CREATE POLICY "Users can view own profile" 
  ON users FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
  ON users FOR UPDATE 
  USING (auth.uid() = id);

-- Trainer-Students: Trainers and students can view relationships
CREATE POLICY "Trainers manage their students" 
  ON trainer_students FOR ALL 
  USING (
    trainer_id = auth.uid() OR 
    student_id = auth.uid()
  );

-- Exercises: Trainers manage their library
CREATE POLICY "Trainers manage exercises" 
  ON exercises FOR ALL 
  USING (trainer_id = auth.uid());

-- Students can view exercises from their trainers
CREATE POLICY "Students view trainer exercises" 
  ON exercises FOR SELECT 
  USING (
    trainer_id IN (
      SELECT trainer_id 
      FROM trainer_students 
      WHERE student_id = auth.uid() 
      AND status = 'active'
    )
  );

-- Workouts: Trainers manage workouts
CREATE POLICY "Trainers manage workouts" 
  ON workouts FOR ALL 
  USING (trainer_id = auth.uid());

-- Students view assigned workouts
CREATE POLICY "Students view assigned workouts" 
  ON workouts FOR SELECT 
  USING (
    id IN (
      SELECT workout_id 
      FROM student_workouts 
      WHERE student_id = auth.uid()
    )
  );

-- Workout Exercises: Access via workout
CREATE POLICY "Access workout exercises via workout" 
  ON workout_exercises FOR SELECT 
  USING (
    workout_id IN (
      SELECT id FROM workouts 
      WHERE trainer_id = auth.uid()
    ) OR
    workout_id IN (
      SELECT workout_id 
      FROM student_workouts 
      WHERE student_id = auth.uid()
    )
  );

-- Student Workouts: Students and trainers access
CREATE POLICY "Students view own workouts" 
  ON student_workouts FOR SELECT 
  USING (
    student_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM trainer_students 
      WHERE trainer_id = auth.uid() 
      AND student_id = student_workouts.student_id
    )
  );

CREATE POLICY "Students update own workouts" 
  ON student_workouts FOR UPDATE 
  USING (student_id = auth.uid());

-- Workout Sessions: Students manage sessions
CREATE POLICY "Students manage sessions" 
  ON workout_sessions FOR ALL 
  USING (student_id = auth.uid());

CREATE POLICY "Trainers view student sessions" 
  ON workout_sessions FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM trainer_students 
      WHERE trainer_id = auth.uid() 
      AND student_id = workout_sessions.student_id
      AND status = 'active'
    )
  );

-- Session Exercises: Access via session
CREATE POLICY "Access session exercises" 
  ON session_exercises FOR ALL 
  USING (
    workout_session_id IN (
      SELECT id FROM workout_sessions 
      WHERE student_id = auth.uid()
    )
  );

-- Assessments: Trainers and students access
CREATE POLICY "Assessments access" 
  ON assessments FOR ALL 
  USING (
    trainer_id = auth.uid() OR 
    student_id = auth.uid()
  );

-- Push Subscriptions: Users manage own
CREATE POLICY "Users manage push subscriptions" 
  ON push_subscriptions FOR ALL 
  USING (user_id = auth.uid());

-- Sync Queue: Users manage own queue
CREATE POLICY "Users manage sync queue" 
  ON offline_sync_queue FOR ALL 
  USING (user_id = auth.uid());
```

#### Passo 3: Configurar Authentication

1. Acesse **Authentication → Providers**
2. Ative os providers desejados:
   - ✅ Email/Password (obrigatório)
   - ✅ Google (recomendado)
   - ✅ Apple (para iOS)

3. **Email Templates** (customizar em Authentication → Email Templates):

```html
<!-- Confirm Signup -->
<h2>Bem-vindo ao Treinos PT!</h2>
<p>Clique no link abaixo para confirmar seu email:</p>
<p><a href="{{ .ConfirmationURL }}">Confirmar Email</a></p>
```

#### Passo 4: Gerar TypeScript Types

```bash
# Instalar Supabase CLI
npm install -g supabase

# Login
supabase login

# Link projeto
supabase link --project-ref your-project-ref

# Gerar types
supabase gen types typescript --project-id your-project-id > types/database.ts
```

---

## 4. INTEGRAÇÃO NEXT.JS + SUPABASE

### 📦 Instalação de Dependências

```bash
pnpm add @supabase/supabase-js @supabase/ssr
pnpm add -D @supabase/supabase-js@latest
```

### 🔧 Configuração dos Clientes Supabase

#### `lib/supabase/client.ts` (Browser Client)

```typescript
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

#### `lib/supabase/server.ts` (Server Client)

```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/types/database'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value, ...options })
          } catch (error) {
            // Server Component - can't set cookies
          }
        },
        remove(name: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value: '', ...options })
          } catch (error) {
            // Server Component - can't remove cookies
          }
        },
      },
    }
  )
}
```

#### `lib/supabase/middleware.ts` (Middleware Client)

```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import type { Database } from '@/types/database'

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({
            name,
            value,
            ...options,
          })
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          })
          response.cookies.set({
            name,
            value,
            ...options,
          })
        },
        remove(name: string, options: CookieOptions) {
          request.cookies.set({
            name,
            value: '',
            ...options,
          })
          response = NextResponse.next({
            request: {
              headers: request.headers,
            },
          })
          response.cookies.set({
            name,
            value: '',
            ...options,
          })
        },
      },
    }
  )

  // Refresh session
  const { data: { user } } = await supabase.auth.getUser()

  // Protect routes
  if (!user && !request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return response
}
```

#### `middleware.ts` (Root)

```typescript
import { updateSession } from '@/lib/supabase/middleware'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  return await updateSession(request)
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

---

## 5. DEPLOY VERCEL

### 🚀 Setup Inicial

#### Opção 1: Via Dashboard Vercel (Recomendado)

1. Acesse [vercel.com](https://vercel.com)
2. Clique **"New Project"**
3. Conecte GitHub → Selecione repositório
4. **Framework Preset:** Next.js (auto-detectado)
5. **Root Directory:** `./` (se não for monorepo)
6. **Build Command:** `pnpm build` (ou deixe padrão)
7. **Output Directory:** `.next` (padrão)
8. **Install Command:** `pnpm install` (ou auto)

#### Opção 2: Via Vercel CLI

```bash
# Instalar CLI
pnpm add -g vercel

# Login
vercel login

# Deploy
vercel

# Deploy para produção
vercel --prod
```

### ⚙️ Configuração `vercel.json` (Opcional)

```json
{
  "buildCommand": "pnpm build",
  "devCommand": "pnpm dev",
  "installCommand": "pnpm install",
  "framework": "nextjs",
  "regions": ["gru1"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Referrer-Policy",
          "value": "origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "camera=(), microphone=(), geolocation=()"
        }
      ]
    },
    {
      "source": "/service-worker.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=0, must-revalidate"
        }
      ]
    }
  ],
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "/api/:path*"
    }
  ]
}
```

---

## 6. GESTÃO DE SECRETS E VARIÁVEIS

### 🔐 Hierarquia de Environments

```
Development (local)     → .env.local
Preview (PR deploys)    → Vercel Preview Env Vars
Production (main)       → Vercel Production Env Vars
```

### 📝 Configurar no Vercel Dashboard

1. Projeto → **Settings** → **Environment Variables**

2. Adicionar variáveis:

| Key | Value | Environment |
|-----|-------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://xxx.supabase.co` | Production, Preview, Development |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbG...` | Production, Preview, Development |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbG...` | Production, Preview |
| `NEXT_PUBLIC_APP_URL` | `https://treinos.app` | Production |
| `NEXT_PUBLIC_APP_URL` | `https://staging.treinos.app` | Preview |

### 🛡️ Boas Práticas

✅ **FAÇA:**
- Use `NEXT_PUBLIC_` para variáveis que devem ser expostas ao browser
- Armazene secrets sensíveis APENAS no servidor (sem `NEXT_PUBLIC_`)
- Use diferentes valores para Preview vs Production
- Rotacione secrets regularmente

❌ **NÃO FAÇA:**
- Nunca commite `.env.local` no Git
- Nunca use `NEXT_PUBLIC_` para API keys privadas
- Nunca hardcode secrets no código

### 🔄 Rotação de Secrets

```bash
# 1. Gerar novo service role key no Supabase
# 2. Atualizar no Vercel
vercel env add SUPABASE_SERVICE_ROLE_KEY production

# 3. Re-deploy
vercel --prod
```

---

## 7. CI/CD E AUTOMAÇÃO

### 🤖 GitHub Actions Workflow

#### `.github/workflows/ci.yml`

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm lint

      - name: Type check
        run: pnpm type-check

      - name: Build
        run: pnpm build
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}

      - name: Run tests (optional)
        run: pnpm test
        if: false  # Desative se não tiver testes ainda
```

#### `.github/workflows/preview.yml`

```yaml
name: Preview Deployment

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  deploy-preview:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Deploy to Vercel Preview
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          scope: ${{ secrets.VERCEL_ORG_ID }}
```

#### `.github/workflows/production.yml`

```yaml
name: Production Deployment

on:
  push:
    branches:
      - main

jobs:
  deploy-production:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Deploy to Vercel Production
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
          scope: ${{ secrets.VERCEL_ORG_ID }}
```

### 🔑 Configurar Secrets no GitHub

1. Repository → **Settings** → **Secrets and variables** → **Actions**
2. Clique **"New repository secret"**

Adicione:
- `VERCEL_TOKEN` → Gere em vercel.com/account/tokens
- `VERCEL_ORG_ID` → Encontre em .vercel/project.json após primeiro deploy
- `VERCEL_PROJECT_ID` → Encontre em .vercel/project.json
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

---

## 8. SEGURANÇA E ROW LEVEL SECURITY

### 🛡️ Checklist de Segurança

#### Backend (Supabase)

✅ **RLS Ativado em Todas as Tabelas**
```sql
-- Verificar RLS ativo
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

✅ **Políticas Granulares**
```sql
-- Exemplo: Estudante só vê seus próprios treinos
CREATE POLICY "Students view own workouts" 
  ON student_workouts FOR SELECT 
  USING (student_id = auth.uid());
```

✅ **Service Role Key NUNCA no Frontend**
```typescript
// ❌ ERRADO
const supabase = createClient(url, SERVICE_ROLE_KEY) 

// ✅ CORRETO
const supabase = createClient(url, ANON_KEY)
```

✅ **Validação de Entrada**
```typescript
// Usar Zod para validar dados
import { z } from 'zod'

const WorkoutSchema = z.object({
  name: z.string().min(3).max(100),
  description: z.string().max(500).optional(),
})

export async function createWorkout(data: unknown) {
  const validated = WorkoutSchema.parse(data)
  // Prosseguir com dados validados
}
```

#### Frontend (Next.js)

✅ **CSRF Protection (Next.js built-in)**
```typescript
// Next.js automaticamente adiciona CSRF token em forms
```

✅ **Content Security Policy**
```typescript
// next.config.ts
const nextConfig = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "script-src 'self' 'unsafe-eval' 'unsafe-inline' https://vercel.live",
              "style-src 'self' 'unsafe-inline'",
              "img-src 'self' data: https:",
              "font-src 'self' data:",
              "connect-src 'self' https://*.supabase.co wss://*.supabase.co",
              "frame-ancestors 'none'",
            ].join('; '),
          },
        ],
      },
    ]
  },
}
```

✅ **XSS Prevention**
```typescript
// React escapa automaticamente, mas cuidado com dangerouslySetInnerHTML
// Use sanitização quando necessário
import DOMPurify from 'isomorphic-dompurify'

const SafeHTML = ({ html }: { html: string }) => (
  <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
)
```

### 🔐 Auth Flow Seguro

#### Login/Signup
```typescript
// app/(auth)/login/page.tsx
'use client'

import { createClient } from '@/lib/supabase/client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const router = useRouter()
  const supabase = createClient()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    const { data, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (authError) {
      setError(authError.message)
      return
    }

    // Buscar tipo de usuário
    const { data: userData } = await supabase
      .from('users')
      .select('user_type')
      .eq('id', data.user.id)
      .single()

    // Redirect baseado no tipo
    if (userData?.user_type === 'trainer') {
      router.push('/trainer')
    } else {
      router.push('/student')
    }
  }

  return (
    <form onSubmit={handleLogin}>
      {error && <div className="text-red-500">{error}</div>}
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
      />
      <button type="submit">Login</button>
    </form>
  )
}
```

#### Protected Routes
```typescript
// app/(student)/layout.tsx
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function StudentLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = await createClient()
  
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    redirect('/login')
  }

  // Verificar se é estudante
  const { data: userData } = await supabase
    .from('users')
    .select('user_type')
    .eq('id', user.id)
    .single()

  if (userData?.user_type !== 'student') {
    redirect('/login')
  }

  return <>{children}</>
}
```

### 🔒 Rate Limiting

#### Via Vercel Edge Config (Recomendado)
```typescript
// middleware.ts
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'), // 10 requests per 10 seconds
})

export async function middleware(request: NextRequest) {
  // Rate limit API routes
  if (request.nextUrl.pathname.startsWith('/api')) {
    const ip = request.ip ?? '127.0.0.1'
    const { success } = await ratelimit.limit(ip)

    if (!success) {
      return new Response('Too Many Requests', { status: 429 })
    }
  }

  return await updateSession(request)
}
```

---

## 9. MONITORING E PERFORMANCE

### 📊 Vercel Analytics

#### Ativar no Dashboard
1. Projeto → **Analytics**
2. Ative **Web Analytics** (gratuito)
3. Ative **Speed Insights** (gratuito)

#### Implementar no Código
```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react'
import { SpeedInsights } from '@vercel/speed-insights/next'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  )
}
```

### 🎯 Performance Targets

| Métrica | Target | Como Medir |
|---------|--------|------------|
| **Lighthouse Performance** | >90 | Chrome DevTools |
| **First Contentful Paint** | <1.8s | Vercel Speed Insights |
| **Largest Contentful Paint** | <2.5s | Vercel Speed Insights |
| **Time to Interactive** | <3.8s | Lighthouse |
| **Cumulative Layout Shift** | <0.1 | Lighthouse |

### 🔍 Monitoring Supabase

#### Dashboard Supabase
1. **Database** → **Query Performance**
   - Identifique queries lentas
   - Adicione índices se necessário

2. **API** → **Logs**
   - Monitore erros de RLS
   - Identifique padrões de uso

#### Custom Monitoring (Opcional)
```typescript
// lib/monitoring.ts
export async function logError(error: Error, context?: any) {
  if (process.env.NODE_ENV === 'production') {
    // Enviar para serviço de monitoring (Sentry, etc)
    console.error('Production Error:', error, context)
  } else {
    console.error('Dev Error:', error, context)
  }
}

export async function logPerformance(metric: string, value: number) {
  if (process.env.NODE_ENV === 'production') {
    // Enviar para analytics
    console.log(`Performance: ${metric} = ${value}ms`)
  }
}
```

### ⚡ Otimizações Críticas

#### 1. Image Optimization
```typescript
import Image from 'next/image'

// ✅ CORRETO
<Image
  src="/profile.jpg"
  alt="Profile"
  width={200}
  height={200}
  priority // Para imagens above-the-fold
/>

// ❌ EVITE
<img src="/profile.jpg" alt="Profile" />
```

#### 2. Lazy Loading Components
```typescript
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/AssessmentChart'), {
  loading: () => <p>Carregando...</p>,
  ssr: false, // Desative SSR se não precisar
})
```

#### 3. Database Query Optimization
```typescript
// ❌ N+1 Query Problem
const students = await supabase.from('users').select('*')
for (const student of students) {
  const workouts = await supabase
    .from('student_workouts')
    .select('*')
    .eq('student_id', student.id)
}

// ✅ Single Query with Join
const students = await supabase
  .from('users')
  .select(`
    *,
    student_workouts (*)
  `)
  .eq('user_type', 'student')
```

#### 4. React Query Caching
```typescript
// app/providers.tsx
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useState } from 'react'

export default function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minuto
        cacheTime: 5 * 60 * 1000, // 5 minutos
        refetchOnWindowFocus: false,
      },
    },
  }))

  return (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  )
}
```

---

## 10. TROUBLESHOOTING COMUM

### 🐛 Problemas Frequentes e Soluções

#### 1. "Error: Could not resolve supabase client"

**Causa:** Cliente não inicializado corretamente

**Solução:**
```typescript
// Verifique se as variáveis estão definidas
console.log(process.env.NEXT_PUBLIC_SUPABASE_URL)
console.log(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)

// Adicione validação
if (!process.env.NEXT_PUBLIC_SUPABASE_URL) {
  throw new Error('Missing NEXT_PUBLIC_SUPABASE_URL')
}
```

#### 2. "RLS Policy Violation"

**Causa:** Política de segurança bloqueando acesso

**Solução:**
```sql
-- Teste query diretamente no SQL Editor do Supabase
SET request.jwt.claim.sub = 'user-uuid-here';

SELECT * FROM workouts WHERE trainer_id = 'user-uuid-here';

-- Se funcionar, problema está no código. Se não, problema na política.
```

#### 3. "Cookies not working in middleware"

**Causa:** Middleware rodando em Edge Runtime

**Solução:**
```typescript
// Sempre use o padrão de middleware do Supabase SSR
import { updateSession } from '@/lib/supabase/middleware'

export async function middleware(request: NextRequest) {
  return await updateSession(request) // Retorna NextResponse
}
```

#### 4. "Build failing on Vercel"

**Causa:** Variáveis de ambiente faltando

**Solução:**
1. Vercel Dashboard → Settings → Environment Variables
2. Adicione todas as variáveis `NEXT_PUBLIC_*`
3. Re-deploy

#### 5. "Service Worker not updating"

**Causa:** Cache agressivo do browser

**Solução:**
```javascript
// public/service-worker.js
self.addEventListener('install', (event) => {
  self.skipWaiting() // Força update imediato
})

self.addEventListener('activate', (event) => {
  event.waitUntil(clients.claim()) // Assume controle imediatamente
})
```

#### 6. "CORS error from Supabase"

**Causa:** Domínio não autorizado

**Solução:**
1. Supabase Dashboard → **Settings** → **API**
2. **Site URL:** `https://seu-dominio.vercel.app`
3. **Redirect URLs:** Adicione todas as URLs permitidas

#### 7. "Too many connections to database"

**Causa:** Conexões não sendo fechadas

**Solução:**
```typescript
// Use Supabase client singleton
// NÃO crie novo client a cada request

// ✅ CORRETO
import { createClient } from '@/lib/supabase/client'
const supabase = createClient() // Reutiliza conexão

// ❌ ERRADO
const supabase = createBrowserClient(url, key) // Nova conexão
```

---

## 📚 RECURSOS ADICIONAIS

### 🔗 Links Oficiais

- [Next.js Documentation](https://nextjs.org/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Vercel Documentation](https://vercel.com/docs)
- [Supabase + Next.js Guide](https://supabase.com/docs/guides/auth/server-side/nextjs)

### 🎓 Cursos e Tutoriais

- [Supabase Auth Deep Dive](https://supabase.com/docs/guides/auth)
- [Next.js App Router Course](https://nextjs.org/learn)
- [PWA with Next.js](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)

### 🛠️ Ferramentas Úteis

- **Supabase CLI:** `npm install -g supabase`
- **Vercel CLI:** `npm install -g vercel`
- **Database Management:** [TablePlus](https://tableplus.com/)
- **API Testing:** [Postman](https://www.postman.com/) ou [Insomnia](https://insomnia.rest/)

---

## ✅ CHECKLIST DE DEPLOY

### Pré-Deploy

- [ ] Todas as migrations executadas no Supabase
- [ ] RLS policies testadas
- [ ] Environment variables configuradas no Vercel
- [ ] Build local funcionando (`pnpm build`)
- [ ] Tests passando (se tiver)
- [ ] Lighthouse score >85
- [ ] PWA manifest validado

### Deploy

- [ ] Push para `main` branch
- [ ] Vercel deploy automático trigado
- [ ] Build bem-sucedido no Vercel
- [ ] Environment variables injetadas corretamente
- [ ] DNS configurado (se domínio customizado)
- [ ] SSL ativo (Vercel automático)

### Pós-Deploy

- [ ] Testar autenticação (login/signup)
- [ ] Testar criação de dados
- [ ] Testar PWA install
- [ ] Testar offline mode
- [ ] Verificar Vercel Analytics funcionando
- [ ] Configurar alertas de erro
- [ ] Documentar credenciais de acesso

---

## 🎯 PRÓXIMOS PASSOS

1. **Monitoramento Avançado**
   - Integrar Sentry para error tracking
   - Configurar Uptime monitoring (UptimeRobot)

2. **Performance**
   - Implementar Edge Caching
   - Otimizar bundle size (bundle analyzer)

3. **Segurança**
   - Implementar 2FA (Supabase Auth)
   - Adicionar rate limiting avançado

4. **Escalabilidade**
   - Configurar Read Replicas (Supabase Pro)
   - Implementar Database Backups automáticos

---

## 📞 SUPORTE

### Problemas não resolvidos?

1. **GitHub Issues:** Crie issue detalhada no repositório
2. **Supabase Discord:** [discord.supabase.com](https://discord.supabase.com)
3. **Vercel Support:** support@vercel.com
4. **Stack Overflow:** Tag `next.js`, `supabase`, `vercel`

---

**Documento criado em:** Janeiro 2025  
**Última atualização:** 2025-01-19  
**Versão:** 1.0.0

---

*Este documento foi criado com base nas melhores práticas oficiais de Next.js 15, Supabase e Vercel, incluindo padrões da comunidade em 2025.*