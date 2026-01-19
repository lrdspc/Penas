# 🛠️ Stack Tecnológico

Este documento detalha todas as tecnologias utilizadas no projeto, incluindo versões específicas e observações importantes.

## 📋 Stack Tecnológico Resumido

| Categoria | Tecnologia | Versão | Propósito |
|-----------|-----------|--------|-----------|
| **Framework** | Next.js | 15.1 | App Router obrigatório |
| **Runtime** | Node.js | 22+ | LTS Version |
| **Linguagem** | TypeScript | 5.7 | Strict mode ativado |
| **React** | React | 18.3.1 | Concurrent Mode |
| **Styling** | Tailwind CSS | 4.0 | JIT compiler |
| **Ícones** | lucide-react | v0.x | Tree-shaking otimizado |
| **Validação** | Zod | v3 | Schema validation |
| **Formulários** | React Hook Form | v7 | Uncontrolled components |
| **Datas** | date-fns | v3 | Lightweight alternative to Moment.js |
| **Utilitários** | clsx, classnames | - | Conditional classnames |

## 🎨 Frontend

### Framework: Next.js 15.1

**Por que Next.js 15.1?**
- ✅ App Router com Server Components
- ✅ Performance otimizada com streaming
- ✅ Turbopack para builds mais rápidos
- ✅ Suporte nativo a PWA
- ✅ Edge Functions integradas
- ✅ Melhor suporte a TypeScript

**Configurações Importantes:**
```typescript
// next.config.ts
const nextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  compress: true,
  swcMinify: true,
  images: {
    domains: ['your-supabase-storage-url'],
  },
  experimental: {
    optimizePackageImports: ['lucide-react'],
  },
}
```

### Linguagem: TypeScript 5.7

**Por que TypeScript?**
- ✅ Type safety em tempo de desenvolvimento
- ✅ Melhor DX (Developer Experience)
- ✅ Refatoração mais segura
- ✅ Autocomplete inteligente
- ✅ Documentação como código

**Configuração:**
```json
// tsconfig.json
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
    "skipLibCheck": true
  }
}
```

### Styling: Tailwind CSS 4.0

**Por que Tailwind 4.0?**
- ✅ JIT compiler otimizado
- ✅ Zero runtime overhead
- ✅ Design system consistente
- ✅ Dark mode integrado
- ✅ Responsive design fácil

**Configuração:**
```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: 'class',
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          // ...
        },
      },
    },
  },
  plugins: [],
}
export default config
```

## 🏗️ Estado Global e Data Fetching

### Estado Global: Zustand v4

**Por que Zustand?**
- ✅ Zero-boilerplate
- ✅ TypeScript support nativo
- ✅ DevTools integrado
- ✅ Persistência opcional
- ✅ Bundle size pequeno (~1KB)

**Use Cases:**
- Estado global do usuário
- Estado do player de treino
- Tema da aplicação
- Configurações do usuário

### Server State: TanStack Query v5

**Por que TanStack Query?**
- ✅ Caching inteligente automático
- ✅ Background updates
- ✅ Deduplication de requests
- ✅ Optimistic updates
- ✅ Retry automático

**Use Cases:**
- Dados do Supabase (treinos, exercícios)
- Dados de sessões
- Dados de avaliações
- Listagem de alunos

### Realtime: Supabase Realtime

**Por que Supabase Realtime?**
- ✅ Atualizações em tempo real sem configuração
- ✅ Presence tracking nativo
- ✅ Channels multi-tenant
- ✅ Integração perfeita com Supabase Auth

**Use Cases:**
- Acompanhamento de alunos em tempo real
- Notificações live
- Atualização de status de treinos

## 📡 PWA Core

### Service Worker: Workbox 8.0

**Por que Workbox?**
- ✅ Estratégias de cache avançadas
- ✅ Automatic routing
- ✅ Precaching inteligente
- ✅ Background Sync
- ✅ Integrado com next-pwa

**Estratégias de Cache:**
- **CacheFirst:** assets estáticos (JS, CSS, imagens)
- **NetworkFirst:** API calls do Supabase
- **StaleWhileRevalidate:** dados que podem estar desatualizados por curto período
- **NetworkOnly:** dados sensíveis (auth)

### PWA Plugin: next-pwa v5.6+

**Por que next-pwa?**
- ✅ Integração nativa com Next.js
- ✅ Geração automática de manifest
- ✅ Service worker otimizado
- ✅ Configuração simplificada

