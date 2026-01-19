# 🧩 Componentes Críticos - Especificações Detalhadas

Este documento detalha os componentes críticos do sistema com especificações completas de implementação.

## 📋 Componentes Críticos

Existem 3 componentes críticos que requerem atenção especial:

1. **WorkoutPlayer.tsx** - Player principal de treinos
2. **Timer.tsx** - Timer com Web Workers
3. **ExerciseCard.tsx** - Card de exercício para drag-and-drop

---

## 🎮 1. WorkoutPlayer.tsx (🔴 CRÍTICO)

### Responsabilidades

- Gerenciar estado completo da execução do treino
- Controlar Wake Lock, Timer, Vibração
- Salvar progresso em IndexedDB com fallback para localStorage
- Sincronizar com Supabase via Background Sync quando online
- Lidar com interrupções (app background, conexão perdida)
- Feedback visual e auditivo para transições

### Props (TypeScript)

```typescript
interface WorkoutPlayerProps {
  studentWorkoutId: string;           // ID do treino atribuído ao aluno
  workoutSessionId?: string;           // ID da sessão existente (para continuar)
  onComplete?: (sessionData: SessionData) => void;
  onAbandon?: (reason: string) => void;
  onError?: (error: Error) => void;
}
```

### Estado Interno (Zustand Store)

```typescript
interface PlayerState {
  // Controle de execução
  currentExerciseIndex: number;
  currentSetIndex: number;
  phase: 'exercise' | 'rest' | 'completed' | 'abandoned';

  // Timer management
  timeRemaining: number;
  timerRunning: boolean;
  restDuration: number;

  // Hardware APIs
  vibrationEnabled: boolean;
  wakeLockActive: boolean;
  screenBrightness: number;

  // Offline/sync management
  offlineMode: boolean;
  syncStatus: 'pending' | 'syncing' | 'synced' | 'failed';
  lastSyncAttempt: Date | null;

  // Dados de execução
  setsCompleted: Record<string, {
    exerciseId: string;
    repsCompleted: number[];
    weightUsed: number;
    notes: string;
    timestamp: Date;
  }>;

  // Métricas de performance
  startTime: number;
  totalDuration: number;
  pauseCount: number;
  pauseDurations: number[];

  // UI state
  showInstructions: boolean;
  showNotesModal: boolean;
  currentNotes: string;
}
```

### Estrutura do Componente

```typescript
'use client'

import { useState, useEffect } from 'react'
import { create } from 'zustand'
import { useWakeLock } from '@/hooks/useWakeLock'
import { useTimerWorker } from '@/hooks/useTimerWorker'
import { useHaptic } from '@/hooks/useHaptic'
import { useBackgroundSync } from '@/hooks/useBackgroundSync'
import { useOfflineStorage } from '@/hooks/useOfflineStorage'
import { createClient } from '@/lib/supabase/client'

interface WorkoutPlayerProps {
  studentWorkoutId: string;
  workoutSessionId?: string;
  onComplete?: (sessionData: SessionData) => void;
  onAbandon?: (reason: string) => void;
  onError?: (error: Error) => void;
}

export function WorkoutPlayer({
  studentWorkoutId,
  workoutSessionId,
  onComplete,
  onAbandon,
  onError
}: WorkoutPlayerProps) {
  const { request: requestWakeLock, release: releaseWakeLock } = useWakeLock()
  const { time, start: startTimer, stop: stopTimer, reset: resetTimer } = useTimerWorker()
  const { heavyTap, success, warning } = useHaptic()
  const { addToSyncQueue } = useBackgroundSync()
  const { saveSession, getSession } = useOfflineStorage()
  const supabase = createClient()

  // ... implementation

  return (
    <div className="workout-player">
      {/* Player UI */}
    </div>
  )
}
```

### Fluxo de Execução

#### 1. Inicialização

```typescript
useEffect(() => {
  async function initialize() {
    try {
      // Carregar treino do cache (IndexedDB) ou Supabase
      let workout
      if (workoutSessionId) {
        const session = await getSession(workoutSessionId)
        if (session) {
          workout = session.workout
        }
      }

      if (!workout) {
        const { data } = await supabase
          .from('student_workouts')
          .select(`
            *,
            workouts (
              *,
              workout_exercises (
                *,
                exercises (*)
              )
            )
          `)
          .eq('id', studentWorkoutId)
          .single()

        workout = data.workouts
      }

      setWorkout(workout)
      setIsLoading(false)

      // Ativar Wake Lock
      await requestWakeLock()

    } catch (error) {
      onError?.(error as Error)
    }
  }

  initialize()
}, [studentWorkoutId, workoutSessionId])
```

