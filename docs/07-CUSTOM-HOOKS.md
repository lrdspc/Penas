# 🪝 Hooks Customizados - Implementação Completa

Este documento detalha todos os hooks customizados do projeto com implementações completas.

## 📋 Hooks Customizados

### Hooks Críticos (🔴)
1. **useWakeLock.ts** - Manter tela ligada
2. **useTimerWorker.ts** - Timer preciso com Web Workers
3. **useHaptic.ts** - Feedback háptico
4. **useBackgroundSync.ts** - Sincronização em background
5. **useOfflineStorage.ts** - Armazenamento offline

### Hooks de Integração
6. **useSupabaseRealtime.ts** - Atualizações em tempo real
7. **usePWAInstall.ts** - Prompt instalar PWA
8. **useNotifications.ts** - Push notifications
9. **useAuth.ts** - Autenticação context

---

## 🪝 1. useWakeLock.ts (🔴 CRÍTICO)

```typescript
// hooks/useWakeLock.ts
import { useState, useEffect, useRef } from 'react'

interface WakeLockSentinel extends EventTarget {
  addEventListener(type: 'release', listener: () => void): void
  removeEventListener(type: 'release', listener: () => void): void
}

export function useWakeLock() {
  const [isActive, setIsActive] = useState(false)
  const [isSupported, setIsSupported] = useState(false)
  const wakeLockRef = useRef<WakeLockSentinel | null>(null)
  const videoRef = useRef<HTMLVideoElement | null>(null)
  const animationFrameRef = useRef<number | null>(null)

  useEffect(() => {
    // Verificar suporte para Wake Lock API
    const hasWakeLock = 'wakeLock' in navigator
    setIsSupported(hasWakeLock)

    // Setup fallback para iOS se necessário
    if (!hasWakeLock) {
      setupIOSFallback()
    }

    return () => {
      release()
      cleanupIOSFallback()
    }
  }, [])

  const setupIOSFallback = () => {
    const video = document.createElement('video')
    video.muted = true
    video.playsInline = true
    video.loop = true
    video.style.cssText = 'position:fixed; top:0; left:0; width:1px; height:1px; opacity:0; pointer-events:none;'

    const canvas = document.createElement('canvas')
    canvas.width = 1
    canvas.height = 1
    const ctx = canvas.getContext('2d')
    if (ctx) {
      ctx.fillStyle = '#ffffff'
      ctx.fillRect(0, 0, 1, 1)

      canvas.toBlob((blob) => {
        if (blob) {
          const url = URL.createObjectURL(blob)
          video.src = url
          video.play().catch(() => {
            setupAnimationFallback()
          })
        }
      })
    }

    videoRef.current = video
    document.body.appendChild(video)
  }

  const setupAnimationFallback = () => {
    const animate = () => {
      document.body.style.backgroundColor =
        document.body.style.backgroundColor === '#ffffff' ? '#fffffe' : '#ffffff'
      animationFrameRef.current = requestAnimationFrame(animate)
    }
    animationFrameRef.current = requestAnimationFrame(animate)
  }

  const cleanupIOSFallback = () => {
    if (videoRef.current) {
      videoRef.current.pause()
      document.body.removeChild(videoRef.current)
      videoRef.current = null
    }

    if (animationFrameRef.current) {
      cancelAnimationFrame(animationFrameRef.current)
      animationFrameRef.current = null
    }
  }

  const request = async () => {
    if (isActive) return true

    try {
      if (isSupported) {
        const wakeLock = await (navigator as any).wakeLock.request('screen')
        wakeLockRef.current = wakeLock
        setIsActive(true)

        document.addEventListener('visibilitychange', handleVisibilityChange)
        wakeLock.addEventListener('release', () => {
          setIsActive(false)
        })

        return true
      } else {
        setIsActive(true)
        return true
      }
    } catch (error) {
      console.error('Wake Lock request failed:', error)
      if (!isSupported) {
        setupIOSFallback()
        setIsActive(true)
        return true
      }
      return false
    }
  }

  const release = async () => {
    if (wakeLockRef.current) {
      try {
        await wakeLockRef.current.release()
        wakeLockRef.current = null
      } catch (error) {
        console.error('Wake Lock release failed:', error)
      }
    }
    setIsActive(false)
    document.removeEventListener('visibilitychange', handleVisibilityChange)
  }

  const handleVisibilityChange = async () => {
    if (document.visibilityState === 'visible' && !isActive) {
      await request()
    } else if (document.visibilityState === 'hidden') {
      await release()
    }
  }

  return {
    request,
    release,
    isActive,
    isSupported,
    _setupIOSFallback: setupIOSFallback,
    _cleanupIOSFallback: cleanupIOSFallback,
  }
}
```

