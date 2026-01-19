# STACK TECNOLÓGICA (ATUALIZADA - SEM VARIAÇÕES)

## Frontend
| Tecnologia | Versão | Observações |
|------------|--------|-------------|
| Framework | Next.js 15.1 | App Router obrigatório |
| Runtime | Node.js 22+ | LTS Version |
| Linguagem | TypeScript 5.7 | Strict mode ativado |
| React | 18.3.1 | Concurrent Mode |
| Styling | Tailwind CSS 4.0 | JIT compiler |
| Ícones | lucide-react v0.x | Tree-shaking otimizado |
| Validação | Zod v3 | Schema validation |
| Formulários | React Hook Form v7 | Uncontrolled components |
| Datas | date-fns v3 | Lightweight alternative to Moment.js |
| Utilitários | clsx, classnames | Conditional classnames |

## Estado Global e Data Fetching
| Tecnologia | Responsabilidade | Observações |
|------------|-------------------|-------------|
| Zustand v4 | Estado global (user, workouts, exercises) | Zero-boilerplate, persistência opcional |
| TanStack Query v5 | Server state management | Caching, retries, background updates |
| Supabase Realtime | Atualizações em tempo real | Presence tracking, live updates |
| SWR | Fallback para caching simples | Opcional para MVP |
| Context API | UI state (tema, loading states) | Não usar para dados críticos |

## PWA Core (Funcionalidades PWA)
| Tecnologia | Versão | Observações |
|------------|--------|-------------|
| Service Worker | Workbox 8.0 | Estratégias de cache avançadas |
| PWA Plugin | next-pwa v5.6+ | Manifest e service worker automático |
| Manifest | Web App Manifest JSON | Optimizado para iOS/Android/Desktop |
| Storage Offline | IndexedDB v3 + idb wrapper | Estrutura otimizada para queries |
| Background Sync | Background Sync API + Periodic Background Sync | Fallback para online sync |
| Notificações | Web Push Notifications + Badges API | VAPID keys, permission management |
| Wake Lock | Screen Wake Lock API v2 | Fallback para iOS com video loop |
| Vibração | Vibration API (Android) + Fallback iOS | Patterns pré-definidos |
| File Access | File System Access API | Exportação de relatórios |
| Desktop UI | Window Controls Overlay API | Desktop PWA experience |

## Backend e Banco de Dados
| Tecnologia | Versão | Observações |
|------------|--------|-------------|
| Backend | Supabase | PostgreSQL 14 + Auth + Realtime |
| Banco de Dados | PostgreSQL 14.x | Row Level Security obrigatório |
| Autenticação | Supabase Auth (JWT) | PKCE flow para segurança |
| RLS | Row Level Security | Policies granulares por tabela |
| Storage | Supabase Storage | Signed URLs para privacidade |
| Edge Functions | Supabase Edge Functions | Cálculos pesados offloaded |
| Realtime | Supabase Realtime | Presence channel para acompanhamento |

## Deploy e Hosting
| Tecnologia | Observações |
|------------|-------------|
| Frontend Deploy | Vercel (Edge Network) |
| Edge Network | Vercel Edge Functions |
| Banco de Dados | Supabase Cloud (managed PostgreSQL) |
| Versionamento | GitHub (branch strategy clara) |
| CI/CD | Vercel CI + GitHub Actions |
| Monitoramento | Vercel Analytics + Speed Insights |

## Dependências Adicionais
| Categoria | Tecnologias |
|-----------|-------------|
| HTTP Client | fetch API nativa + Supabase client |
| Testes | Vitest + React Testing Library |
| Linting | ESLint + Prettier + TypeScript ESLint |
| Documentação | JSDoc + Storybook |
| Monitoring | Vercel Analytics + Sentry (opcional) |
| Rate Limiting | @upstash/ratelimit + Redis |

---

# ESTRUTURA DE PASTAS (NEXT.JS APP ROUTER - ATUALIZADA)

```bash
projeto-treinos-pwa/
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # Testes, linting e type checking
│   │   ├── preview.yml               # Deploy preview para PRs
│   │   └── production.yml            # Deploy produção para main
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
│
├── app/
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
│   └── api/
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
├── components/
│   ├── client/
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
│   ├── server/
│   │   ├── StudentsList.tsx          # Server component
│   │   ├── WorkoutsList.tsx
│   │   ├── AssessmentsList.tsx
│   │   ├── SessionHistoryList.tsx
│   │   ├── DashboardStats.tsx        # Stats cards para dashboards
│   │   └── RealtimePresence.tsx      # Indicador de presença online
│   │
│   └── shared/
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
├── hooks/
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
├── lib/
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
├── public/
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
├── styles/
│   ├── globals.css
│   ├── variables.css                 # CSS custom properties
│   ├── animations.css                # Animações reutilizáveis
│   └── print.css                     # Estilos para impressão
│
├── supabase/
│   ├── migrations/
│   │   ├── 20250101000000_initial_schema.sql
│   │   ├── 20250102000000_add_rls_policies.sql
│   │   └── 20250103000000_add_indexes.sql
│   ├── seed.sql                      # Dados iniciais para dev
│   └── config.toml                   # Config Supabase CLI
│
├── env/
│   └── schema.ts                     # Validação variáveis env
│
├── docs/                             # Documentação do projeto
│   ├── 01-PROMPT-MASTER.md
│   ├── 02-PROJECT-BRIEF.md
│   ├── 03-ARCHITECTURE.md
│   ├── 04-DATABASE-SCHEMA.md
│   ├── 05-COMPONENTS.md
│   ├── 06-CUSTOM-HOOKS.md
│   ├── 07-PWA-FEATURES.md
│   ├── 08-API-DOCUMENTATION.md
│   ├── 09-SECURITY.md
│   ├── 10-SETUP-DEPLOY.md
│   ├── 11-PROMPTS-FOR-AI.md
│   └── INDEX.md
│
├── .env.example                      # Variáveis exemplo
├── .env.local                        # Variáveis reais (gitignored)
├── .eslintrc.json
├── .prettierrc.json
├── next.config.ts                    # Next.js config com PWA
├── tsconfig.json
├── tailwind.config.ts                # Tailwind config
├── postcss.config.js
├── package.json
├── pnpm-lock.yaml
├── vercel.json                       # Config Vercel
├── .gitignore
└── README.md                         # Getting started
```
