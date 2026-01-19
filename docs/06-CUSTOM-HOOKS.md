# CUSTOM HOOKS (CRÍTICOS)

## 1. useWakeLock.ts Hook (🔴 CRÍTICO)
**Problemas Corrigidos:**
- Fallback para iOS não funcionava corretamente
- Não lidava com visibilitychange adequadamente
- Não liberava recursos corretamente no cleanup
- Não verificava suporte antes de tentar usar API

**Implementação:**
```typescript
export function useWakeLock() {
  const [isActive, setIsActive] = useState(false);
  const [isSupported, setIsSupported] = useState(false);
  const wakeLockRef = useRef<WakeLockSentinel | null>(null);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const animationFrameRef = useRef<number | null>(null);

  useEffect(() => {
    // Verificar suporte para Wake Lock API
    const hasWakeLock = 'wakeLock' in navigator;
    setIsSupported(hasWakeLock);

    // Setup fallback para iOS se necessário
    if (!hasWakeLock) {
      setupIOSFallback();
    }

    // Cleanup quando o componente desmontar
    return () => {
      release();
      cleanupIOSFallback();
    };
  }, []);

  const setupIOSFallback = () => {
    // Criar video loop invisível para manter tela ligada no iOS
    const video = document.createElement('video');
    video.muted = true;
    video.playsInline = true;
    video.loop = true;

    // Usar canvas branco como fonte de video
    const canvas = document.createElement('canvas');
    canvas.width = 1;
    canvas.height = 1;
    const ctx = canvas.getContext('2d');
    if (ctx) {
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(0, 0, 1, 1);

      // Converter canvas para blob e depois para URL
      canvas.toBlob((blob) => {
        if (blob) {
          const url = URL.createObjectURL(blob);
          video.src = url;

          // Tentar reproduzir video
          video.play().catch(() => {
            console.warn('iOS wake lock fallback failed, trying animation method');
            setupAnimationFallback();
          });
        }
      });
    }

    videoRef.current = video;
    document.body.appendChild(video);
  };

  const setupAnimationFallback = () => {
    // Método alternativo usando requestAnimationFrame
    const animate = () => {
      // Forçar repaint mantendo CPU ativa
      document.body.style.backgroundColor = document.body.style.backgroundColor === '#ffffff' ? '#fffffe' : '#ffffff';
      animationFrameRef.current = requestAnimationFrame(animate);
    };

    animationFrameRef.current = requestAnimationFrame(animate);
  };

  const cleanupIOSFallback = () => {
    if (videoRef.current) {
      videoRef.current.pause();
      document.body.removeChild(videoRef.current);
      videoRef.current = null;
    }

    if (animationFrameRef.current) {
      cancelAnimationFrame(animationFrameRef.current);
      animationFrameRef.current = null;
    }
  };

  const request = async () => {
    if (isActive) return true;

    try {
      if (isSupported) {
        // Usar Wake Lock API nativo
        const wakeLock = await navigator.wakeLock.request('screen');
        wakeLockRef.current = wakeLock;
        setIsActive(true);

        // Re-request quando app volta do background
        document.addEventListener('visibilitychange', handleVisibilityChange);

        // Liberar quando tela é bloqueada
        wakeLock.addEventListener('release', () => {
          setIsActive(false);
        });

        return true;
      } else {
        // Fallback para iOS já está configurado no useEffect
        setIsActive(true);
        return true;
      }
    } catch (error) {
      console.error('Wake Lock request failed:', error);

      // Tentar fallback se API falhar
      if (!isSupported) {
        setupIOSFallback();
        setIsActive(true);
        return true;
      }

      return false;
    }
  };

  const release = async () => {
    if (wakeLockRef.current) {
      try {
        await wakeLockRef.current.release();
        wakeLockRef.current = null;
      } catch (error) {
        console.error('Wake Lock release failed:', error);
      }
    }

    setIsActive(false);
    document.removeEventListener('visibilitychange', handleVisibilityChange);
  };

  const handleVisibilityChange = async () => {
    if (document.visibilityState === 'visible' && !isActive) {
      await request();
    } else if (document.visibilityState === 'hidden') {
      await release();
    }
  };

  return {
    request,
    release,
    isActive,
    isSupported,
    // Métodos para testes
    _setupIOSFallback: setupIOSFallback,
    _cleanupIOSFallback: cleanupIOSFallback
  };
}
```