#### 2. Execução do Exercício

```typescript
const startExercise = async () => {
  // Haptic feedback leve
  heavyTap()

  // Gravar timestamp de início
  const exerciseStartTime = Date.now()

  // Atualizar estado
  setPlayerState(prev => ({
    ...prev,
    setsCompleted: {
      ...prev.setsCompleted,
      [currentExercise.id]: {
        exerciseId: currentExercise.id,
        repsCompleted: [],
        weightUsed: currentExercise.weight_kg,
        notes: '',
        timestamp: new Date(exerciseStartTime)
      }
    }
  }))

  // Salvar progresso em IndexedDB
  await saveSession({
    id: sessionId,
    student_workout_id: studentWorkoutId,
    workout: workout,
    current_exercise_index: currentExerciseIndex,
    sets_completed: playerState.setsCompleted,
    status: 'in_progress'
  })
}
```

#### 3. Finalização de Série

```typescript
const completeSet = async (reps: number) => {
  // Haptic feedback médio
  heavyTap()

  // Gravar série
  const exerciseData = playerState.setsCompleted[currentExercise.id]
  exerciseData.repsCompleted.push(reps)

  // Salvar em IndexedDB
  await saveSession({
    id: sessionId,
    student_workout_id: studentWorkoutId,
    workout: workout,
    current_exercise_index: currentExerciseIndex,
    sets_completed: playerState.setsCompleted,
    status: 'in_progress'
  })

  // Iniciar timer de descanso no Web Worker
  const restDuration = currentExercise.rest_seconds || 60
  startTimer(restDuration)

  // Ativar Wake Lock se não estiver ativo
  await requestWakeLock()

  // Mudar fase para descanso
  setPlayerState(prev => ({
    ...prev,
    phase: 'rest',
    restDuration,
    timerRunning: true
  }))
}
```

#### 4. Timer de Descanso

```typescript
useEffect(() => {
  if (time === 0 && playerState.phase === 'rest') {
    // Ao final do descanso
    handleRestComplete()
  }
}, [time])

const handleRestComplete = async () => {
  // Vibração forte (Android) ou som + flash (iOS)
  heavyTap()
  success()

  // Transição automática para próximo exercício
  const nextExerciseIndex = currentExerciseIndex + 1

  if (nextExerciseIndex >= workout.workout_exercises.length) {
    // Treino completado
    completeWorkout()
  } else {
    // Próximo exercício
    setCurrentExerciseIndex(nextExerciseIndex)
    setPlayerState(prev => ({
      ...prev,
      currentSetIndex: 0,
      phase: 'exercise',
      timerRunning: false
    }))
  }

  // Gravar timestamp de término do descanso
  // ...
}
```

#### 5. Tratamento de Interrupções

```typescript
useEffect(() => {
  const handleVisibilityChange = async () => {
    if (document.visibilityState === 'hidden') {
      // App para background
      stopTimer()
      await releaseWakeLock()
    } else if (document.visibilityState === 'visible') {
      // App volta para foreground
      if (playerState.timerRunning) {
        startTimer(playerState.timeRemaining)
      }
      await requestWakeLock()
    }
  }

  document.addEventListener('visibilitychange', handleVisibilityChange)
  return () => {
    document.removeEventListener('visibilitychange', handleVisibilityChange)
  }
}, [playerState.timerRunning, playerState.timeRemaining])

useEffect(() => {
  const handleOnlineOffline = () => {
    const isOnline = navigator.onLine
    setOfflineMode(!isOnline)

    if (isOnline) {
      // Voltou online, tentar sincronizar
      triggerSync()
    }
  }

  window.addEventListener('online', handleOnlineOffline)
  window.addEventListener('offline', handleOnlineOffline)

  return () => {
    window.removeEventListener('online', handleOnlineOffline)
    window.removeEventListener('offline', handleOnlineOffline)
  }
}, [])
```

#### 6. Finalização do Treino

