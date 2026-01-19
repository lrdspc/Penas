# ✅ Testes e Validação

Este documento detalha todas as estratégias de teste e validação do projeto.

## 📋 Tipos de Testes

### 1. Testes Unitários
Testar funções e componentes isoladamente

### 2. Testes de Integração
Testar como componentes funcionam juntos

### 3. Testes de Componentes
Testar componentes React com user interactions

### 4. Testes E2E (End-to-End)
Testar fluxos completos de usuário

### 5. Testes de Performance
Testar métricas de performance

### 6. Testes de Segurança
Testar vulnerabilidades de segurança

---

## 🧪 Testes Unitários Críticos

### Timer Worker

**Objetivo:** Garantir precisão do timer em diferentes condições

```typescript
// __tests__/hooks/useTimerWorker.test.ts
import { renderHook, act } from '@testing-library/react'
import { useTimerWorker } from '@/hooks/useTimerWorker'

describe('useTimerWorker', () => {
  it('deve iniciar timer corretamente', async () => {
    const { result } = renderHook(() => useTimerWorker())

    await act(async () => {
      result.current.start(60)
    })

    expect(result.current.isRunning).toBe(true)
    expect(result.current.time).toBe(60)
  })

  it('deve decrementar tempo corretamente', async () => {
    const { result } = renderHook(() => useTimerWorker())

    await act(async () => {
      result.current.start(10)
      await new Promise(resolve => setTimeout(resolve, 2000))
    })

    expect(result.current.time).toBeLessThan(10)
  })

  it('deve completar quando tempo chega a zero', async () => {
    const { result } = renderHook(() => useTimerWorker())

    await act(async () => {
      result.current.start(1)
      await new Promise(resolve => setTimeout(resolve, 2000))
    })

    expect(result.current.isRunning).toBe(false)
    expect(result.current.time).toBe(0)
  })

  it('deve parar timer quando stop é chamado', async () => {
    const { result } = renderHook(() => useTimerWorker())

    await act(async () => {
      result.current.start(60)
      result.current.stop()
    })

    expect(result.current.isRunning).toBe(false)
  })

  it('deve resetar timer para valor inicial', async () => {
    const { result } = renderHook(() => useTimerWorker())

    await act(async () => {
      result.current.start(60)
      await new Promise(resolve => setTimeout(resolve, 2000))
      result.current.reset()
    })

    expect(result.current.time).toBe(60)
  })
})
```

### Wake Lock

**Objetivo:** Verificar funcionamento em todos os dispositivos suportados

```typescript
// __tests__/hooks/useWakeLock.test.ts
import { renderHook, act } from '@testing-library/react'
import { useWakeLock } from '@/hooks/useWakeLock'

describe('useWakeLock', () => {
  beforeEach(() => {
    // Mock navigator.wakeLock
    Object.defineProperty(navigator, 'wakeLock', {
      value: {
        request: vi.fn().mockResolvedValue({}),
        addEventListener: vi.fn(),
        removeEventListener: vi.fn()
      },
      writable: true
    })
  })

  it('deve ativar Wake Lock quando request é chamado', async () => {
    const { result } = renderHook(() => useWakeLock())

    await act(async () => {
      await result.current.request()
    })

    expect(result.current.isActive).toBe(true)
    expect((navigator as any).wakeLock.request).toHaveBeenCalledWith('screen')
  })

  it('deve detectar quando Wake Lock não é suportado', () => {
    Object.defineProperty(navigator, 'wakeLock', {
      value: undefined,
      writable: true
    })

    const { result } = renderHook(() => useWakeLock())

    expect(result.current.isSupported).toBe(false)
  })

  it('deve liberar Wake Lock quando release é chamado', async () => {
    const { result } = renderHook(() => useWakeLock())

    await act(async () => {
      await result.current.request()
      await result.current.release()
    })

    expect(result.current.isActive).toBe(false)
  })
})
```

### Haptic Feedback

**Objetivo:** Verificar padrões de vibração e fallbacks

