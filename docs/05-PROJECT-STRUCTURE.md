# 📁 Estrutura de Pastas - Next.js App Router

Este documento detalha a estrutura completa de pastas e arquivos do projeto seguindo o Next.js 15 App Router.

## 📂 Estrutura Completa

```bash
projeto-treinos-pwa/
│
├── .github/                           # Configuração GitHub
│   ├── workflows/
│   │   ├── ci.yml                    # Testes, linting e type checking
│   │   ├── preview.yml               # Deploy preview para PRs
│   │   └── production.yml            # Deploy produção para main
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
│
├── app/                               # Next.js App Router
│   ├── layout.tsx                    # Root layout com PWA setup
│   ├── globals.css                   # Tailwind + CSS vars globais
│   ├── not-found.tsx                 # Custom 404 page
│   ├── error.tsx                     # Error boundary global
│   ├── robots.txt                    # SEO robots.txt
│   ├── sitemap.ts                    # Dynamic sitemap
│   │
│   ├── (auth)/                       # Grupo sem layout de navegação
│   │   ├── layout.tsx                # Auth layout simples
│   │   ├── page.tsx                  # Redirect para login ou dashboard
│   │   ├── login/
│   │   │   ├── page.tsx              # Login para trainer/aluno
│   │   │   └── actions.ts            # Server actions para login
│   │   ├── trainer-signup/
│   │   │   ├── page.tsx              # Cadastro novo trainer
│   │   │   └── actions.ts
│   │   ├── student-signup/
│   │   │   ├── page.tsx              # Cadastro novo aluno
│   │   │   └── actions.ts
│   │   ├── invite/
│   │   │   └── [token]/
│   │   │       ├── page.tsx          # Aceitar convite (CRÍTICO)
│   │   │       └── actions.ts
│   │   └── forgot-password/
│   │       ├── page.tsx
│   │       └── actions.ts
│   │
│   ├── (student)/                    # Rotas aluno com layout
│   │   ├── layout.tsx                # Sidebar + Navigation student
│   │   ├── page.tsx                  # Dashboard aluno
│   │   ├── workout/
│   │   │   ├── page.tsx              # Lista treinos atribuídos
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx          # Detalhe treino (preview)
│   │   │   │   └── actions.ts
│   │   │   └── [id]/
│   │   │       └── play/
│   │   │           ├── page.tsx      # 🔴 CRÍTICO: Player treino
│   │   │           ├── actions.ts    # Server actions para gravação
│   │   │           └── components/   # Componentes específicos do player
│   │   ├── history/
│   │   │   ├── page.tsx              # Histórico treinos executados
│   │   │   └── [sessionId]/
│   │   │       └── page.tsx          # Detalhe sessão
│   │   ├── assessments/
│   │   │   ├── page.tsx              # Ver avaliações (gráficos)
│   │   │   └── [assessmentId]/
│   │   │       └── page.tsx          # Detalhe avaliação
│   │   ├── profile/
│   │   │   ├── page.tsx              # Perfil aluno
│   │   │   └── actions.ts
│   │   └── settings/
│   │       ├── page.tsx              # Preferências, notificações
│   │       └── actions.ts
│   │
│   ├── (trainer)/                    # Rotas trainer com layout
│   │   ├── layout.tsx                # Sidebar + Navigation trainer
│   │   ├── page.tsx                  # Dashboard trainer
│   │   ├── students/
│   │   │   ├── page.tsx              # Lista de alunos
│   │   │   ├── new/
│   │   │   │   ├── page.tsx          # Convidar novo aluno
│   │   │   │   └── actions.ts
│   │   │   └── [studentId]/
│   │   │       ├── page.tsx          # Perfil aluno
│   │   │       ├── workouts/
│   │   │       │   ├── page.tsx      # Treinos do aluno
│   │   │       │   └── actions.ts
│   │   │       └── assessments/
│   │   │           ├── new/
│   │   │           │   ├── page.tsx  # Nova avaliação
│   │   │           │   └── actions.ts
│   │   │           └── page.tsx      # Histórico avaliações
│   │   ├── exercises/
│   │   │   ├── page.tsx              # Biblioteca exercícios
│   │   │   ├── new/
│   │   │   │   ├── page.tsx          # Criar exercício
│   │   │   │   └── actions.ts
│   │   │   └── [exerciseId]/
│   │   │       └── edit/
│   │   │           ├── page.tsx
│   │   │           └── actions.ts
│   │   ├── workouts/
│   │   │   ├── page.tsx              # Lista treinos
│   │   │   ├── new/
│   │   │   │   ├── page.tsx          # Criar treino (CRÍTICO)
│   │   │   │   └── actions.ts
│   │   │   └── [workoutId]/
│   │   │       ├── page.tsx          # Detalhe treino
│   │   │       └── edit/
│   │   │           ├── page.tsx
│   │   │           └── actions.ts
│   │   ├── monitoring/
│   │   │   └── page.tsx              # Acompanhamento alunos em tempo real
│   │   ├── assessments/
│   │   │   └── page.tsx              # Histórico avaliações
│   │   ├── profile/
│   │   │   ├── page.tsx              # Perfil trainer
│   │   │   └── actions.ts
│   │   └── settings/
│   │       ├── page.tsx              # Configurações
│   │       └── actions.ts
│   │
│   └── api/                           # API Routes
│       ├── auth/
│       │   ├── login/route.ts
│       │   ├── signup/route.ts
│       │   ├── logout/route.ts
│       │   ├── verify-invite/[token]/route.ts
│       │   └── refresh-token/route.ts
│       ├── workouts/
│       │   ├── route.ts              # GET/POST workouts
│       │   └── [id]/route.ts         # GET/PUT/DELETE
│       ├── exercises/
│       │   ├── route.ts
│       │   └── [id]/route.ts
│       ├── students/
│       │   ├── route.ts
│       │   └── [id]/route.ts
│       ├── sessions/
│       │   ├── route.ts              # POST criar sessão
│       │   └── [id]/route.ts         # PUT atualizar sessão
│       ├── assessments/
│       │   ├── route.ts
│       │   └── [id]/route.ts
│       ├── sync/
│       │   └── route.ts              # Background Sync endpoint
│       ├── notifications/
│       │   ├── subscribe/route.ts   # Subscribe push
│       │   └── send/route.ts        # Send notification (trainer only)
│       └── webhooks/
│           └── supabase/route.ts    # Supabase webhooks
│
├── components/                        # Componentes React
│   ├── client/                        # Client Components (use client)
│   │   ├── WorkoutPlayer.tsx         # 🔴 CRÍTICO: Componente principal
│   │   ├── Timer.tsx                 # Timer com Web Workers
│   │   ├── ExerciseCard.tsx          # Card exercício
│   │   ├── ExerciseDragList.tsx      # Drag-drop para criar treino
│   │   ├── HapticButton.tsx          # Botão com feedback
│   │   ├── AssessmentChart.tsx       # Gráficos de progresso
│   │   ├── PWAInstallPrompt.tsx      # Prompt instalar PWA
│   │   ├── OfflineIndicator.tsx      # Indicador modo offline
│   │   ├── NotificationBell.tsx      # Ícone notificações
│   │   ├── Modal.tsx                 # Modal reutilizável
│   │   ├── Avatar.tsx                # Avatar com fallback
│   │   └── Form/
│   │       ├── CreateExerciseForm.tsx
│   │       ├── CreateWorkoutForm.tsx
│   │       ├── CreateAssessmentForm.tsx
│   │       └── InviteStudentForm.tsx
│   │
│   ├── server/                        # Server Components
│   │   ├── StudentsList.tsx          # Server component
│   │   ├── WorkoutsList.tsx
│   │   ├── AssessmentsList.tsx
│   │   ├── SessionHistoryList.tsx
│   │   ├── DashboardStats.tsx        # Stats cards para dashboards
│   │   └── RealtimePresence.tsx      # Indicador de presença online
│   │
│   └── shared/                        # Componentes compartilhados
│       ├── Navigation.tsx            # Navegação superior
│       ├── Sidebar.tsx               # Sidebar para layouts
│       ├── Header.tsx                # Header com search e notificações
│       ├── Footer.tsx                # Footer simples
│       ├── Loading.tsx               # Skeleton loaders
│       ├── ErrorBoundary.tsx         # Error boundary reutilizável
│       ├── ProtectedRoute.tsx        # Proteção de rotas
│       ├── ThemeToggle.tsx           # Toggle tema claro/escuro
│       └── LanguageSwitcher.tsx      # Switcher idioma
│
├── hooks/                             # React Hooks customizados
│   ├── useWakeLock.ts                # 🔴 CRÍTICO
│   ├── useTimerWorker.ts             # 🔴 CRÍTICO
│   ├── useHaptic.ts                  # 🔴 CRÍTICO
│   ├── useBackgroundSync.ts          # 🔴 CRÍTICO
│   ├── useOfflineStorage.ts          # 🔴 CRÍTICO
│   ├── useSupabaseRealtime.ts        # Realtime subscriptions
│   ├── usePWAInstall.ts              # Install PWA prompt
│   ├── useNotifications.ts           # Push notifications
│   ├── useAuth.ts                    # Autenticação context
│   ├── useWorkout.ts                 # Lógica de treinos
│   ├── useAssessments.ts             # Lógica de avaliações
│   ├── usePresence.ts                # Presence tracking
│   └── useTheme.ts                   # Tema claro/escuro
│
├── lib/                               # Bibliotecas e utilitários
│   ├── supabase/
│   │   ├── client.ts                 # Supabase client (browser)
│   │   ├── server.ts                 # Supabase server (SSR)
│   │   ├── middleware.ts             # Middleware auth
│   │   └── queries/
│   │       ├── workouts.ts
│   │       ├── exercises.ts
│   │       ├── students.ts
│   │       ├── sessions.ts
│   │       └── assessments.ts
│   ├── workers/
│   │   ├── timer.worker.ts           # 🔴 CRÍTICO: Web Worker timer
│   │   └── sync.worker.ts            # Background sync worker
│   ├── indexeddb/
│   │   ├── database.ts               # 🔴 CRÍTICO: Offline storage
│   │   ├── sessions.ts               # Session storage
│   │   └── sync-queue.ts             # Sync queue management
│   ├── service-worker/
│   │   ├── register.ts               # Service worker registration
│   │   └── strategies.ts             # Cache strategies
│   ├── notifications/
│   │   ├── push.ts                   # Push notifications setup
│   │   └── in-app.ts                 # In-app notifications
│   ├── calculations/
│   │   ├── anthropometric.ts         # Fórmulas antropométricas
│   │   └── workout-metrics.ts        # Cálculo métricas treino
│   ├── utils/
│   │   ├── date.ts                   # Utils de data
│   │   ├── string.ts                 # Utils de string
│   │   ├── number.ts                 # Utils de número
│   │   └── validation.ts             # Validações customizadas
│   ├── validators/
│   │   ├── workout.ts                # Zod schemas para treinos
│   │   ├── assessment.ts             # Zod schemas para avaliações
│   │   └── user.ts                   # Zod schemas para usuários
│   ├── constants/
│   │   ├── workout.ts                # Constantes de treino
│   │   ├── assessment.ts             # Constantes de avaliação
│   │   └── pwa.ts                    # Constantes PWA
│   └── types/
│       ├── database.ts               # Types gerados do Supabase
│       ├── workout.ts
│       ├── user.ts
│       └── assessment.ts
│
├── public/                            # Arquivos estáticos
│   ├── manifest.json                 # Web App Manifest
│   ├── service-worker.js             # Service Worker (gerado)
│   ├── robots.txt
│   ├── icons/
│   │   ├── icon-192x192.png
│   │   ├── icon-192x192-maskable.png
│   │   └── icon-512x512.png
│   ├── splash/
│   │   ├── splash-640x1136.png       # iPhone SE
│   │   ├── splash-750x1334.png       # iPhone 8
│   │   ├── splash-1242x2436.png      # iPhone X/XS
│   │   ├── splash-1125x2436.png      # iPhone XR
│   │   ├── splash-1536x2048.png      # iPad Retina
│   │   └── splash-2048x2732.png      # iPad Pro
│   ├── sounds/
│   │   ├── timer-complete.mp3        # Som fim timer
│   │   ├── notification.mp3          # Som notificação
│   │   ├── light-tap.mp3             # Som light haptic
│   │   ├── medium-tap.mp3            # Som medium haptic
│   │   └── heavy-tap.mp3             # Som heavy haptic
│   └── fonts/
│       └── inter-var.woff2           # Font otimizada
│
├── styles/                            # Estilos globais
│   ├── globals.css
│   ├── variables.css                 # CSS custom properties
│   ├── animations.css                # Animações reutilizáveis
│   └── print.css                     # Estilos para impressão
│
├── supabase/                          # Migrations e config Supabase
│   ├── migrations/
│   │   ├── 20250101000000_initial_schema.sql
│   │   ├── 20250102000000_add_rls_policies.sql
│   │   └── 20250103000000_add_indexes.sql
│   ├── seed.sql                      # Dados iniciais para dev
│   └── config.toml                   # Config Supabase CLI
│
├── env/                               # Variáveis de ambiente
│   └── schema.ts                     # Validação variáveis env
│
├── docs/                              # Documentação do projeto
│   ├── README.md
│   ├── 01-PROJECT-OVERVIEW.md
│   ├── 02-TECH-STACK.md
│   ├── 03-PERSONAS.md
│   ├── 04-DATABASE-SCHEMA.md
│   ├── 05-PROJECT-STRUCTURE.md
│   ├── 06-CRITICAL-COMPONENTS.md
│   ├── 07-CUSTOM-HOOKS.md
│   ├── 08-TESTING.md
│   ├── 09-DEPLOY-MONITORING.md
│   ├── 10-TROUBLESHOOTING.md
│   ├── 11-GITHUB-SUPABASE-VERCEL-SETUP.md
│   └── 12-GITHUB-ACTIONS-WORKFLOWS.md
│
├── .env.example                       # Variáveis exemplo
├── .env.local                         # Variáveis reais (gitignored)
├── .eslintrc.json
├── .prettierrc.json
├── next.config.ts                     # Next.js config com PWA
├── tsconfig.json
├── tailwind.config.ts                 # Tailwind config
├── postcss.config.js
├── package.json
├── pnpm-lock.yaml
├── vercel.json                        # Config Vercel
├── .gitignore
└── README.md                          # Getting started
```

