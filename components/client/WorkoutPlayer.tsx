'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useTimerWorker } from '@/hooks/useTimerWorker';
import { useWakeLock } from '@/hooks/useWakeLock';
import { useHaptic } from '@/hooks/useHaptic';
import { useOfflineStorage } from '@/hooks/useOfflineStorage';

interface WorkoutPlayerProps {
  workout: any;
  onComplete: (data: any) => void;
}

export const WorkoutPlayer: React.FC<WorkoutPlayerProps> = ({ workout, onComplete }) => {
  const [currentExerciseIndex, setCurrentExerciseIndex] = useState(0);
  const [currentSet, setCurrentSet] = useState(1);
  const [isResting, setIsResting] = useState(false);
  
  const { time, startTimer, stopTimer, resetTimer } = useTimerWorker();
  const { requestWakeLock, releaseWakeLock } = useWakeLock();
  const { vibrate } = useHaptic();
  const { saveSession } = useOfflineStorage();

  const currentExercise = workout.exercises[currentExerciseIndex];

  useEffect(() => {
    requestWakeLock();
    return () => releaseWakeLock();
  }, []);

  const handleSetComplete = () => {
    vibrate('medium');
    if (currentSet < currentExercise.sets) {
      setCurrentSet(prev => prev + 1);
      startRest();
    } else if (currentExerciseIndex < workout.exercises.length - 1) {
      setCurrentExerciseIndex(prev => prev + 1);
      setCurrentSet(1);
      startRest();
    } else {
      handleWorkoutComplete();
    }
  };

  const startRest = () => {
    setIsResting(true);
    resetTimer(currentExercise.rest_seconds || 60);
    startTimer();
  };

  const handleWorkoutComplete = () => {
    vibrate('heavy');
    const sessionData = {
      workout_id: workout.id,
      completed_at: new Date().toISOString(),
      // ... outros dados
    };
    saveSession(sessionData);
    onComplete(sessionData);
  };

  return (
    <div className="flex flex-col h-full p-4 bg-background">
      <div className="flex-1">
        <h2 className="text-2xl font-bold">{currentExercise.name}</h2>
        <p className="text-muted-foreground">Série {currentSet} de {currentExercise.sets}</p>
        
        {isResting ? (
          <div className="flex flex-col items-center justify-center h-64">
            <span className="text-6xl font-mono">{time}s</span>
            <p>Descanso</p>
          </div>
        ) : (
          <div className="mt-8">
            <p className="text-xl">{currentExercise.reps} repetições</p>
            <p className="text-lg text-primary">{currentExercise.weight}kg</p>
          </div>
        )}
      </div>

      <button 
        onClick={isResting ? () => setIsResting(false) : handleSetComplete}
        className="w-full py-4 text-xl font-bold text-white bg-primary rounded-xl"
      >
        {isResting ? 'Pular Descanso' : 'Série Completa'}
      </button>
    </div>
  );
};