```typescript
const completeWorkout = async () => {
  // Mostrar resumo
  setPlayerState(prev => ({
    ...prev,
    phase: 'completed',
    totalDuration: Date.now() - playerState.startTime
  }))

  // Salvar sessão final em IndexedDB
  const sessionData: WorkoutSession = {
    id: sessionId,
    student_workout_id: studentWorkoutId,
    started_at: new Date(playerState.startTime),
    completed_at: new Date(),
    total_duration_seconds: Math.floor((Date.now() - playerState.startTime) / 1000),
    status: 'completed',
    offline_mode: offlineMode,
    sync_status: 'pending'
  }

  await saveSession(sessionData)

  // Agendar Background Sync
  await addToSyncQueue({
    action: 'create_session',
    table_name: 'workout_sessions',
    payload: sessionData
  })

  // Enviar notificação ao trainer
  await supabase.from('notifications').insert({
    user_id: trainerId,
    type: 'workout_completed',
    title: 'Treino completado',
    body: `O aluno ${studentName} completou o treino ${workout.name}`
  })

  // Liberar Wake Lock
  await releaseWakeLock()

  // Notificar completion
  onComplete?.(sessionData)
}
```

### UI Components

```typescript
return (
  <div className="workout-player h-screen flex flex-col bg-gray-900 text-white">
    {/* Área Central - Exercício */}
    <div className="flex-1 flex flex-col items-center justify-center p-4">
      {currentExercise && (
        <>
          <div className="w-full max-w-md mb-4">
            {/* Vídeo/Imagem do exercício */}
            {currentExercise.exercises.image_url && (
              <img
                src={currentExercise.exercises.image_url}
                alt={currentExercise.exercises.name}
                className="w-full h-64 object-cover rounded-lg"
              />
            )}
          </div>

          <h1 className="text-3xl font-bold mb-2">
            {currentExercise.exercises.name}
          </h1>

          <div className="text-gray-400 mb-4">
            Série {currentSetIndex + 1} de {currentExercise.sets} | {currentExercise.reps} reps
          </div>

          {/* Contador de Séries */}
          <div className="flex items-center gap-2 mb-4">
            {Array.from({ length: currentExercise.sets }).map((_, i) => (
              <div
                key={i}
                className={`w-8 h-8 rounded-full border-2 ${
                  i < currentSetIndex
                    ? 'bg-green-500 border-green-500'
                    : 'border-gray-600'
                }`}
              />
            ))}
          </div>
        </>
      )}
    </div>

    {/* Área de Controle */}
    <div className="p-4 bg-gray-800">
      {playerState.phase === 'exercise' ? (
        <button
          onClick={() => completeSet(currentExercise.reps)}
          className="w-full py-4 bg-green-600 hover:bg-green-700 rounded-lg text-xl font-bold transition-colors"
        >
          Série Completa
        </button>
      ) : (
        <div className="text-center">
          <div className="text-6xl font-bold mb-2">
            {Math.ceil(time / 60)}:{(time % 60).toString().padStart(2, '0')}
          </div>
          <div className="text-gray-400 mb-4">Descanso</div>
          <button
            onClick={skipRest}
            className="w-full py-2 bg-gray-600 hover:bg-gray-700 rounded-lg"
          >
            Pular Descanso
          </button>
        </div>
      )}
    </div>
  </div>
)
```

### Testes Críticos

```typescript
describe('WorkoutPlayer', () => {
  it('deve iniciar um treino e ativar Wake Lock', async () => {
    const { result } = renderHook(() => useWorkoutPlayer(), {
      wrapper: TestWrapper
    })

    await act(async () => {
      await result.current.startWorkout(workoutId)
    })

    expect(result.current.wakeLockActive).toBe(true)
    expect(result.current.phase).toBe('exercise')
  })

  it('deve completar uma série e iniciar timer de descanso', async () => {
    const { result } = renderHook(() => useWorkoutPlayer(), {
      wrapper: TestWrapper
    })

    await act(async () => {
      await result.current.startWorkout(workoutId)
      await result.current.completeSet(10)
    })

    expect(result.current.phase).toBe('rest')
    expect(result.current.timeRemaining).toBe(60)
  })

  it('deve salvar progresso em IndexedDB offline', async () => {
    const { result } = renderHook(() => useWorkoutPlayer(), {
      wrapper: TestWrapper
    })

    // Simular offline
    Object.defineProperty(navigator, 'onLine', { value: false })

    await act(async () => {
      await result.current.startWorkout(workoutId)
      await result.current.completeSet(10)
    })

    const session = await result.current.getSession(sessionId)
    expect(session).toBeDefined()
    expect(session.offlineMode).toBe(true)
  })

  it('deve syncronizar quando voltar online', async () => {
    const { result } = renderHook(() => useWorkoutPlayer(), {
      wrapper: TestWrapper
    })

    // Iniciar offline
    Object.defineProperty(navigator, 'onLine', { value: false })
    await act(async () => {
      await result.current.startWorkout(workoutId)
      await result.current.completeWorkout()
    })

    // Voltar online
    Object.defineProperty(navigator, 'onLine', { value: true })
    await act(async () => {
      await result.current.triggerSync()
    })

    expect(result.current.syncStatus).toBe('synced')
  })
})
```