**Configuração:**
```typescript
// next.config.ts
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/.*\.supabase\.co\/.*/,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'supabase-api',
        expiration: {
          maxEntries: 64,
          maxAgeSeconds: 24 * 60 * 60,
        },
        networkTimeoutSeconds: 15,
      },
    },
  ],
})

module.exports = withPWA(nextConfig)
```

### Storage Offline: IndexedDB v3 + idb wrapper

**Por que IndexedDB + idb?**
- ✅ Armazenamento assíncrono
- ✅ Capacidade grande (GBs)
- ✅ Queries indexadas
- ✅ idb wrapper com Promises

**Schema do IndexedDB:**
```typescript
// Stores
- workouts: treinos atribuídos
- exercises: exercícios com vídeos
- sessions: sessões de treino
- sync_queue: fila de sincronização
```

### Background Sync: Background Sync API + Periodic Background Sync

**Por que Background Sync?**
- ✅ Sincronização automática quando online
- ✅ Fallback para manual se não suportado
- ✅ Priorização de dados críticos
- ✅ Retry automático em falhas

### Notificações: Web Push Notifications + Badges API

**Por que Web Push?**
- ✅ Notificações mesmo com app fechado
- ✅ VAPID keys para segurança
- ✅ Badges API para contadores
- ✅ Fallback para in-app notifications

### Wake Lock: Screen Wake Lock API v2

**Por que Wake Lock?**
- ✅ Mantém tela ligada durante treino
- ✅ Fallback para iOS usando video loop
- ✅ Fallback alternativo com animation
- ✅ Liberação automática de recursos

### Vibração: Vibration API + Fallback iOS

**Por que Vibration API?**
- ✅ Feedback háptico consistente
- ✅ Padrões customizáveis
- ✅ Fallback para iOS com som + flash
- ✅ Navegador handles o hardware

### File Access: File System Access API

**Por que File System Access?**
- ✅ Exportação de relatórios
- ✅ Acesso nativo ao sistema de arquivos
- ✅ Permissões granulares
- ✅ Fallback para download tradicional

## 🗄️ Backend e Banco de Dados

### Backend: Supabase

**Por que Supabase?**
- ✅ PostgreSQL gerenciado
- ✅ Auth integrado com JWT
- ✅ Realtime sem configuração
- ✅ Storage com signed URLs
- ✅ Edge Functions
- ✅ Row Level Security (RLS)

### Banco de Dados: PostgreSQL 14.x

**Por que PostgreSQL 14?**
- ✅ ACID compliance
- ✅ Row Level Security (RLS)
- ✅ JSONB para flexibilidade
- ✅ Arrays nativos
- ✅ Performance otimizada
- ✅ Full-text search integrado

### Autenticação: Supabase Auth (JWT)

**Por que Supabase Auth?**
- ✅ JWT tokens com expiração
- ✅ PKCE flow para segurança
- ✅ OAuth providers (Google, Apple)
- ✅ Email/password com verificação
- ✅ Session management automático

### RLS: Row Level Security

**Por que RLS?**
- ✅ Segurança em nível de banco
- ✅ Policies granulares por tabela
- ✅ Proteção automática de dados
- ✅ Isolamento entre trainers

### Storage: Supabase Storage

**Por que Supabase Storage?**
- ✅ Signed URLs para privacidade
- ✅ Upload de vídeos e imagens
- ✅ CDN integrado
- ✅ Transformações de imagem
- ✅ Buckets organizados

### Edge Functions: Supabase Edge Functions

**Por que Edge Functions?**
- ✅ Cálculos pesados offloaded
- ✅ Latência baixa global
- ✅ TypeScript support
- ✅ Integração com Supabase Auth

### Realtime: Supabase Realtime

**Por que Supabase Realtime?**
- ✅ Presence channel para acompanhamento
- ✅ Atualizações live de dados
- ✅ Broadcast channels para notificações
- ✅ Auto-reconnection

## 🚀 Deploy e Hosting

### Frontend Deploy: Vercel

**Por que Vercel?**
- ✅ Edge Network global
- ✅ Preview deployments automáticos
- ✅ CI/CD integrado
- ✅ Analytics e Speed Insights
- ✅ Suporte nativo a Next.js
- ✅ Zero configuration

### Edge Network: Vercel Edge Functions

