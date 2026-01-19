# 🐛 Troubleshooting

Este documento contém soluções para problemas comuns encontrados durante desenvolvimento e deploy.

## 📋 Índice

1. [Problemas de Desenvolvimento](#desenvolvimento)
2. [Problemas de Supabase](#supabase)
3. [Problemas de Deploy](#deploy)
4. [Problemas de PWA](#pwa)
5. [Problemas de Performance](#performance)
6. [Problemas de Testes](#testes)

---

## 🔧 Problemas de Desenvolvimento

### Erro: "Module not found: Can't resolve '@/components/...'"

**Sintoma:**
```bash
Module not found: Can't resolve '@/components/WorkoutPlayer' from '/app/(student)/workout/[id]/play/page.tsx'
```

**Causa:** Path alias não configurado corretamente no `tsconfig.json`

**Solução:**
```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

---

### Erro: "next/image loader is not configured"

**Sintoma:**
```bash
Error: next/image loader is not configured with domains
```

**Causa:** Domínio do Supabase Storage não adicionado ao `next.config.ts`

**Solução:**
```typescript
// next.config.ts
const nextConfig = {
  images: {
    domains: ['your-project.supabase.co'],
  },
}
```

---

### Erro: "ReferenceError: window is not defined"

**Sintoma:**
```bash
ReferenceError: window is not defined
```

**Causa:** Código que acessa `window` ou `document` está sendo executado no servidor

**Solução:**
```typescript
// Adicionar 'use client' no topo do arquivo
'use client'

// Ou verificar se está no browser
if (typeof window !== 'undefined') {
  // Código que usa window
}
```

---

### Erro: "Failed to fetch" ao chamar API do Supabase

**Sintoma:**
```bash
Error: Failed to fetch
```

**Causa:** Problema de CORS ou URL errada do Supabase

**Solução:**
1. Verifique a URL do Supabase no `.env.local`
2. Adicione o domínio do Vercel às configurações de CORS do Supabase

```bash
# No Supabase Dashboard
Settings > API > CORS
Add: https://your-app.vercel.app
```

---

## 🗄️ Problemas de Supabase

### Erro: "new row violates row-level security policy"

**Sintoma:**
```bash
Error: new row violates row-level security policy for table "workouts"
```

**Causa:** RLS policy não permite inserção

**Solução:**
1. Verifique se o usuário está autenticado
2. Verifique as RLS policies no Supabase Dashboard
3. Confirme que a policy permite a operação

```sql
-- Ver policies
SELECT *
FROM pg_policies
WHERE tablename = 'workouts';

-- Exemplo de policy para INSERT
CREATE POLICY "Trainers can insert workouts"
ON workouts FOR INSERT
WITH CHECK (trainer_id = auth.uid());
```

---

### Erro: "Permission denied for table users"

**Sintoma:**
```bash
Error: permission denied for table users
```

**Causa:** Usuário não tem permissão para acessar a tabela

**Solução:**
```sql
-- Conceder permissão
GRANT SELECT ON users TO anon;
GRANT SELECT ON users TO authenticated;
```

---

### Erro: "relation 'public.users' does not exist"

**Sintoma:**
```bash
Error: relation 'public.users' does not exist
```

**Causa:** Migrations não foram executadas

**Solução:**
```bash
# Executar migrations
npx supabase db push

# Ou manualmente via SQL
npx supabase db execute
```

---

### Problema: RLS policy não está funcionando

**Sintoma:** Usuário pode ver dados que não deveria

**Causa:** RLS não está habilitado na tabela

**Solução:**
```sql
-- Habilitar RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
-- ... habilitar em todas as tabelas
```

---

### Problema: Dados não aparecem na aplicação

**Sintoma:** Queries retornam dados vazios

**Causa:** Usuário não está vinculado ao trainer

**Solução:**
```sql
-- Verificar se aluno está vinculado
SELECT *
FROM trainer_students
WHERE student_id = auth.uid()
  AND status = 'active';

-- Se não estiver, criar vínculo
INSERT INTO trainer_students (trainer_id, student_id, invite_token, status)
VALUES ('trainer-id', 'student-id', 'token', 'active');
```

---

## 🚀 Problemas de Deploy

### Erro: "Build failed with exit code 1"

**Sintoma:**
```bash
Error: Build failed with exit code 1
```

**Causa:** Erro de TypeScript, lint ou build

**Solução:**
```bash
# Verificar erros localmente
pnpm lint
pnpm type-check
pnpm build

# Corrigir erros e tentar novamente
git add .
git commit -m "Fix build errors"
git push
```

---

### Erro: "Environment variable not defined"

**Sintoma:**
```bash
Error: NEXT_PUBLIC_SUPABASE_URL is not defined
```

**Causa:** Variável de ambiente não configurada no Vercel

**Solução:**
```bash
# Adicionar variável no Vercel
vercel env add NEXT_PUBLIC_SUPABASE_URL

# Ou via dashboard Vercel
Settings > Environment Variables > Add New
```

---

### Problema: Deploy fica preso em "Queued"

**Sintoma:** Deploy fica em estado "Queued" por muito tempo

**Causa:** Problema com GitHub Actions ou Vercel

**Solução:**
1. Cancelar o deploy
2. Verificar logs do GitHub Actions
3. Tentar deploy novamente
4. Se persistir, contactar suporte Vercel

---

### Problema: Preview deployment não atualiza

**Sintoma:** Preview deployment mostra código antigo

**Causa:** Cache do Vercel

**Solução:**
```bash
# Limpar cache e re-deploy
vercel --force
```

---

## 📡 Problemas de PWA

### Problema: Service worker não registra

**Sintoma:** Service worker não aparece no DevTools

**Causa:** `next-pwa` está desabilitado em desenvolvimento

**Solução:**
```typescript
// next.config.ts
const withPWA = require('next-pwa')({
  disable: false, // Habilite para testar em dev
  dest: 'public',
  register: true,
})
```

---

### Problema: App não instala (botão "Add to Home Screen" não aparece)

**Sintoma:** Não aparece botão para instalar app

**Causa:** Manifest ou service worker não configurado corretamente

**Solução:**
1. Verifique se `manifest.json` está na pasta `public`
2. Verifique se service worker está registrado
3. Verifique se HTTPS está sendo usado (obrigatório para PWA)
4. Use Lighthouse para verificar PWA compliance

```bash
# Verificar PWA compliance
npx lighthouse https://your-app.vercel.app --view
```

---

### Problema: App funciona offline mas não sincroniza

**Sintoma:** Dados salvos offline não sincronizam quando volta online

**Causa:** Background Sync não está funcionando

**Solução:**
1. Verifique se `navigator.serviceWorker` está disponível
2. Verifique se Background Sync está registrado
3. Verifique logs do service worker

```typescript
// Verificar suporte
if ('serviceWorker' in navigator && 'sync' in ServiceWorkerRegistration.prototype) {
  console.log('Background Sync é suportado')
} else {
  console.warn('Background Sync não é suportado')
}
```

---

### Problema: Wake Lock não funciona no iOS

**Sintoma:** Tela desliga no iOS durante treino

**Causa:** iOS não suporta Wake Lock API nativamente

**Solução:** Verifique se o fallback iOS está implementado

```typescript
// Verificar se fallback está ativo
const { isSupported, isActive } = useWakeLock()

if (!isSupported) {
  console.log('Usando fallback para iOS')
  // Fallback deve manter tela ligada
}
```

---

## ⚡ Problemas de Performance

### Problema: Aplicação lenta ao carregar

**Sintoma:** Tempo de carregamento >3s

**Causa:** Imagens não otimizadas, bundle grande, ou queries lentas

**Solução:**
```bash
# Analisar performance
npx lighthouse https://your-app.vercel.app --view

# Verificar bundle size
pnpm build

# Analisar pacotes
npx @next/bundle-analyzer
```

---

### Problema: Memory leak no player de treino

**Sintoma:** Aplicação fica lenta após longos treinos

**Causa:** Event listeners não sendo removidos, Web Workers não terminados

**Solução:**
```typescript
useEffect(() => {
  // Setup
  const worker = new Worker('timer.worker.js')
  const handler = (e: MessageEvent) => {
    // Handler
  }

  worker.addEventListener('message', handler)

  // Cleanup
  return () => {
    worker.removeEventListener('message', handler)
    worker.terminate()
  }
}, [])
```

---

### Problema: Timer perde precisão

**Sintoma:** Timer mostra tempo incorreto após longo período

**Causa:** Web Worker não está corretamente implementado

**Solução:**
```typescript
// Verificar se worker está rodando em thread separada
const { time, isRunning } = useTimerWorker()

console.log('Time:', time)
console.log('Is running:', isRunning)
console.log('Worker:', workerRef.current)
```

---

## 🧪 Problemas de Testes

### Problema: Testes falham no CI mas passam localmente

**Sintoma:** Testes passam localmente mas falham no GitHub Actions

**Causa:** Timezone, versões diferentes, ou ambiente diferente

**Solução:**
```bash
# Configurar timezone no GitHub Actions
- name: Set timezone
  run: |
    export TZ=UTC
```

---

### Problema: Testes de componentes falham com "act() is not defined"

**Sintoma:** Erro ao usar `act()` em testes

**Causa:** Versão do React Testing Library ou imports incorretos

**Solução:**
```typescript
// Importar corretamente
import { act } from '@testing-library/react'

// Ou usar versão compatível
import { renderHook, act } from '@testing-library/react-hooks'
```

---

### Problema: Mocks não funcionam

**Sintoma:** Funções mocked ainda são chamadas

**Causa:** Mocks não configurados corretamente

**Solução:**
```typescript
// Antes de cada teste
beforeEach(() => {
  vi.clearAllMocks()
  vi.resetAllMocks()
})

// Verificar se mock foi chamado
expect(mockFunction).toHaveBeenCalled()
expect(mockFunction).toHaveBeenCalledWith('expected-arg')
```

---

## 🔍 Debugging

### Logs do Vercel

```bash
# Ver logs recentes
vercel logs --limit 100

# Ver logs de um deploy específico
vercel logs <deployment-url>

# Ver logs em tempo real
vercel logs --follow
```

### Logs do Supabase

```bash
# Ver logs do banco de dados
npx supabase logs db

# Ver logs de API
npx supabase logs api

# Ver logs específicos
npx supabase logs functions <function-name>
```

### Logs do Service Worker

```javascript
// Adicionar logs no service worker
console.log('[SW] Service worker registrado')
console.log('[SW] Cache strategy:', strategy)
console.log('[SW] Background sync registrado')
```

### Logs do Sentry

```typescript
// Adicionar contexto para errors
Sentry.captureException(error, {
  tags: {
    component: 'WorkoutPlayer',
    phase: 'rest'
  },
  extra: {
    workoutId,
    currentExerciseIndex,
    timeRemaining
  }
})
```

---

## 🛠️ Ferramentas de Debugging

### React DevTools

```bash
# Instalar React DevTools
pnpm add @welldone-software/why-did-you-render

# Usar em desenvolvimento
import whyDidYouRender from '@welldone-software/why-did-you-render'
```

### Chrome DevTools

```javascript
// Adicionar breakpoints
debugger

// Ver logs no console
console.log('Current exercise:', currentExercise)
console.log('Timer state:', { time, isRunning })
console.table(playerState.setsCompleted)
```

### Network Tab

```typescript
// Verificar requisições de rede
fetch('/api/workouts', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(workout)
}).then(res => {
  console.log('Response:', res)
  return res.json()
})
```

---

## 📞 Recursos Adicionais

### Documentação

- [Next.js Docs](https://nextjs.org/docs)
- [Supabase Docs](https://supabase.com/docs)
- [Vercel Docs](https://vercel.com/docs)
- [MDN Web APIs](https://developer.mozilla.org/en-US/docs/Web/API)

### Comunidade

- [Next.js Discord](https://discord.gg/nextjs)
- [Supabase Discord](https://supabase.com/discord)
- [Vercel Discord](https://vercel.com/discord)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/nextjs)

### Suporte

- [Next.js GitHub Issues](https://github.com/vercel/next.js/issues)
- [Supabase GitHub Issues](https://github.com/supabase/supabase/issues)
- [Vercel Support](https://vercel.com/support)

---

## 🎓 Conclusão

Este troubleshooting guide cobre:

- ✅ **Problemas comuns** - Soluções para problemas frequentes
- ✅ **Debugging tools** - Ferramentas para identificar problemas
- ✅ **Logging** - Como adicionar logs úteis
- ✅ **Recursos** - Links para documentação e suporte

Com este guide, a equipe pode resolver problemas rapidamente e manter o projeto rodando suavemente. 🚀