---

## 📂 App Directory (Next.js 15 App Router)

### Root Layout

```typescript
// app/layout.tsx
import './globals.css'
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'PWA para Treinadores de Musculação',
  description: 'Sistema PWA de gerenciamento de treinos',
  manifest: '/manifest.json',
  themeColor: '#000000',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'Treinos',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  )
}
```

### Route Groups

O projeto usa **route groups** do Next.js para organizar rotas:

- `(auth)` - Rotas de autenticação sem layout compartilhado
- `(student)` - Rotas do aluno com layout específico
- `(trainer)` - Rotas do trainer com layout específico

Os parênteses `()` indicam que o nome não faz parte da URL.

---

## 🧩 Components Directory

### Client Components

Componentes que usam hooks do React (`useState`, `useEffect`, etc.) ou interagem diretamente com APIs do navegador:

```typescript
'use client'

// components/client/WorkoutPlayer.tsx
import { useState, useEffect } from 'react'
import { useWakeLock } from '@/hooks/useWakeLock'
import { useTimerWorker } from '@/hooks/useTimerWorker'
import { useHaptic } from '@/hooks/useHaptic'

export function WorkoutPlayer({ workoutId }: { workoutId: string }) {
  const { request: requestWakeLock, release: releaseWakeLock } = useWakeLock()
  const { time, start, stop, reset } = useTimerWorker()
  const { heavyTap, success } = useHaptic()

  // ... implementation
}
```

