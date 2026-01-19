# API DOCUMENTATION

A API é construída utilizando **Next.js App Router (Route Handlers)**.

## Estrutura de Endpoints

```
api/
├── auth/
│   ├── login/              # POST: Login de usuário
│   ├── signup/             # POST: Cadastro de usuário
│   ├── logout/             # POST: Logout
│   ├── verify-invite/      # POST: Verificar token de convite
│   └── refresh-token/      # POST: Atualizar token JWT
├── workouts/
│   ├── route.ts            # GET: Listar treinos, POST: Criar treino
│   └── [id]/               # GET, PUT, DELETE: Operações em treino específico
├── exercises/
│   ├── route.ts            # GET: Listar exercícios, POST: Criar exercício
│   └── [id]/               # GET, PUT, DELETE: Operações em exercício específico
├── students/
│   ├── route.ts            # GET: Listar alunos
│   └── [id]/               # GET, PUT, DELETE: Operações em aluno específico
├── sessions/
│   ├── route.ts            # POST: Criar sessão de treino
│   └── [id]/               # PUT: Atualizar sessão existente
├── assessments/
│   ├── route.ts            # GET: Listar avaliações, POST: Criar avaliação
│   └── [id]/               # GET, PUT, DELETE: Operações em avaliação específica
├── sync/
│   └── route.ts            # POST: Endpoint para Background Sync
├── notifications/
│   ├── subscribe/          # POST: Inscrever dispositivo para push notifications
│   └── send/               # POST: Enviar notificação (apenas trainer)
└── webhooks/
    └── supabase/           # Webhooks para eventos do Supabase
```
