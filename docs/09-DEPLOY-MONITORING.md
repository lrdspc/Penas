# 🚀 Deploy e Monitoramento

Este documento detalha todo o processo de deploy e monitoramento do projeto.

## 📋 Visão Geral

O projeto usa **Vercel** para deploy com **GitHub Actions** para CI/CD.

---

## 🔧 Variáveis de Ambiente

### Development (.env.local)

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# VAPID (Web Push)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=your-vapid-private-key

# Upstash Redis (Rate Limiting)
NEXT_PUBLIC_UPSTASH_REDIS_REST_URL=https://your-redis.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-redis-token

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Preview (Vercel Environment Variables)

```bash
# Supabase (Preview Project)
NEXT_PUBLIC_SUPABASE_URL=https://your-preview-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-preview-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-preview-service-role-key

# VAPID (Generate new keys)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=your-preview-vapid-public-key
VAPID_PRIVATE_KEY=your-preview-vapid-private-key

# Upstash Redis (Preview)
NEXT_PUBLIC_UPSTASH_REDIS_REST_URL=https://your-preview-redis.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-preview-redis-token

# App
NEXT_PUBLIC_APP_URL=https://your-app.vercel.app
```

### Production (Vercel Environment Variables)

```bash
# Supabase (Production Project)
NEXT_PUBLIC_SUPABASE_URL=https://your-production-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-production-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-production-service-role-key

# VAPID (Production Keys)
NEXT_PUBLIC_VAPID_PUBLIC_KEY=your-production-vapid-public-key
VAPID_PRIVATE_KEY=your-production-vapid-private-key

# Upstash Redis (Production)
NEXT_PUBLIC_UPSTASH_REDIS_REST_URL=https://your-production-redis.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-production-redis-token

# App
NEXT_PUBLIC_APP_URL=https://your-production-url.com
```

---

## 🚀 Deploy na Vercel

### 1. Criar Projeto na Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Login
vercel login

# Criar projeto
vercel link
```

### 2. Configurar Variáveis de Ambiente

```bash
# Adicionar variáveis de ambiente
vercel env add NEXT_PUBLIC_SUPABASE_URL
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
vercel env add SUPABASE_SERVICE_ROLE_KEY
# ... adicionar todas as variáveis
```

### 3. Configurar Deploy

```bash
# Deploy para preview
vercel --env=preview

# Deploy para produção
vercel --env=production --prod
```

---

## 🔄 Deploy Automático com GitHub Actions

### Workflow de Preview

O workflow `.github/workflows/preview.yml` é executado automaticamente em cada PR:

```yaml
name: Preview Deploy

on:
  pull_request:
    branches: [main, develop]

jobs:
  deploy-preview:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prebuilt'
```

### Workflow de Produção

O workflow `.github/workflows/production.yml` é executado ao fazer merge na main:

```yaml
name: Production Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'

      - name: Run Database Migrations
        run: |
          npx supabase db push
```

---

## 📊 Monitoramento

### Vercel Analytics

**Objetivo:** Rastrear métricas de usuário e performance

```typescript
// components/analytics/VercelAnalytics.tsx
'use client'

import { Analytics } from '@vercel/analytics/react'

export function VercelAnalytics() {
  return <Analytics />
}
```

**Adicionar ao root layout:**

```typescript
// app/layout.tsx
import { VercelAnalytics } from '@/components/analytics/VercelAnalytics'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        <VercelAnalytics />
      </body>
    </html>
  )
}
```

### Vercel Speed Insights

**Objetivo:** Rastrear Web Vitals e performance

```typescript
// components/analytics/SpeedInsights.tsx
'use client'

import { SpeedInsights } from '@vercel/speed-insights/next'

export function SpeedInsights() {
  return <SpeedInsights />
}
```

### Sentry (Error Tracking)

**Objetivo:** Capturar e rastrear erros em produção

```typescript
// lib/sentry/client.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
})
```

```typescript
// lib/sentry/server.ts
import * as Sentry from '@sentry/nextjs'

export function registerSentry() {
  if (process.env.NODE_ENV === 'production') {
    Sentry.init({
      dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
      tracesSampleRate: 1.0,
      environment: process.env.NODE_ENV,
    })
  }
}
```

### Custom Metrics

**Objetivo:** Rastrear métricas específicas do negócio

```typescript
// lib/analytics/metrics.ts
export function trackWorkoutCompleted(sessionId: string, duration: number) {
  if (typeof window !== 'undefined' && 'gtag' in window) {
    (window as any).gtag('event', 'workout_completed', {
      event_category: 'workout',
      event_label: sessionId,
      value: duration
    })
  }
}