**Por que Edge Functions?**
- ✅ Latência ultra-baixa
- ✅ Global deployment
- ✅ Cold start rápido
- ✅ Integrado com Next.js

### Banco de Dados: Supabase Cloud

**Por que Supabase Cloud?**
- ✅ PostgreSQL gerenciado
- ✅ Backups automáticos
- ✅ Point-in-time recovery
- ✅ SSL/TLS encryptado
- ✅ Auto-scaling

### Versionamento: GitHub

**Por que GitHub?**
- ✅ Branch strategy clara
- ✅ Pull requests com reviews
- ✅ Issues tracking
- ✅ Actions para CI/CD

### CI/CD: Vercel CI + GitHub Actions

**Por que Vercel CI + GitHub Actions?**
- ✅ Deploy automático no push
- ✅ Preview environments para PRs
- ✅ Tests e linting no pipeline
- ✅ Migrations automáticas
- ✅ Rollback fácil

### Monitoramento: Vercel Analytics + Speed Insights

**Por que Vercel Analytics?**
- ✅ Web Vitals automáticas
- ✅ Real user monitoring (RUM)
- ✅ Performance tracking
- ✅ Conversion tracking

## 🧪 Testes

### Testes Unitários: Vitest

**Por que Vitest?**
- ✅ Compatível com Jest
- ✅ Mais rápido com ESM
- ✅ Watch mode instantâneo
- ✅ TypeScript support

### Testes de Componentes: React Testing Library

**Por que RTL?**
- ✅ Testing best practices
- ✅ Query selectors semânticos
- ✅ User-centric testing
- ✅ Integrado com Vitest

### Linting: ESLint + Prettier + TypeScript ESLint

**Por que ESLint?**
- ✅ Code quality
- ✅ Bug detection
- ✅ Consistency
- ✅ Auto-fix

**Por que Prettier?**
- ✅ Formatting consistente
- ✅ Zero configuration
- ✅ Integrado com ESLint

## 📚 Dependências Adicionais

### HTTP Client: fetch API nativa + Supabase client

**Por que?**
- ✅ Native browser API
- ✅ Supabase client com TypeScript
- ✅ Auth integrado
- ✅ Type-safe queries

### Monitoring: Vercel Analytics + Sentry (opcional)

**Por que?**
- ✅ Error tracking (Sentry)
- ✅ Performance metrics (Vercel)
- ✅ Real user monitoring
- ✅ Alertas automáticos

### Rate Limiting: @upstash/ratelimit + Redis

**Por que?**
- ✅ Proteção contra brute force
- ✅ Limitar API calls
- ✅ Distributed rate limiting
- ✅ Fácil integração

## 📦 Package.json Resumido

```json
{
  "dependencies": {
    "next": "15.1.0",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "typescript": "5.7.0",
    "@supabase/supabase-js": "^2.39.0",
    "zustand": "^4.4.7",
    "@tanstack/react-query": "^5.17.0",
    "tailwindcss": "^4.0.0",
    "lucide-react": "^0.300.0",
    "zod": "^3.22.4",
    "react-hook-form": "^7.49.3",
    "date-fns": "^3.0.6",
    "clsx": "^2.0.0",
    "classnames": "^2.3.2",
    "idb": "^8.0.0",
    "next-pwa": "^5.6.0",
    "@upstash/ratelimit": "^1.0.0",
    "@upstash/redis": "^1.25.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "eslint": "^8.56.0",
    "eslint-config-next": "15.1.0",
    "prettier": "^3.1.1",
    "typescript-eslint": "^6.15.0",
    "vitest": "^1.0.0",
    "@testing-library/react": "^14.1.0",
    "@testing-library/jest-dom": "^6.1.5",
    "@vitejs/plugin-react": "^4.2.1"
  }
}
```

## 🎯 Conclusão

Este stack tecnológico foi cuidadosamente selecionado para fornecer:
- ✅ **Performance otimizada** com Next.js 15.1 e Web Workers
- ✅ **Experiência nativa** com PWA APIs modernas
- ✅ **Segurança robusta** com RLS e Supabase Auth
- ✅ **Desenvolvimento rápido** com DX excelente
- ✅ **Deploy confiável** com Vercel e GitHub Actions
- ✅ **Escalabilidade** com PostgreSQL e Supabase

O equilíbrio entre tecnologias modernas e comprovadas garante um projeto sustentável e fácil de manter a longo prazo. 💪🚀