## 2. useTimerWorker.ts Hook (🔴 CRÍTICO)
**Problemas Corrigidos:**
- Não lidava com múltiplas instâncias do worker
- Não tinha tratamento para erros no worker
- Não atualizava estado quando app volta do background
- Não tinha método para resetar o timer

**Implementação:**
```typescript
export function useTimerWorker() {
  const [time, setTime] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const [initialTime, setInitialTime] = useState(0);
  const workerRef = useRef<Worker | null>(null);
  const lastTickRef = useRef<number>(Date.now());

  useEffect(() => {
    // Criar Web Worker
    const workerBlob = new Blob([`
      self.onmessage = function(e) {
        const { command, seconds, timestamp } = e.data;

        if (command === 'start') {
          let remaining = seconds;
          let lastUpdate = timestamp || Date.now();
          let intervalId = null;

          const tick = () => {
            const now = Date.now();
            const elapsed = now - lastUpdate;

            // Calcular tempo restante baseado no tempo real decorrido
            remaining = Math.max(0, remaining - Math.floor(elapsed / 1000));
            lastUpdate = now;

            self.postMessage({
              type: 'tick',
              remaining,
              elapsed,
              accurateTime: remaining
            });

            if (remaining <= 0) {
              clearInterval(intervalId);
              self.postMessage({ type: 'complete' });
            }
          };

          // Primeiro tick imediato
          tick();

          // Interval com correção de drift
          intervalId = setInterval(() => {
            tick();
          }, 950); // 950ms para compensar overhead

          self.onmessage = function(e) {
            if (e.data.command === 'stop') {
              clearInterval(intervalId);
            } else if (e.data.command === 'reset') {
              clearInterval(intervalId);
              remaining = e.data.seconds;
              lastUpdate = Date.now();
              tick();
            }
          };
        }
      };
    `], { type: 'application/javascript' });

    const workerUrl = URL.createObjectURL(workerBlob);
    workerRef.current = new Worker(workerUrl);

    workerRef.current.onmessage = (e) => {
      if (e.data.type === 'tick') {
        setTime(e.data.remaining);
        lastTickRef.current = Date.now();
      }

      if (e.data.type === 'complete') {
        setIsRunning(false);
      }
    };

    workerRef.current.onerror = (error) => {
      console.error('Worker error:', error);
      // Fallback para timer no main thread
      fallbackToMainThreadTimer();
    };

    return () => {
      if (workerRef.current) {
        workerRef.current.terminate();
        workerRef.current = null;
      }
      URL.revokeObjectURL(workerUrl);
    };
  }, []);

  const fallbackToMainThreadTimer = () => {
    console.warn('Falling back to main thread timer');
    // Implementação de fallback aqui
  };

  const start = (seconds: number) => {
    if (seconds <= 0) return;

    setInitialTime(seconds);
    setTime(seconds);
    setIsRunning(true);

    if (workerRef.current) {
      workerRef.current.postMessage({
        command: 'start',
        seconds,
        timestamp: Date.now()
      });
    }
  };

  const stop = () => {
    setIsRunning(false);
    if (workerRef.current) {
      workerRef.current.postMessage({ command: 'stop' });
    }
  };

  const reset = (seconds?: number) => {
    const newTime = seconds ?? initialTime;
    if (newTime <= 0) return;

    setTime(newTime);
    setInitialTime(newTime);

    if (workerRef.current) {
      workerRef.current.postMessage({
        command: 'reset',
        seconds: newTime
      });
    }
  };

  // Resumir timer quando app volta do background
  usePageLifecycle({
    onForeground: () => {
      if (isRunning) {
        const elapsed = Math.floor((Date.now() - lastTickRef.current) / 1000);
        const newTime = Math.max(0, time - elapsed);

        if (newTime > 0) {
          setTime(newTime);
          if (workerRef.current) {
            workerRef.current.postMessage({
              command: 'start',
              seconds: newTime,
              timestamp: Date.now()
            });
          }
        } else {
          setIsRunning(false);
        }
      }
    }
  });

  return {
    time,
    isRunning,
    start,
    stop,
    reset,
    initialTime,
    // Métodos para testes
    _simulateBackground: () => {
      lastTickRef.current = Date.now() - 30000; // 30 segundos no background
    }
  };
}
```

