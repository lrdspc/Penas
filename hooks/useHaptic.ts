'use client';

import { useCallback } from 'react';

export function useHaptic() {
  const vibrate = useCallback((type: 'light' | 'medium' | 'heavy' = 'medium') => {
    if (typeof navigator !== 'undefined' && navigator.vibrate) {
      switch (type) {
        case 'light':
          navigator.vibrate(10);
          break;
        case 'medium':
          navigator.vibrate(50);
          break;
        case 'heavy':
          navigator.vibrate([100, 50, 100]);
          break;
      }
    } else {
      // Fallback para iOS ou dispositivos sem vibração
      console.log(`Haptic fallback: ${type}`);
    }
  }, []);

  return { vibrate };
}
