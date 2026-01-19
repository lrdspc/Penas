# COMPONENTES CRÍTICOS - ESPECIFICAÇÕES DETALHADAS

## 1. WorkoutPlayer.tsx (🔴 CRÍTICO)
**Responsabilidades:**
- Gerenciar estado completo da execução do treino
- Controlar Wake Lock, Timer, Vibração
- Salvar progresso em IndexedDB com fallback para localStorage
- Sincronizar com Supabase via Background Sync quando online
- Lidar com interrupções (app background, conexão perdida)
- Feedback visual e auditivo para transições

**Props (TypeScript):**
```typescript
interface WorkoutPlayerProps {
  studentWorkoutId: string;           // ID do treino atribuído ao aluno
  workoutSessionId?: string;           // ID da sessão existente (para continuar)
  onComplete?: (sessionData: SessionData) => void;
  onAbandon?: (reason: string) => void;
  onError?: (error: Error) => void;
}
```

**Estado Interno (Zustand Store):**
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

**Fluxo de Execução:**
1. **Inicialização:**
   - Carregar treino do cache (IndexedDB) ou Supabase
   - Verificar modo offline
   - Inicializar Web Worker para timer
   - Ativar Wake Lock
   - Inicializar Haptic API

2. **Execução do Exercício:**
   - Mostrar exercício atual com vídeo/instruções
   - Permitir ajuste de peso antes de iniciar
   - Ao tocar "Iniciar Série":
     - Gravar timestamp de início
     - Iniciar contagem de repetições (manual ou automática)
     - Ativar haptic feedback leve em cada repetição

3. **Finalização de Série:**
   - Ao tocar "Série Completa":
     - Haptic feedback médio
     - Gravar dados da série em IndexedDB
     - Iniciar timer de descanso no Web Worker
     - Ativar Wake Lock se não estiver ativo

4. **Timer de Descanso:**
   - Contagem regressiva em thread separada
   - Atualização visual a cada segundo
   - Botão "Pular Descanso" aparece após 10 segundos
   - Ao final do tempo:
     - Haptic feedback forte (Android) ou som + flash (iOS)
     - Transição automática para próximo exercício
     - Gravar timestamp de término do descanso

5. **Tratamento de Interrupções:**
   - **App para background:** Pausar timer, liberar Wake Lock temporariamente
   - **App volta para foreground:** Retomar timer, reativar Wake Lock
   - **Conexão perdida:** Continuar offline, enfileirar dados para sincronização
   - **Bateria < 15%:** Alerta visual, sugerir conclusão rápida

6. **Finalização do Treino:**
   - Mostrar resumo completo:
     - Tempo total
     - Séries completadas vs planejado
     - Peso médio utilizado
     - Calorias estimadas
   - Opções:
     - "Finalizar Treino" (completo)
     - "Treino Incompleto" (com motivo)
     - "Continuar Depois" (salvar progresso)
   - Ao finalizar:
     - Salvar sessão em IndexedDB
     - Agendar Background Sync
     - Enviar notificação ao trainer
     - Liberar Wake Lock

**Testes Críticos:**
✅ **Timer preciso:** Teste com 600 segundos (10min), erro máximo 1 segundo
✅ **Wake Lock:** Verificar que tela não desliga durante execução
✅ **Vibração Android:** Testar todos os patterns (light, medium, heavy)
✅ **Fallback iOS:** Testar som + flash quando vibração não disponível
✅ **Offline mode:** Simular desconexão durante treino, verificar salvamento
✅ **Background Sync:** Testar sincronização quando voltar online
✅ **App lifecycle:** Testar pausar/resumir app durante timer
✅ **Battery optimization:** Testar em modo de economia de bateria
✅ **Memory usage:** Verificar vazamento de memória em sessões longas
✅ **Error handling:** Simular falhas no IndexedDB/Supabase