---

## ⏱️ 2. Timer.tsx (🔴 CRÍTICO)

### Responsabilidades

- Exibir timer regressivo visual
- Atualizar a cada segundo
- Mudar cores conforme tempo (verde → amarelo → vermelho)
- Permitir pular descanso após 10 segundos

### Props

```typescript
interface TimerProps {
  seconds: number;
  isRunning: boolean;
  color?: 'green' | 'yellow' | 'red';
  onSkip?: () => void;
  showSkipButton?: boolean;
}
```

### Implementação

```typescript
'use client'

import { useEffect, useState } from 'react'

interface TimerProps {
  seconds: number;
  isRunning: boolean;
  color?: 'green' | 'yellow' | 'red';
  onSkip?: () => void;
  showSkipButton?: boolean;
}

export function Timer({
  seconds,
  isRunning,
  color = 'green',
  onSkip,
  showSkipButton = false
}: TimerProps) {
  const [displayTime, setDisplayTime] = useState(seconds)

  // Atualizar display
  useEffect(() => {
    setDisplayTime(seconds)
  }, [seconds])

  // Calcular cor baseada no tempo
  const getColor = () => {
    if (color !== 'green') return color
    if (displayTime <= 10) return 'red'
    if (displayTime <= 30) return 'yellow'
    return 'green'
  }

  const currentColor = getColor()

  return (
    <div className="timer flex flex-col items-center justify-center">
      {/* Timer Display */}
      <div className={`text-8xl font-bold transition-colors ${
        currentColor === 'green' ? 'text-green-500' :
        currentColor === 'yellow' ? 'text-yellow-500' :
        'text-red-500'
      }`}>
        {Math.floor(displayTime / 60)}:{(displayTime % 60).toString().padStart(2, '0')}
      </div>

      {/* Progress Bar */}
      <div className="w-full max-w-md h-2 bg-gray-700 rounded-full overflow-hidden">
        <div
          className={`h-full transition-all ${
            currentColor === 'green' ? 'bg-green-500' :
            currentColor === 'yellow' ? 'bg-yellow-500' :
            'bg-red-500'
          }`}
          style={{ width: `${(displayTime / seconds) * 100}%` }}
        />
      </div>

      {/* Skip Button */}
      {showSkipButton && (
        <button
          onClick={onSkip}
          className="mt-4 px-6 py-2 bg-gray-600 hover:bg-gray-700 rounded-lg transition-colors"
        >
          Pular Descanso
        </button>
      )}
    </div>
  )
}
```

### Testes

```typescript
describe('Timer', () => {
  it('deve exibir tempo formatado corretamente', () => {
    render(<Timer seconds={90} isRunning={false} />)

    expect(screen.getByText('1:30')).toBeInTheDocument()
  })

  it('deve mudar cor para vermelho quando tempo <= 10s', () => {
    render(<Timer seconds={5} isRunning={false} />)

    const timer = screen.getByText('0:05')
    expect(timer).toHaveClass('text-red-500')
  })

  it('deve mostrar botão de pular quando showSkipButton=true', () => {
    render(
      <Timer
        seconds={60}
        isRunning={false}
        onSkip={vi.fn()}
        showSkipButton={true}
      />
    )

    expect(screen.getByText('Pular Descanso')).toBeInTheDocument()
  })
})
```

---

## 🎴 3. ExerciseCard.tsx (Drag-and-Drop)

### Responsabilidades

- Exibir informações do exercício
- Suportar drag-and-drop
- Mostrar preview rápido do vídeo
- Editar exercícios existentes

### Props

```typescript
interface ExerciseCardProps {
  exercise: Exercise;
  index: number;
  onDelete?: (id: string) => void;
  onEdit?: (id: string) => void;
  isDragging?: boolean;
}
```

### Implementação

