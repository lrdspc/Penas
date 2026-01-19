import { useState, useEffect, useRef } from 'react';
import { createClient } from '@/lib/supabase/client';

export type SyncStatus = 'idle' | 'syncing' | 'completed' | 'failed';

export interface SyncQueueItem {
  id: string;
  action: 'create_session' | 'update_session' | 'create_assessment' | 'update_workout_status';
  table_name: string;
  recordId?: string;
  payload: any;
  status: 'pending' | 'syncing' | 'synced' | 'failed';
  retryCount: number;
  lastError?: string;
}

export function useSyncQueue() {
  const [syncStatus, setSyncStatus] = useState<SyncStatus>('idle');
  const isSyncingRef = useRef(false);

  const triggerSync = async () => {
    if (isSyncingRef.current || !navigator.onLine) return;
    
    isSyncingRef.current = true;
    setSyncStatus('syncing');

    try {
      // Lógica de sincronização aqui
      // 1. Buscar itens pendentes no IndexedDB
      // 2. Processar cada item via Supabase
      // 3. Atualizar status no IndexedDB e no Supabase
      
      setSyncStatus('completed');
    } catch (error) {
      console.error('Sync failed:', error);
      setSyncStatus('failed');
    } finally {
      isSyncingRef.current = false;
    }
  };

  useEffect(() => {
    window.addEventListener('online', triggerSync);
    return () => window.removeEventListener('online', triggerSync);
  }, []);

  return {
    syncStatus,
    triggerSync
  };
}