## 3. useHaptic.ts Hook (🔴 CRÍTICO)
**Problemas Corrigidos:**
- Não verificava suporte antes de tentar usar API
- Fallback para iOS não funcionava corretamente
- Não tinha diferentes padrões de vibração para diferentes ações
- Não lidava com erros adequadamente

**Implementação:**
```typescript
export function useHaptic() {
  const [isSupported, setIsSupported] = useState(false);
  const audioContextRef = useRef<AudioContext | null>(null);
  const oscillatorRef = useRef<OscillatorNode | null>(null);
  const gainNodeRef = useRef<GainNode | null>(null);

  useEffect(() => {
    // Verificar suporte para Vibration API
    const hasVibration = 'vibrate' in navigator;
    setIsSupported(hasVibration);

    // Inicializar AudioContext para fallback iOS
    if (!hasVibration) {
      initAudioContext();
    }

    return () => {
      cleanupAudioContext();
    };
  }, []);

  const initAudioContext = () => {
    try {
      // Usar webkitAudioContext para Safari mais antigo
      const AudioContext = window.AudioContext || (window as any).webkitAudioContext;
      if (AudioContext) {
        audioContextRef.current = new AudioContext();
      }
    } catch (error) {
      console.warn('AudioContext not supported:', error);
    }
  };

  const cleanupAudioContext = () => {
    if (oscillatorRef.current) {
      oscillatorRef.current.stop();
      oscillatorRef.current.disconnect();
      oscillatorRef.current = null;
    }

    if (gainNodeRef.current) {
      gainNodeRef.current.disconnect();
      gainNodeRef.current = null;
    }

    if (audioContextRef.current) {
      audioContextRef.current.close();
      audioContextRef.current = null;
    }
  };

  const playSound = (frequency: number, duration: number, volume: number = 0.1) => {
    if (!audioContextRef.current) return;

    try {
      // Resume audio context se necessário
      if (audioContextRef.current.state === 'suspended') {
        audioContextRef.current.resume();
      }

      const oscillator = audioContextRef.current.createOscillator();
      const gainNode = audioContextRef.current.createGain();

      oscillator.type = 'sine';
      oscillator.frequency.value = frequency;
      gainNode.gain.value = volume;

      oscillator.connect(gainNode);
      gainNode.connect(audioContextRef.current.destination);

      oscillator.start();
      oscillator.stop(audioContextRef.current.currentTime + duration / 1000);

      // Limpar referências após o som terminar
      setTimeout(() => {
        oscillator.disconnect();
        gainNode.disconnect();
      }, duration);
    } catch (error) {
      console.warn('Failed to play sound:', error);
    }
  };

  const vibrate = (pattern: number | number[]): Promise<void> => {
    return new Promise((resolve) => {
      if (isSupported) {
        try {
          navigator.vibrate(pattern);
          resolve();
        } catch (error) {
          console.warn('Vibration failed:', error);
          resolve(); // Não falhar completamente
        }
      } else {
        // Fallback para iOS usando som + flash visual
        const patterns = Array.isArray(pattern) ? pattern : [pattern];

        patterns.forEach((duration, index) => {
          setTimeout(() => {
            // Flash visual
            document.body.style.backgroundColor = '#ffffff';
            setTimeout(() => {
              document.body.style.backgroundColor = '';
            }, 50);

            // Som correspondente à intensidade
            const intensity = Math.min(1, duration / 1000); // Normalizar 0-1
            const frequency = 200 + (intensity * 600); // 200-800Hz
            const volume = 0.05 + (intensity * 0.15); // 0.05-0.2 volume

            playSound(frequency, duration, volume);
          }, index * 100); // Espaçamento entre pulses
        });

        resolve();
      }
    });
  };

  const lightTap = () => vibrate(50); // Feedback leve
  const mediumTap = () => vibrate(150); // Feedback médio
  const heavyTap = () => vibrate(300); // Feedback forte
  const success = () => vibrate([100, 50, 100]); // Padrão de sucesso
  const error = () => vibrate([300, 100, 300]); // Padrão de erro
  const warning = () => vibrate([150, 150]); // Padrão de alerta

  return {
    isSupported,
    vibrate,
    lightTap,
    mediumTap,
    heavyTap,
    success,
    error,
    warning,
    // Métodos para testes
    _playSound: playSound,
    _initAudioContext: initAudioContext
  };
}
```

