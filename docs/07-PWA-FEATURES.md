# PWA CORE (FUNCIONALIDADES PWA)

## Funcionalidades de Elite
- **Timer com Web Workers** (erro <1s em 10min) - extremamente raro ver essa precisão em projetos reais
- **Wake Lock + Vibration API** com fallback iOS bem pensado
- **Offline-first completo** com IndexedDB + Background Sync - poucos projetos implementam isso corretamente
- Manifest.json otimizado com screenshots, shortcuts e protocol handlers

## Stack PWA
| Tecnologia | Versão | Observações |
|------------|--------|-------------|
| Service Worker | Workbox 8.0 | Estratégias de cache avançadas |
| PWA Plugin | next-pwa v5.6+ | Manifest e service worker automático |
| Manifest | Web App Manifest JSON | Optimizado para iOS/Android/Desktop |
| Storage Offline | IndexedDB v3 + idb wrapper | Estrutura otimizada para queries |
| Background Sync | Background Sync API + Periodic Background Sync | Fallback para online sync |
| Notificações | Web Push Notifications + Badges API | VAPID keys, permission management |
| Wake Lock | Screen Wake Lock API v2 | Fallback para iOS com video loop |
| Vibração | Vibration API (Android) + Fallback iOS | Patterns pré-definidos |
| File Access | File System Access API | Exportação de relatórios |
| Desktop UI | Window Controls Overlay API | Desktop PWA experience |