export function trackAssessmentCreated(assessmentId: string) {
  if (typeof window !== 'undefined' && 'gtag' in window) {
    (window as any).gtag('event', 'assessment_created', {
      event_category: 'assessment',
      event_label: assessmentId
    })
  }
}
```

---

## 📈 Performance Targets

### Web Vitals

| Métrica | Target | Status |
|---------|--------|--------|
| LCP (Largest Contentful Paint) | <2.5s | ✅ |
| FID (First Input Delay) | <100ms | ✅ |
| CLS (Cumulative Layout Shift) | <0.1 | ✅ |
| FCP (First Contentful Paint) | <1.8s | ✅ |
| TTI (Time to Interactive) | <3.8s | ✅ |

### Lighthouse Score

| Categoria | Target | Status |
|-----------|--------|--------|
| Performance | >90 | ✅ |
| Accessibility | >90 | ✅ |
| Best Practices | >90 | ✅ |
| SEO | >90 | ✅ |
| PWA | 100 | ✅ |

### Custom Metrics

| Métrica | Target |
|---------|--------|
| Tempo de carregamento 3G | <2s |
| Memory usage durante treino | <100MB |
| Battery consumption por hora | <5% |
| Offline startup time | <1s |

---

## 🔔 Alertas

### Vercel Alerts

Configure alertas no dashboard da Vercel:

1. Vá para `Settings > Alerts`
2. Clique em `Create Alert`
3. Configure:
   - **Type:** Deployment Error
   - **Condition:** Any deployment fails
   - **Notification:** Slack, Email, etc.

### Sentry Alerts

Configure alertas no dashboard da Sentry:

1. Vá para `Settings > Alerts`
2. Crie alertas para:
   - Errors com alto impacto
   - Performance degradation
   - Spike de errors

### Custom Alerts

```typescript
// lib/monitoring/custom-alerts.ts
export async function checkSyncQueueHealth() {
  const { data } = await supabase
    .from('offline_sync_queue')
    .select('count')
    .eq('status', 'failed')

  if (data && data.count > 100) {
    await sendSlackAlert({
      text: `⚠️ Fila de sync tem ${data.count} itens falhados`,
      channel: '#alerts'
    })
  }
}
```

---

## 📊 Dashboards

### Vercel Dashboard

Acompanhe:
- Deployments
- Web Vitals
- Analytics
- Logs

### Supabase Dashboard

Acompanhe:
- Database queries
- Auth events
- Storage usage
- Realtime connections

### Custom Dashboard

```typescript
// app/admin/dashboard/page.tsx
export default async function AdminDashboard() {
  const stats = await getAdminStats()

  return (
    <div>
      <StatsCards stats={stats} />
      <Charts />
      <RecentActivity />
    </div>
  )
}
```

---

## 🔒 Segurança no Deploy

### Environment Variables

- ✅ Nunca commitar `.env.local`
- ✅ Usar variáveis de ambiente no Vercel
- ✅ Validar todas as variáveis no startup
- ✅ Usar tipos TypeScript para env vars

### Secrets Management

```typescript
// env/schema.ts
import { z } from 'zod'

const envSchema = z.object({
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  NEXT_PUBLIC_VAPID_PUBLIC_KEY: z.string().min(1),
  VAPID_PRIVATE_KEY: z.string().min(1),
  // ... demais variáveis
})

export const env = envSchema.parse(process.env)
```

### Pre-Deploy Checklist

- [ ] Todas as variáveis de ambiente configuradas
- [ ] Migrations testadas em ambiente de preview
- [ ] Tests passam
- [ ] Lint sem erros
- [ ] Type check sem erros
- [ ] Build sem warnings
- [ ] Sentry configurado
- [ ] Analytics configurados

### Post-Deploy Checklist

- [ ] Site carrega corretamente
- [ ] Login funciona
- [ ] Treinos podem ser criados
- [ ] Player de treino funciona
- [ ] Offline mode funciona
- [ ] PWA instala corretamente
- [ ] Push notifications funcionam
- [ ] Realtime atualiza
- [ ] Analytics estão coletando dados
- [ ] Sentry está capturando erros

---

## 🎯 Performance Optimization

### Build Optimization

```typescript
// next.config.ts
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  compress: true,
  experimental: {
    optimizePackageImports: ['lucide-react', '@supabase/supabase-js'],
  },
}
```

### Image Optimization

```typescript
import Image from 'next/image'

<Image
  src={exercise.image_url}
  alt={exercise.name}
  width={400}
  height={300}
  loading="lazy"
  blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRg..."
/>
```

### Bundle Size Optimization

```json
// .eslintrc.json
{
  "rules": {
    "no-restricted-imports": [
      "error",
      {
        "name": ["lodash"],
        "message": "Use lodash-es instead"
      }
    ]
  }
}
```

---

## 🔄 Rollback Procedure

### 1. Identificar Problema

```bash
# Ver logs recentes
vercel logs --limit 100

# Ver Web Vitals
vercel analytics --latest
```

### 2. Determinar Causa

- Ver Sentry para errors
- Ver Vercel Analytics para performance
- Ver logs para exceptions

### 3. Rollback

```bash
# Rollback para deploy anterior
vercel rollback [deployment-url]

# Ou rollback para N deploys atrás
vercel rollback --to [N]
```

### 4. Corrigir e Deploy

```bash
# Corrigir código
git fix

# Deploy fix
vercel --prod
```

---

## 🎓 Conclusão

O pipeline de deploy e monitoramento garante:

- ✅ **Deploy confiável** - CI/CD automatizado
- ✅ **Monitoramento contínuo** - Analytics, errors, performance
- ✅ **Alertas proativos** - Notificação de problemas
- ✅ **Rollback rápido** - Capacidade de reverter
- ✅ **Performance otimizada** - Métricas e otimizações

Com este setup, o projeto está pronto para produção com confiança total. 🚀