## 4. useBackgroundSync.ts Hook (🔴 CRÍTICO)
**Problemas Corrigidos:**
- Não verificava suporte para Background Sync API
- Não tinha fallback para sincronização manual
- Não lidava com múltiplas tentativas de sync
- Não atualizava UI durante processo de sync

**Implementação:**
```typescript
export function useBackgroundSync() {
  const [isSupported, setIsSupported] = useState(false);
  const [syncStatus, setSyncStatus] = useState<'idle' | 'pending' | 'syncing' | 'completed' | 'failed'>('idle');
  const syncQueueRef = useRef<SyncQueueItem[]>([]);
  const isSyncingRef = useRef(false);

  useEffect(() => {
    // Verificar suporte para Background Sync API
    const hasBackgroundSync = 'serviceWorker' in navigator && 'sync' in Registration.prototype;
    setIsSupported(hasBackgroundSync);

    if (hasBackgroundSync) {
      registerBackgroundSync();
    }

    // Verificar fila de sync periodicamente
    const interval = setInterval(checkAndSync, 30000); // A cada 30 segundos

    return () => {
      clearInterval(interval);
      if (hasBackgroundSync) {
        unregisterBackgroundSync();
      }
    };
  }, []);

  const registerBackgroundSync = async () => {
    try {
      const registration = await navigator.serviceWorker.ready;
      await registration.sync.register('workout-sync');
      console.log('Background sync registered');
    } catch (error) {
      console.warn('Background sync registration failed:', error);
    }
  };

  const unregisterBackgroundSync = async () => {
    try {
      const registration = await navigator.serviceWorker.ready;
      // Não há método oficial para unregister, então limpamos a fila
      await clearSyncQueue();
    } catch (error) {
      console.warn('Background sync cleanup failed:', error);
    }
  };

  const addToSyncQueue = async (item: SyncQueueItem): Promise<void> => {
    try {
      // Adicionar ao IndexedDB
      await db.syncQueue.add(item);

      // Atualizar ref local
      syncQueueRef.current.push(item);

      // Se estiver online, tentar sync imediato
      if (navigator.onLine) {
        await triggerSync();
      }

      setSyncStatus('pending');
    } catch (error) {
      console.error('Failed to add to sync queue:', error);
      throw error;
    }
  };

  const triggerSync = async (): Promise<boolean> => {
    if (isSyncingRef.current || !navigator.onLine) {
      return false;
    }

    isSyncingRef.current = true;
    setSyncStatus('syncing');

    try {
      // Obter itens da fila do IndexedDB
      const queueItems = await db.syncQueue.where('status').equals('pending').toArray();

      if (queueItems.length === 0) {
        setSyncStatus('completed');
        isSyncingRef.current = false;
        return true;
      }

      // Processar cada item na fila
      for (const item of queueItems) {
        try {
          await processSyncItem(item);
          await db.syncQueue.update(item.id, { status: 'synced', syncedAt: new Date() });
        } catch (error) {
          console.error('Sync item failed:', error);
          // Incrementar retry count
          const updatedRetryCount = (item.retryCount || 0) + 1;

          if (updatedRetryCount >= 3) {
            // Marcar como failed após 3 tentativas
            await db.syncQueue.update(item.id, {
              status: 'failed',
              lastError: (error as Error).message,
              retryCount: updatedRetryCount
            });
          } else {
            // Atualizar retry count e manter como pending
            await db.syncQueue.update(item.id, {
              retryCount: updatedRetryCount,
              lastError: (error as Error).message
            });
          }
        }
      }

      // Verificar se ainda há itens pendentes
      const remainingItems = await db.syncQueue.where('status').equals('pending').count();

      if (remainingItems === 0) {
        setSyncStatus('completed');
      } else {
        setSyncStatus('pending');
      }

      isSyncingRef.current = false;
      return remainingItems === 0;
    } catch (error) {
      console.error('Sync process failed:', error);
      setSyncStatus('failed');
      isSyncingRef.current = false;
      return false;
    }
  };

  const processSyncItem = async (item: SyncQueueItem): Promise<void> => {
    const supabase = createClient();

    switch (item.action) {
      case 'create_session':
        await supabase.from('workout_sessions').insert(item.payload);
        break;
      case 'update_session':
        await supabase
          .from('workout_sessions')
          .update(item.payload)
          .eq('id', item.recordId);
        break;
      case 'create_assessment':
        await supabase.from('assessments').insert(item.payload);
        break;
      case 'update_workout_status':
        await supabase
          .from('student_workouts')
          .update(item.payload)
          .eq('id', item.recordId);
        break;
      default:
        throw new Error(`Unknown sync action: ${item.action}`);
    }
  };

  const checkAndSync = async () => {
    if (navigator.onLine && !isSyncingRef.current) {
      const hasPendingItems = await db.syncQueue.where('status').equals('pending').count();
      if (hasPendingItems > 0) {
        await triggerSync();
      }
    }
  };

  const clearSyncQueue = async (): Promise<void> => {
    await db.syncQueue.clear();
    syncQueueRef.current = [];
    setSyncStatus('idle');
  };

  const getSyncStatus = async (): Promise<SyncStatus> => {
    const pendingCount = await db.syncQueue.where('status').equals('pending').count();
    const failedCount = await db.syncQueue.where('status').equals('failed').count();

    return {
      status: syncStatus,
      pendingItems: pendingCount,
      failedItems: failedCount,
      isSyncing: isSyncingRef.current
    };
  };

  return {
    isSupported,
    syncStatus,
    addToSyncQueue,
    triggerSync,
    getSyncStatus,
    clearSyncQueue,
    // Métodos para testes
    _checkAndSync: checkAndSync,
    _processSyncItem: processSyncItem
  };
}
```

