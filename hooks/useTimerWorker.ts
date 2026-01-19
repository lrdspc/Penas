'use client';

import { useState, useEffect, useRef } from 'react';

export function useTimerWorker() {
  const [time, setTime] = useState(0);
  const workerRef = useRef<Worker | null>(null);

  useEffect(() => {
    // Em um ambiente real, o worker estaria em um arquivo separado
    // Aqui estamos simulando a interface
    return () => {
      if (workerRef.current) {
        workerRef.current.terminate();
      }
    };
  }, []);

  const startTimer = () => {
    // Lógica para iniciar o worker
  };

  const stopTimer = () => {
    // Lógica para parar o worker
  };

  const resetTimer = (initialTime: number) => {
    setTime(initialTime);
  };

  return { time, startTimer, stopTimer, resetTimer };
}