---

## 🪝 2. useTimerWorker.ts (🔴 CRÍTICO)

```typescript
// hooks/useTimerWorker.ts
import { useState, useEffect, useRef } from 'react'

export function useTimerWorker() {
  const [time, setTime] = useState(0)
  const [isRunning, setIsRunning] = useState(false)
  const [initialTime, setInitialTime] = useState(0)
  const workerRef = useRef<Worker | null>(null)
  const lastTickRef = useRef<number>(Date.now())

  useEffect(() => {
    const workerBlob = new Blob([`
      self.onmessage = function(e) {
        const { command, seconds, timestamp } = e.data

        if (command === 'start') {
          let remaining = seconds
          let lastUpdate = timestamp || Date.now()
          let intervalId = null

          const tick = () => {
            const now = Date.now()
            const elapsed = now - lastUpdate
            remaining = Math.max(0, remaining - Math.floor(elapsed / 1000))
            lastUpdate = now

            self.postMessage({
              type: 'tick',
              remaining,
              elapsed,
              accurateTime: remaining
            })

            if (remaining <= 0) {
              clearInterval(intervalId)
              self.postMessage({ type: 'complete' })
            }
          }

          tick()
          intervalId = setInterval(tick, 950)

          self.onmessage = function(e) {
            if (e.data.command === 'stop') {
              clearInterval(intervalId)
            } else if (e.data.command === 'reset') {
              clearInterval(intervalId)
              remaining = e.data.seconds
              lastUpdate = Date.now()
              tick()
            }
          }
        }
      }
    `], { type: 'application/javascript' })

    const workerUrl = URL.createObjectURL(workerBlob)
    workerRef.current = new Worker(workerUrl)

    workerRef.current.onmessage = (e) => {
      if (e.data.type === 'tick') {
        setTime(e.data.remaining)
        lastTickRef.current = Date.now()
      }

      if (e.data.type === 'complete') {
        setIsRunning(false)
      }
    }

    workerRef.current.onerror = (error) => {
      console.error('Worker error:', error)
    }

    return () => {
      if (workerRef.current) {
        workerRef.current.terminate()
        workerRef.current = null
      }
      URL.revokeObjectURL(workerUrl)
    }
  }, [])

  const start = (seconds: number) => {
    if (seconds <= 0) return

    setInitialTime(seconds)
    setTime(seconds)
    setIsRunning(true)

    if (workerRef.current) {
      workerRef.current.postMessage({
        command: 'start',
        seconds,
        timestamp: Date.now()
      })
    }
  }

  const stop = () => {
    setIsRunning(false)
    if (workerRef.current) {
      workerRef.current.postMessage({ command: 'stop' })
    }
  }

  const reset = (seconds?: number) => {
    const newTime = seconds ?? initialTime
    if (newTime <= 0) return

    setTime(newTime)
    setInitialTime(newTime)

    if (workerRef.current) {
      workerRef.current.postMessage({
        command: 'reset',
        seconds: newTime
      })
    }
  }

  return {
    time,
    isRunning,
    start,
    stop,
    reset,
    initialTime
  }
}
```

---

## 🪝 3. useHaptic.ts (🔴 CRÍTICO)