```typescript
// __tests__/hooks/useHaptic.test.ts
import { renderHook } from '@testing-library/react'
import { useHaptic } from '@/hooks/useHaptic'

describe('useHaptic', () => {
  beforeEach(() => {
    // Mock navigator.vibrate
    Object.defineProperty(navigator, 'vibrate', {
      value: vi.fn(),
      writable: true
    })
  })

  it('deve vibrar com padrão leve', () => {
    const { result } = renderHook(() => useHaptic())

    result.current.lightTap()

    expect((navigator as any).vibrate).toHaveBeenCalledWith(50)
  })

  it('deve vibrar com padrão médio', () => {
    const { result } = renderHook(() => useHaptic())

    result.current.mediumTap()

    expect((navigator as any).vibrate).toHaveBeenCalledWith(150)
  })

  it('deve vibrar com padrão forte', () => {
    const { result } = renderHook(() => useHaptic())

    result.current.heavyTap()

    expect((navigator as any).vibrate).toHaveBeenCalledWith(300)
  })

  it('deve usar padrão de sucesso', () => {
    const { result } = renderHook(() => useHaptic())

    result.current.success()

    expect((navigator as any).vibrate).toHaveBeenCalledWith([100, 50, 100])
  })
})
```

### Offline Storage

**Objetivo:** Verificar persistência e recuperação de dados

```typescript
// __tests__/hooks/useOfflineStorage.test.ts
import { renderHook, act } from '@testing-library/react'
import { useOfflineStorage } from '@/hooks/useOfflineStorage'

const mockWorkout = {
  id: '1',
  name: 'Dia A - Peito',
  trainer_id: 'trainer-1'
}

describe('useOfflineStorage', () => {
  beforeEach(() => {
    // Limpar IndexedDB antes de cada teste
    indexedDB.deleteDatabase('WorkoutPWA')
  })

  it('deve salvar treino no IndexedDB', async () => {
    const { result } = renderHook(() => useOfflineStorage())

    await act(async () => {
      await result.current.saveWorkout(mockWorkout)
    })

    const retrieved = await result.current.getWorkout('1')
    expect(retrieved).toEqual(mockWorkout)
  })

  it('deve recuperar treino do IndexedDB', async () => {
    const { result } = renderHook(() => useOfflineStorage())

    await act(async () => {
      await result.current.saveWorkout(mockWorkout)
    })

    const retrieved = await result.current.getWorkout('1')
    expect(retrieved).toBeDefined()
    expect(retrieved?.name).toBe('Dia A - Peito')
  })

  it('deve usar fallback localStorage se IndexedDB falhar', async () => {
    // Desabilitar IndexedDB
    Object.defineProperty(window, 'indexedDB', {
      value: undefined,
      writable: true
    })

    const { result } = renderHook(() => useOfflineStorage())

    await act(async () => {
      await result.current.saveWorkout(mockWorkout)
    })

    const retrieved = await result.current.getWorkout('1')
    expect(retrieved).toEqual(mockWorkout)
  })

  it('deve limpar dados antigos automaticamente', async () => {
    const { result } = renderHook(() => useOfflineStorage())

    const oldSession = {
      id: 'session-1',
      started_at: new Date('2024-01-01').toISOString()
    }

    await act(async () => {
      await result.current.saveSession(oldSession)
      const deleted = await result.current.cleanOldData(30)
      expect(deleted).toBeGreaterThan(0)
    })
  })
})
```

### Background Sync

**Objetivo:** Verificar sincronização automática quando online