```typescript
'use client'

import { useDrag, useDrop } from 'react-dnd'
import { DndProvider } from 'react-dnd-html5-backend'
import { HTML5Backend } from 'react-dnd-html5-backend'

interface ExerciseCardProps {
  exercise: Exercise;
  index: number;
  onDelete?: (id: string) => void;
  onEdit?: (id: string) => void;
  isDragging?: boolean;
}

export function ExerciseCard({
  exercise,
  index,
  onDelete,
  onEdit,
  isDragging
}: ExerciseCardProps) {
  const [{ opacity }, drag] = useDrag({
    type: 'EXERCISE',
    item: { id: exercise.id, index },
    collect: (monitor) => ({
      opacity: monitor.isDragging() ? 0.5 : 1,
    }),
  })

  const [, drop] = useDrop({
    accept: 'EXERCISE',
    hover(item: { id: string; index: number }, monitor) {
      if (item.index === index) return

      const hoverBoundingRect = ref.current?.getBoundingClientRect()
      const hoverMiddleY = (hoverBoundingRect.bottom - hoverBoundingRect.top) / 2
      const clientOffset = monitor.getClientOffset()
      const hoverClientY = clientOffset.y - hoverBoundingRect.top

      // Apenas mover se mouse estiver acima ou abaixo do meio
      if (item.index < index && hoverClientY < hoverMiddleY) return
      if (item.index > index && hoverClientY > hoverMiddleY) return

      onMoveExercise(item.index, index)
      item.index = index
    },
  })

  const ref = useRef<HTMLDivElement>(null)
  drag(drop(ref))

  return (
    <div
      ref={ref}
      style={{ opacity }}
      className="exercise-card bg-white rounded-lg shadow p-4 mb-2 cursor-move"
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="text-2xl font-bold text-gray-400">
            {index + 1}
          </div>

          <div>
            <h3 className="font-semibold text-gray-900">
              {exercise.name}
            </h3>
            <div className="text-sm text-gray-600">
              {exercise.sets}x {exercise.reps} reps
              {exercise.rest_seconds && ` • ${exercise.rest_seconds}s descanso`}
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {onEdit && (
            <button
              onClick={() => onEdit(exercise.id)}
              className="p-2 text-gray-600 hover:text-blue-600"
            >
              <EditIcon size={20} />
            </button>
          )}
          {onDelete && (
            <button
              onClick={() => onDelete(exercise.id)}
              className="p-2 text-gray-600 hover:text-red-600"
            >
              <TrashIcon size={20} />
            </button>
          )}
        </div>
      </div>

      {exercise.description && (
        <p className="mt-2 text-sm text-gray-600">
          {exercise.description}
        </p>
      )}
    </div>
  )
}
```

### Testes

```typescript
describe('ExerciseCard', () => {
  it('deve renderizar informações do exercício', () => {
    const exercise = {
      id: '1',
      name: 'Supino Reto',
      sets: 3,
      reps: 10,
      rest_seconds: 60
    }

    render(
      <DndProvider backend={HTML5Backend}>
        <ExerciseCard exercise={exercise} index={0} />
      </DndProvider>
    )

    expect(screen.getByText('Supino Reto')).toBeInTheDocument()
    expect(screen.getByText('3x 10 reps • 60s descanso')).toBeInTheDocument()
  })

  it('deve chamar onDelete quando botão de deletar é clicado', () => {
    const onDelete = vi.fn()
    const exercise = { id: '1', name: 'Supino Reto', sets: 3, reps: 10 }

    render(
      <DndProvider backend={HTML5Backend}>
        <ExerciseCard exercise={exercise} index={0} onDelete={onDelete} />
      </DndProvider>
    )

    const deleteButton = screen.getByRole('button')
    fireEvent.click(deleteButton)

    expect(onDelete).toHaveBeenCalledWith('1')
  })
})
```

---

## 🎯 Best Practices

### 1. Performance

- ✅ Usar `useMemo` para cálculos pesados
- ✅ Evitar re-renders desnecessários
- ✅ Lazy loading de componentes grandes
- ✅ Otimizar listas com keys estáveis

### 2. Acessibilidade

- ✅ ARIA labels em todos os botões
- ✅ Suporte a teclado (tab, enter, space)
- ✅ Contraste de cores adequado
- ✅ Screen reader support

### 3. Testabilidade

- ✅ Componentes modulares e pequenos
- ✅ Dependências injetáveis
- ✅ Testes unitários isolados
- ✅ Mocks para APIs externas

### 4. TypeScript

- ✅ Tipos estritos para props
- ✅ Interfaces para dados complexos
- ✅ Type guards para validação
- ✅ Generics para reuso

---

## 🎓 Conclusão

Estes componentes críticos foram projetados para:

- ✅ **Performance** - Código otimizado e sem vazamentos de memória
- ✅ **Acessibilidade** - Interface acessível para todos
- ✅ **Testabilidade** - Cobertura completa de testes
- ✅ **Manutenibilidade** - Código limpo e bem documentado

A implementação cuidadosa destes componentes garante uma experiência de usuário excelente e confiável. 🚀