### Server Components

Componentes que não precisam de hooks e podem ser renderizados no servidor:

```typescript
// components/server/DashboardStats.tsx
import { createServerClient } from '@/lib/supabase/server'

export async function DashboardStats({ userId }: { userId: string }) {
  const supabase = createServerClient()

  const { data: stats } = await supabase
    .from('workout_sessions')
    .select('count, total_duration_seconds')
    .eq('student_id', userId)

  // ... implementation
}
```

### Shared Components

Componentes reutilizáveis em múltiplas partes da aplicação.

---

## 🪝 Hooks Directory

Hooks customizados para encapsular lógica reutilizável.

### Hooks Críticos

```typescript
// hooks/useWakeLock.ts
export function useWakeLock() {
  // ... Wake Lock implementation
}

// hooks/useTimerWorker.ts
export function useTimerWorker() {
  // ... Timer with Web Workers
}

// hooks/useHaptic.ts
export function useHaptic() {
  // ... Haptic feedback
}

// hooks/useBackgroundSync.ts
export function useBackgroundSync() {
  // ... Background sync
}

// hooks/useOfflineStorage.ts
export function useOfflineStorage() {
  // ... IndexedDB storage
}
```

---

## 📚 Lib Directory

### Supabase Client

```typescript
// lib/supabase/client.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export const createClient = () =>
  createClientComponentClient<Database>()
```