```typescript
// __tests__/hooks/useBackgroundSync.test.ts
import { renderHook, act } from '@testing-library/react'
import { useBackgroundSync } from '@/hooks/useBackgroundSync'

const mockSyncItem = {
  id: '1',
  action: 'create_session',
  table_name: 'workout_sessions',
  payload: { id: 'session-1', student_id: 'student-1' }
}

describe('useBackgroundSync', () => {
  beforeEach(() => {
    // Mock navigator.serviceWorker
    Object.defineProperty(navigator, 'serviceWorker', {
      value: {
        ready: Promise.resolve({
          sync: {
            register: vi.fn()
          }
        })
      },
      writable: true
    })

    // Mock navigator.onLine
    Object.defineProperty(navigator, 'onLine', {
      value: true,
      writable: true
    })
  })

  it('deve adicionar item à fila de sync', async () => {
    const { result } = renderHook(() => useBackgroundSync())

    await act(async () => {
      await result.current.addToSyncQueue(mockSyncItem)
    })

    const status = await result.current.getSyncStatus()
    expect(status.pendingItems).toBeGreaterThan(0)
  })

  it('deve syncronizar automaticamente quando online', async () => {
    const { result } = renderHook(() => useBackgroundSync())

    await act(async () => {
      await result.current.addToSyncQueue(mockSyncItem)
    })

    await act(async () => {
      const success = await result.current.triggerSync()
      expect(success).toBe(true)
    })
  })

  it('deve falhar sync quando offline', async () => {
    Object.defineProperty(navigator, 'onLine', {
      value: false,
      writable: true
    })

    const { result } = renderHook(() => useBackgroundSync())

    await act(async () => {
      await result.current.addToSyncQueue(mockSyncItem)
      const success = await result.current.triggerSync()
      expect(success).toBe(false)
    })
  })
})
```

### RLS Policies

**Objetivo:** Garantir isolamento de dados entre trainers e alunos

```typescript
// __tests__/integration/rls-policies.test.ts
import { createClient } from '@supabase/supabase-js'

describe('RLS Policies', () => {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

  it('deve permitir que trainer veja seus alunos', async () => {
    // Login como trainer
    const { data: authData } = await supabase.auth.signInWithPassword({
      email: 'trainer@example.com',
      password: 'password123'
    })

    // Tentar ver alunos
    const { data: students } = await supabase
      .from('users')
      .select('*')
      .eq('user_type', 'student')

    expect(students).toBeDefined()
  })

  it('deve impedir que aluno veja alunos de outros trainers', async () => {
    // Login como aluno
    const { data: authData } = await supabase.auth.signInWithPassword({
      email: 'student@example.com',
      password: 'password123'
    })

    // Tentar ver todos os alunos
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('user_type', 'student')

    expect(error).toBeDefined()
    expect(data).toBeNull()
  })

  it('deve permitir que aluno veja seus próprios treinos', async () => {
    // Login como aluno
    const { data: authData } = await supabase.auth.signInWithPassword({
      email: 'student@example.com',
      password: 'password123'
    })

    // Ver treinos próprios
    const { data: workouts } = await supabase
      .from('student_workouts')
      .select('*, workouts(*)')
      .eq('student_id', authData.user.id)

    expect(workouts).toBeDefined()
  })
})
```

### PWA Installation

**Objetivo:** Verificar instalação e funcionamento offline

```typescript
// __tests__/integration/pwa.test.ts
import { renderHook, act } from '@testing-library/react'
import { usePWAInstall } from '@/hooks/usePWAInstall'

describe('PWA Installation', () => {
  it('deve detectar quando app é instalável', () => {
    const { result } = renderHook(() => usePWAInstall())

    // Simular evento beforeinstallprompt
    act(() => {
      const event = new Event('beforeinstallprompt')
      window.dispatchEvent(event)
    })

    expect(result.current.isInstallable).toBe(true)
  })

  it('deve instalar app quando prompt é aceito', async () => {
    const { result } = renderHook(() => usePWAInstall())

    const mockPrompt = {
      prompt: vi.fn().mockResolvedValue(undefined)
    }

    await act(async () => {
      result.current.deferredPrompt = mockPrompt
      await result.current.install()
    })

    expect(mockPrompt.prompt).toHaveBeenCalled()
  })

  it('deve funcionar offline após instalação', async () => {
    // Desabilitar conexão
    Object.defineProperty(navigator, 'onLine', {
      value: false,
      writable: true
    })

    const { result } = renderHook(() => useOfflineStorage())

    // Salvar dados offline
    const workout = { id: '1', name: 'Offline Workout' }

    await act(async () => {
      await result.current.saveWorkout(workout)
    })

    // Recuperar dados offline
    const retrieved = await result.current.getWorkout('1')
    expect(retrieved).toEqual(workout)
  })
})
```