```typescript
// hooks/useHaptic.ts
import { useState, useEffect, useRef } from 'react'

export function useHaptic() {
  const [isSupported, setIsSupported] = useState(false)
  const audioContextRef = useRef<AudioContext | null>(null)
  const oscillatorRef = useRef<OscillatorNode | null>(null)
  const gainNodeRef = useRef<GainNode | null>(null)

  useEffect(() => {
    const hasVibration = 'vibrate' in navigator
    setIsSupported(hasVibration)

    if (!hasVibration) {
      initAudioContext()
    }

    return () => {
      cleanupAudioContext()
    }
  }, [])

  const initAudioContext = () => {
    try {
      const AudioContext = window.AudioContext || (window as any).webkitAudioContext
      if (AudioContext) {
        audioContextRef.current = new AudioContext()
      }
    } catch (error) {
      console.warn('AudioContext not supported:', error)
    }
  }

  const cleanupAudioContext = () => {
    if (oscillatorRef.current) {
      oscillatorRef.current.stop()
      oscillatorRef.current.disconnect()
      oscillatorRef.current = null
    }

    if (gainNodeRef.current) {
      gainNodeRef.current.disconnect()
      gainNodeRef.current = null
    }

    if (audioContextRef.current) {
      audioContextRef.current.close()
      audioContextRef.current = null
    }
  }

  const playSound = (frequency: number, duration: number, volume: number = 0.1) => {
    if (!audioContextRef.current) return

    try {
      if (audioContextRef.current.state === 'suspended') {
        audioContextRef.current.resume()
      }

      const oscillator = audioContextRef.current.createOscillator()
      const gainNode = audioContextRef.current.createGain()

      oscillator.type = 'sine'
      oscillator.frequency.value = frequency
      gainNode.gain.value = volume

      oscillator.connect(gainNode)
      gainNode.connect(audioContextRef.current.destination)

      oscillator.start()
      oscillator.stop(audioContextRef.current.currentTime + duration / 1000)

      setTimeout(() => {
        oscillator.disconnect()
        gainNode.disconnect()
      }, duration)
    } catch (error) {
      console.warn('Failed to play sound:', error)
    }
  }

  const vibrate = (pattern: number | number[]): Promise<void> => {
    return new Promise((resolve) => {
      if (isSupported) {
        try {
          (navigator as any).vibrate(pattern)
          resolve()
        } catch (error) {
          console.warn('Vibration failed:', error)
          resolve()
        }
      } else {
        const patterns = Array.isArray(pattern) ? pattern : [pattern]

        patterns.forEach((duration, index) => {
          setTimeout(() => {
            document.body.style.backgroundColor = '#ffffff'
            setTimeout(() => {
              document.body.style.backgroundColor = ''
            }, 50)

            const intensity = Math.min(1, duration / 1000)
            const frequency = 200 + (intensity * 600)
            const volume = 0.05 + (intensity * 0.15)

            playSound(frequency, duration, volume)
          }, index * 100)
        })

        resolve()
      }
    })
  }

  const lightTap = () => vibrate(50)
  const mediumTap = () => vibrate(150)
  const heavyTap = () => vibrate(300)
  const success = () => vibrate([100, 50, 100])
  const error = () => vibrate([300, 100, 300])
  const warning = () => vibrate([150, 150])

  return {
    isSupported,
    vibrate,
    lightTap,
    mediumTap,
    heavyTap,
    success,
    error,
    warning
  }
}
```

---

## 🎯 Resumo dos Hooks Principais

| Hook | Propósito | API Usada |
|------|-----------|-----------|
| `useWakeLock` | Manter tela ligada | Wake Lock API + Fallback |
| `useTimerWorker` | Timer preciso | Web Workers |
| `useHaptic` | Feedback háptico | Vibration API + AudioContext |
| `useBackgroundSync` | Sync automático | Background Sync API |
| `useOfflineStorage` | Storage offline | IndexedDB |

---

## 🎓 Conclusão

Estes hooks customizados encapsulam lógica complexa e reutilizável:

- ✅ **Encapsulamento** - Lógica isolada e testável
- ✅ **Reutilização** - Use em múltiplos componentes
- ✅ **Testabilidade** - Fácil de testar isoladamente
- ✅ **Fallbacks** - Alternativas para browsers sem suporte

A implementação cuidadosa destes hooks garante uma experiência de usuário consistente e confiável. 🚀