```typescript
// lib/supabase/server.ts
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export const createServerClient = () =>
  createServerComponentClient<Database>({
    cookies,
  })
```

### Web Workers

```typescript
// lib/workers/timer.worker.ts
// Web Worker para timer preciso em thread separada

self.onmessage = function(e) {
  const { command, seconds } = e.data

  if (command === 'start') {
    // Timer implementation
  }
}
```

---

## 🎨 Convenções de Nomenclatura

### Arquivos

- **Componentes:** PascalCase (`WorkoutPlayer.tsx`)
- **Hooks:** camelCase com prefixo `use` (`useWakeLock.ts`)
- **Utilitários:** camelCase (`date.ts`, `string.ts`)
- **Types:** camelCase (`workout.ts`, `user.ts`)

### Pastas

- **Rotas:** kebab-case para URLs (`workout/new/page.tsx`)
- **Componentes:** camelCase (`components/client/`)
- **Lib:** Organizado por funcionalidade (`supabase/`, `indexeddb/`)

---

## 🔄 Imports

### Componentes

```typescript
// Componentes client devem usar caminho absoluto com alias @
import { WorkoutPlayer } from '@/components/client/WorkoutPlayer'

// Componentes server podem ser importados relativamente
import { DashboardStats } from '../../components/server/DashboardStats'
```