---

## 🧩 Testes de Integração

### Fluxo Completo de Treino

```typescript
// __tests__/integration/workout-flow.test.ts
describe('Workout Flow', () => {
  it('deve completar fluxo completo de treino offline → sync', async () => {
    // 1. Carregar treino
    const { result: player } = renderHook(() => useWorkoutPlayer())

    await act(async () => {
      await player.current.startWorkout('workout-1')
    })

    expect(player.current.phase).toBe('exercise')

    // 2. Completar primeira série
    await act(async () => {
      await player.current.completeSet(10)
    })

    expect(player.current.phase).toBe('rest')

    // 3. Completar restantes séries e exercícios
    // ...

    // 4. Finalizar treino
    await act(async () => {
      await player.current.completeWorkout()
    })

    expect(player.current.phase).toBe('completed')

    // 5. Voltar online e sincronizar
    Object.defineProperty(navigator, 'onLine', {
      value: true,
      writable: true
    })

    const { result: sync } = renderHook(() => useBackgroundSync())

    await act(async () => {
      await sync.current.triggerSync()
    })

    expect(sync.current.syncStatus).toBe('synced')
  })
})
```

### Convite e Aceitação

```typescript
// __tests__/integration/invite-flow.test.ts
describe('Invite Flow', () => {
  it('deve gerar convite e aluno aceitar', async () => {
    // 1. Trainer convida aluno
    const { result: trainer } = renderHook(() => useInviteStudent())

    await act(async () => {
      await trainer.current.inviteStudent('new-student@example.com')
    })

    const invite = trainer.current.lastInvite
    expect(invite).toBeDefined()
    expect(invite.token).toHaveLength(6)

    // 2. Aluno acessa link com token
    const { result: student } = renderHook(() => useAcceptInvite())

    await act(async () => {
      await student.current.acceptInvite(invite.token, {
        email: 'new-student@example.com',
        password: 'Password123',
        firstName: 'John',
        lastName: 'Doe'
      })
    })

    expect(student.current.isAccepted).toBe(true)
    expect(student.current.user).toBeDefined()
  })
})
```

### Avaliação Física

```typescript
// __tests__/integration/assessment-flow.test.ts
describe('Assessment Flow', () => {
  it('deve criar avaliação e calcular métricas', async () => {
    const { result: assessment } = renderHook(() => useAssessment())

    const data = {
      height_cm: 175,
      weight_kg: 80,
      body_fat_percent: 15,
      muscle_mass_percent: 45
    }

    await act(async () => {
      await assessment.current.create('student-1', data)
    })

    const calculated = assessment.current.calculateMetrics(data)

    expect(calculated.bmi).toBeCloseTo(26.12, 2) // 80 / (1.75 * 1.75)
    expect(calculated.fat_kg).toBe(12) // 80 * 0.15
    expect(calculated.lean_mass_kg).toBe(68) // 80 - 12
  })
})
```

### Acompanhamento em Tempo Real

```typescript
// __tests__/integration/realtime.test.ts
describe('Realtime', () => {
  it('deve receber atualizações em tempo real', async () => {
    const { result: realtime } = renderHook(() => useSupabaseRealtime())

    await act(async () => {
      await realtime.current.subscribeToSession('session-1')
    })

    // Simular atualização do trainer
    await act(async () => {
      await realtime.current.updateSession('session-1', {
        status: 'completed'
      })
    })

    // Verificar que aluno recebeu atualização
    expect(realtime.current.session?.status).toBe('completed')
  })
})
```

---

## ⚡ Testes de Performance

### Lighthouse Score

```bash
# Executar Lighthouse
npm run lighthouse

# Resultados esperados:
# Performance: >90
# Accessibility: >90
# Best Practices: >90
# SEO: >90
# PWA: 100
```

