# 📚 Documentação - PWA para Treinadores de Musculação

Bem-vindo à documentação completa do Sistema PWA de Gerenciamento de Treinos. Este projeto é um Progressive Web App de elite para personal trainers e alunos.

## 🎯 Visão Geral

Este é um projeto **PWA (Progressive Web App)** de gerenciamento de treinos que permite:

- ✅ Timer preciso (Web Workers, erro máx. 1s em 10min)
- ✅ Wake Lock API (tela sempre ligada)
- ✅ Vibração háptica (Android) + Fallback iOS (som + alerta visual)
- ✅ Funcionamento 100% offline com Background Sync API
- ✅ Sincronização automática quando voltar online
- ✅ Instalação no home screen (iOS + Android + Desktop)
- ✅ Notificações push com VAPID keys
- ✅ Avaliação física automatizada com cálculos antropométricos

## 📖 Documentação Organizada

### 🚀 Introdução e Visão Geral
- **[01-PROJECT-OVERVIEW.md](./01-PROJECT-OVERVIEW.md)** - Visão geral do projeto, objetivos e escopo do MVP

### 🛠️ Stack Tecnológico
- **[02-TECH-STACK.md](./02-TECH-STACK.md)** - Tecnologias utilizadas (Frontend, Backend, PWA, Deploy)

### 👥 Personas e Casos de Uso
- **[03-PERSONAS.md](./03-PERSONAS.md)** - Detalhamento completo das personas (Personal Trainer e Aluno)

### 🗄️ Banco de Dados
- **[04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md)** - Schema SQL completo, migrations e RLS policies

### 📁 Estrutura do Projeto
- **[05-PROJECT-STRUCTURE.md](./05-PROJECT-STRUCTURE.md)** - Estrutura completa de pastas Next.js App Router

### 🧩 Componentes Críticos
- **[06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md)** - Especificações detalhadas dos componentes principais

### 🪝 Hooks Customizados
- **[07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md)** - Implementação dos hooks críticos (Wake Lock, Timer, Haptic, etc.)

### ✅ Testes e Validação
- **[08-TESTING.md](./08-TESTING.md)** - Testes unitários, integração, performance e segurança

### 🚀 Deploy e Monitoramento
- **[09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md)** - Deploy no Vercel, monitoramento e observabilidade

### 🔧 Troubleshooting
- **[10-TROUBLESHOOTING.md](./10-TROUBLESHOOTING.md)** - Soluções para problemas comuns

### ⚙️ Setup Completo
- **[11-GITHUB-SUPABASE-VERCEL-SETUP.md](../github-vercel-supabase-setup.md)** - Setup completo GitHub + Supabase + Vercel

### 🔄 GitHub Actions Workflows
- **[12-GITHUB-ACTIONS-WORKFLOWS.md](./12-GITHUB-ACTIONS-WORKFLOWS.md)** - Workflows de CI/CD detalhados

## 🎯 Stack Tecnológico Resumido

### Frontend
- **Framework:** Next.js 15.1 (App Router)
- **Linguagem:** TypeScript 5.7
- **React:** 18.3.1
- **Styling:** Tailwind CSS 4.0
- **Estado:** Zustand v4 + TanStack Query v5

### Backend
- **BaaS:** Supabase (PostgreSQL 14, Auth, Realtime, Storage)
- **Database:** PostgreSQL com Row Level Security (RLS)
- **Auth:** Supabase Auth com JWT e PKCE flow

### PWA Core
- **Service Worker:** Workbox 8.0
- **PWA Plugin:** next-pwa v5.6+
- **Storage:** IndexedDB v3 + idb wrapper
- **Offline:** Background Sync API + Periodic Background Sync
- **Wake Lock:** Screen Wake Lock API v2
- **Notificações:** Web Push Notifications + VAPID

### Deploy
- **Frontend:** Vercel (Edge Network)
- **CI/CD:** GitHub Actions
- **Monitoramento:** Vercel Analytics + Speed Insights + Sentry

## 🚀 Começando Rápido

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/projeto-treinos-pwa.git

# 2. Instale as dependências
pnpm install

# 3. Configure as variáveis de ambiente
cp .env.example .env.local
# Edite .env.local com suas credenciais Supabase

# 4. Execute as migrations
supabase db push

# 5. Inicie o servidor de desenvolvimento
pnpm dev

# 6. Acesse http://localhost:3000
```

## 📊 Escopo do MVP

### ✅ No MVP (v1)
- Autenticação (Email + OAuth)
- Dashboard Trainer (alunos, treinos, avaliações)
- Dashboard Aluno (treinos, histórico, avaliações)
- Player de Treino com timer preciso
- Biblioteca de Exercícios
- Modo Offline Completo
- Avaliações Físicas
- Relatórios de Progresso

### ❌ Não está no MVP (v2)
- Integração com wearables (Apple Health, Google Fit)
- Análise de movimentos por IA
- Marketplace de exercícios
- App Store/Google Play (PWA apenas)
- Videochamadas integradas

## 🔒 Segurança

- ✅ Row Level Security (RLS) em todas as tabelas
- ✅ Proteção contra SQL Injection
- ✅ Sanitização de inputs (XSS Protection)
- ✅ CSRF Protection via tokens
- ✅ Rate Limiting com Upstash Redis
- ✅ Content Security Policy (CSP) configurada
- ✅ Auth com PKCE flow seguro

## 📈 Performance Targets

- ✅ Lighthouse Score: >90 em todas as categorias
- ✅ Tempo de Carregamento: <2s em conexão 3G
- ✅ Memory Usage: <100MB durante execução de treino
- ✅ Battery Consumption: <5% por hora de uso
- ✅ Offline Startup: <1s para carregar treino salvo

## 🎓 Recursos Adicionais

- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Guia para contribuidores
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - Arquitetura detalhada do sistema
- **[github-vercel-supabase-setup.md](../github-vercel-supabase-setup.md)** - Setup completo passo a passo

## 🤝 Suporte

Para questões ou problemas:
1. Verifique a seção de [Troubleshooting](./10-TROUBLESHOOTING.md)
2. Consulte o [Setup Completo](../github-vercel-supabase-setup.md)
3. Abra uma issue no GitHub com o template apropriado

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

---

**Este projeto tem potencial para se tornar o padrão ouro para PWAs no setor fitness!** 💪🚀