### Hooks

```typescript
import { useWakeLock } from '@/hooks/useWakeLock'
import { useTimerWorker } from '@/hooks/useTimerWorker'
```

### Lib

```typescript
import { createClient } from '@/lib/supabase/client'
import { calculateBMI } from '@/lib/calculations/anthropometric'
```

---

## 🎯 Best Practices

### Organização

1. **Separe client e server components** - Use `'use client'` apenas quando necessário
2. **Organize por funcionalidade** - Agrupe arquivos relacionados
3. **Use aliases de import** - `@/` para imports absolutos
4. **Mantenha estrutura flat** - Evite aninhamento excessivo

### Performance

1. **Use server components por padrão** - Reduz o bundle size
2. **Lazy loading para componentes grandes** - Use `next/dynamic`
3. **Otimizar imagens** - Use `next/image` para imagens
4. **Code splitting** - Separe rotas por funcionalidade

### TypeScript

1. **Use tipos estritos** - Ative `strict: true` no tsconfig
2. **Tipos gerados do Supabase** - Use types do banco de dados
3. **Evite any** - Use tipos explícitos sempre que possível
4. **Interfaces para props** - Defina interfaces claras

---

## 📦 Arquivos de Configuração

### next.config.ts

```typescript
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['your-supabase-storage-url'],
  },
}

module.exports = nextConfig
```

### tailwind.config.ts

```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
export default config
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

---

## 🎓 Conclusão

Esta estrutura de pastas segue as melhores práticas do Next.js 15 App Router:

- ✅ **Separação clara** entre client e server components
- ✅ **Organização lógica** por funcionalidade
- ✅ **Imports otimizados** com aliases e caminhos absolutos
- ✅ **Configuração centralizada** para TypeScript, Tailwind, Next.js
- ✅ **Preparada para escala** com separação de responsabilidades

A estrutura facilita o desenvolvimento, manutenção e escalabilidade do projeto a longo prazo. 🚀