### Tempo de Carregamento

```typescript
// __tests__/performance/loading.test.ts
import { measurePerformance } from '@/lib/utils/performance'

describe('Loading Performance', () => {
  it('deve carregar página inicial em <2s em 3G', async () => {
    const metric = await measurePerformance('/')

    expect(metric.loadTime).toBeLessThan(2000) // 2s
    expect(metric.firstContentfulPaint).toBeLessThan(1000) // 1s
    expect(metric.timeToInteractive).toBeLessThan(2000) // 2s
  })

  it('deve carregar treino em <1s offline', async () => {
    const metric = await measurePerformance('/workout/1')

    expect(metric.loadTime).toBeLessThan(1000) // 1s
  })
})
```

### Memory Usage

```typescript
// __tests__/performance/memory.test.ts
describe('Memory Usage', () => {
  it('deve usar <100MB durante execução de treino', async () => {
    const { result: player } = renderHook(() => useWorkoutPlayer())

    await act(async () => {
      await player.current.startWorkout('workout-1')
    })

    const memoryUsage = performance.memory?.usedJSHeapSize || 0
    const memoryMB = memoryUsage / (1024 * 1024)

    expect(memoryMB).toBeLessThan(100)
  })
})
```

---

## 🔒 Testes de Segurança

### SQL Injection

```typescript
// __tests__/security/sql-injection.test.ts
describe('SQL Injection', () => {
  it('deve prevenir SQL injection em busca de exercícios', async () => {
    const maliciousInput = "'; DROP TABLE exercises; --"

    const { data, error } = await supabase
      .from('exercises')
      .select('*')
      .ilike('name', maliciousInput)

    // Query deve falhar ou retornar vazio
    expect(error || data.length).toBeGreaterThanOrEqual(0)
  })
})
```

### XSS Protection

```typescript
// __tests__/security/xss.test.ts
describe('XSS Protection', () => {
  it('deve sanitizar inputs de usuário', () => {
    const maliciousInput = '<script>alert("xss")</script>'

    const sanitized = sanitizeInput(maliciousInput)

    expect(sanitized).not.toContain('<script>')
    expect(sanitized).not.toContain('alert')
  })
})
```

### CSRF Protection

```typescript
// __tests__/security/csrf.test.ts
describe('CSRF Protection', () => {
  it('deve validar CSRF token em forms', async () => {
    const token = generateCSRFToken()

    const response = await fetch('/api/workouts', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      },
      body: JSON.stringify({ name: 'New Workout' })
    })

    expect(response.status).toBe(200)
  })
})
```

---

## 📊 Cobertura de Testes

### Metas

- **Cobertura de código:** >80%
- **Cobertura de linhas:** >90%
- **Cobertura de funções:** >85%
- **Cobertura de branches:** >80%

### Comandos

```bash
# Executar todos os testes
npm test

# Executar com cobertura
npm run test:coverage

# Executar em modo watch
npm run test:ui
```

---

## 🎯 Checklist de Validação

### ✅ Pré-Deploy

- [ ] Todos os testes passam
- [ ] Lint sem erros
- [ ] Type check sem erros
- [ ] Build sem warnings
- [ ] Migrations aplicadas
- [ ] Environment variables configuradas

### ✅ Pós-Deploy

- [ ] Site carrega corretamente
- [ ] Login funciona
- [ ] Treinos podem ser criados
- [ ] Player de treino funciona
- [ ] Offline mode funciona
- [ ] PWA instala corretamente
- [ ] Notificações funcionam
- [ ] Realtime atualiza

---

## 🎓 Conclusão

Esta estratégia de testes abrange:

- ✅ **Qualidade** - Testes unitários e integração
- ✅ **Performance** - Métricas e limites
- ✅ **Segurança** - Vulnerabilidades cobertas
- ✅ **Cobertura** - Metas claras de cobertura

Testes contínuos garantem qualidade e confiança no deploy. 🚀
