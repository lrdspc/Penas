'use client';

import { useState, useCallback } from 'react';

export function useWakeLock() {
  const [wakeLock, setWakeLock] = useState<any>(null);

  const requestWakeLock = useCallback(async () => {
    if ('wakeLock' in navigator) {
      try {
        const wl = await (navigator as any).wakeLock.request('screen');
        setWakeLock(wl);
        console.log('Wake Lock is active');
      } catch (err: any) {
        console.error(`${err.name}, ${err.message}`);
      }
    }
  }, []);

  const releaseWakeLock = useCallback(async () => {
    if (wakeLock) {
      await wakeLock.release();
      setWakeLock(null);
      console.log('Wake Lock released');
    }
  }, [wakeLock]);

  return { requestWakeLock, releaseWakeLock };
}