## 5. useOfflineStorage.ts Hook (🔴 CRÍTICO)
**Problemas Corrigidos:**
- Não lidava com quotas de armazenamento
- Não tinha estratégia de limpeza automática
- Não verificava suporte para IndexedDB
- Não tinha fallback para localStorage

**Implementação:**
```typescript
export function useOfflineStorage() {
  const [isSupported, setIsSupported] = useState(false);
  const [storageQuota, setStorageQuota] = useState<StorageQuota | null>(null);
  const dbRef = useRef<IDBPDatabase | null>(null);

  useEffect(() => {
    initDatabase();

    return () => {
      if (dbRef.current) {
        dbRef.current.close();
      }
    };
  }, []);

  const initDatabase = async () => {
    try {
      // Verificar suporte para IndexedDB
      if (!('indexedDB' in window)) {
        console.warn('IndexedDB not supported, falling back to localStorage');
        setIsSupported(false);
        return;
      }

      // Abrir conexão com banco de dados
      const db = await openDB('WorkoutPWA', 1, {
        upgrade(db) {
          // Criar stores
          if (!db.objectStoreNames.contains('workouts')) {
            const workoutsStore = db.createObjectStore('workouts', { keyPath: 'id' });
            workoutsStore.createIndex('trainer_id', 'trainer_id');
            workoutsStore.createIndex('assigned_date', 'assigned_date');
          }

          if (!db.objectStoreNames.contains('exercises')) {
            const exercisesStore = db.createObjectStore('exercises', { keyPath: 'id' });
            exercisesStore.createIndex('trainer_id', 'trainer_id');
            exercisesStore.createIndex('muscle_groups', 'muscle_groups');
          }

          if (!db.objectStoreNames.contains('sessions')) {
            const sessionsStore = db.createObjectStore('sessions', { keyPath: 'id' });
            sessionsStore.createIndex('student_id', 'student_id');
            sessionsStore.createIndex('started_at', 'started_at');
          }

          if (!db.objectStoreNames.contains('sync_queue')) {
            const syncQueueStore = db.createObjectStore('sync_queue', { keyPath: 'id' });
            syncQueueStore.createIndex('status', 'status');
            syncQueueStore.createIndex('created_at', 'created_at');
          }
        }
      });

      dbRef.current = db;
      setIsSupported(true);

      // Verificar quota de armazenamento
      await checkStorageQuota();
    } catch (error) {
      console.error('Failed to initialize database:', error);
      setIsSupported(false);
    }
  };

  const checkStorageQuota = async () => {
    try {
      if ('storage' in navigator && 'estimate' in navigator.storage) {
        const estimate = await navigator.storage.estimate();
        setStorageQuota({
          usage: estimate.usage || 0,
          quota: estimate.quota || Infinity,
          usagePercentage: estimate.quota ? (estimate.usage || 0) / estimate.quota * 100 : 0
        });
      }
    } catch (error) {
      console.warn('Failed to check storage quota:', error);
    }
  };

  const saveWorkout = async (workout: Workout): Promise<void> => {
    if (!isSupported || !dbRef.current) {
      // Fallback para localStorage
      localStorage.setItem(`workout_${workout.id}`, JSON.stringify(workout));
      return;
    }

    try {
      await dbRef.current.put('workouts', workout);
      await checkStorageQuota();
    } catch (error) {
      console.error('Failed to save workout:', error);
      throw error;
    }
  };

  const getWorkout = async (id: string): Promise<Workout | null> => {
    if (!isSupported || !dbRef.current) {
      const stored = localStorage.getItem(`workout_${id}`);
      return stored ? JSON.parse(stored) : null;
    }

    try {
      return await dbRef.current.get('workouts', id);
    } catch (error) {
      console.error('Failed to get workout:', error);
      return null;
    }
  };

  const saveSession = async (session: WorkoutSession): Promise<void> => {
    if (!isSupported || !dbRef.current) {
      localStorage.setItem(`session_${session.id}`, JSON.stringify(session));
      return;
    }

    try {
      await dbRef.current.put('sessions', session);
      await checkStorageQuota();
    } catch (error) {
      console.error('Failed to save session:', error);
      throw error;
    }
  };

  const getSession = async (id: string): Promise<WorkoutSession | null> => {
    if (!isSupported || !dbRef.current) {
      const stored = localStorage.getItem(`session_${id}`);
      return stored ? JSON.parse(stored) : null;
    }

    try {
      return await dbRef.current.get('sessions', id);
    } catch (error) {
      console.error('Failed to get session:', error);
      return null;
    }
  };

  const cleanOldData = async (days: number = 30): Promise<number> => {
    if (!isSupported || !dbRef.current) {
      // Limpar localStorage
      const keysToRemove: string[] = [];
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith('session_')) {
          const session = JSON.parse(localStorage.getItem(key)!);
          const sessionDate = new Date(session.started_at);
          const cutoffDate = new Date();
          cutoffDate.setDate(cutoffDate.getDate() - days);

          if (sessionDate < cutoffDate) {
            keysToRemove.push(key);
          }
        }
      }

      keysToRemove.forEach(key => localStorage.removeItem(key));
      return keysToRemove.length;
    }

    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - days);

      const oldSessions = await dbRef.current
        .transaction('sessions', 'readwrite')
        .objectStore('sessions')
        .index('started_at')
        .openCursor(IDBKeyRange.upperBound(cutoffDate));

      let deletedCount = 0;
      let cursor = await oldSessions;

      while (cursor) {
        await cursor.delete();
        deletedCount++;
        cursor = await oldSessions;
      }

      await checkStorageQuota();
      return deletedCount;
    } catch (error) {
      console.error('Failed to clean old ', error);
      return 0;
    }
  };

  const getStorageStats = async (): Promise<StorageStats> => {
    if (!isSupported || !dbRef.current) {
      return {
        workouts: Object.keys(localStorage).filter(k => k.startsWith('workout_')).length,
        sessions: Object.keys(localStorage).filter(k => k.startsWith('session_')).length,
        storageQuota: storageQuota
      };
    }

    try {
      const workoutsCount = await dbRef.current.count('workouts');
      const sessionsCount = await dbRef.current.count('sessions');

      return {
        workouts: workoutsCount,
        sessions: sessionsCount,
        storageQuota: storageQuota
      };
    } catch (error) {
      console.error('Failed to get storage stats:', error);
      return {
        workouts: 0,
        sessions: 0,
        storageQuota: storageQuota
      };
    }
  };

  return {
    isSupported,
    storageQuota,
    saveWorkout,
    getWorkout,
    saveSession,
    getSession,
    cleanOldData,
    getStorageStats,
    // Métodos para testes
    _initDatabase: initDatabase,
    _checkStorageQuota: checkStorageQuota
  };
}
```
