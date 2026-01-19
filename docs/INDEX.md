# 📖 Índice de Documentação

Bem-vindo à documentação completa do Sistema PWA de Gerenciamento de Treinos. Este índice organiza todos os documentos disponíveis.

## 🚀 Documentação Principal

### 📖 [README.md](./README.md)
**Comece aqui!** Visão geral do projeto, stack tecnológico e como começar rapidamente.

---

## 📚 Documentos Técnicos

### 1. 📋 [01-PROJECT-OVERVIEW.md](./01-PROJECT-OVERVIEW.md)
Visão geral do projeto, objetivos, escopo do MVP e funcionalidades principais.

- Nome oficial do projeto
- Objetivo principal
- Funcionalidades principais
- Personas (Personal Trainer e Aluno)
- Escopo do MVP (incluído e não incluído)
- Diferenciais competitivos
- Métricas de sucesso
- Roadmap de desenvolvimento

**Quem deve ler:** Novos desenvolvedores, stakeholders, qualquer pessoa interessada no projeto

### 2. 🛠️ [02-TECH-STACK.md](./02-TECH-STACK.md)
Stack tecnológico completo com versões específicas e observações importantes.

- Frontend (Next.js, React, TypeScript, Tailwind)
- Estado global e data fetching (Zustand, TanStack Query, Supabase Realtime)
- PWA Core (Workbox, next-pwa, IndexedDB, Background Sync, etc.)
- Backend e Banco de Dados (Supabase, PostgreSQL, Auth, RLS)
- Deploy e Hosting (Vercel, GitHub Actions)
- Dependências adicionais

**Quem deve ler:** Desenvolvedores frontend e backend, DevOps

### 3. 👥 [03-PERSONAS.md](./03-PERSONAS.md)
Personas detalhadas com casos de uso completos.

- **Persona 1: Personal Trainer** - Dashboard, gerenciar alunos, biblioteca de exercícios, criar treinos, avaliações, acompanhamento em tempo real
- **Persona 2: Aluno** - Onboarding, dashboard, visualizar/executar treinos, histórico, avaliações, modo offline
- Fluxos de uso cruzados
- Métricas de persona

**Quem deve ler:** Designers, desenvolvedores, produto

### 4. 🗄️ [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md)
Schema SQL completo com todas as tabelas, índices e RLS policies.

- 10 tabelas detalhadas (users, trainer_students, exercises, workouts, etc.)
- Índices otimizados para queries
- RLS policies granulares por tabela
- Cálculos automáticos (IMC, gordura, massa magra, etc.)
- Melhores práticas de performance e segurança

**Quem deve ler:** Desenvolvedores backend, DBAs, DevOps

### 5. 📁 [05-PROJECT-STRUCTURE.md](./05-PROJECT-STRUCTURE.md)
Estrutura completa de pastas Next.js App Router.

- Estrutura completa de pastas e arquivos
- App directory (routes, route groups)
- Components directory (client, server, shared)
- Hooks directory (custom hooks)
- Lib directory (supabase, workers, indexeddb, etc.)
- Convenções de nomenclatura
- Arquivos de configuração

**Quem deve ler:** Desenvolvedores frontend, novos membros da equipe

### 6. 🧩 [06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md)
Especificações detalhadas dos componentes críticos do sistema.

- **WorkoutPlayer.tsx** - Player principal de treinos (🔴 CRÍTICO)
- **Timer.tsx** - Timer com Web Workers (🔴 CRÍTICO)
- **ExerciseCard.tsx** - Card de exercício para drag-and-drop
- Implementações completas com TypeScript
- Testes críticos para cada componente
- Best practices de performance, acessibilidade e testabilidade

**Quem deve ler:** Desenvolvedores frontend, QA

### 7. 🪝 [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md)
Hooks customizados com implementações completas.

- **useWakeLock.ts** - Manter tela ligada (🔴 CRÍTICO)
- **useTimerWorker.ts** - Timer preciso com Web Workers (🔴 CRÍTICO)
- **useHaptic.ts** - Feedback háptico (🔴 CRÍTICO)
- **useBackgroundSync.ts** - Sincronização automática (🔴 CRÍTICO)
- **useOfflineStorage.ts** - Armazenamento offline (🔴 CRÍTICO)
- Implementações completas com TypeScript
- Fallbacks para browsers sem suporte

**Quem deve ler:** Desenvolvedores frontend

### 8. ✅ [08-TESTING.md](./08-TESTING.md)
Estratégias de teste e validação do projeto.

- Testes unitários críticos (Timer, Wake Lock, Haptic, Offline Storage, RLS)
- Testes de integração (fluxo completo de treino, convite, avaliações, realtime)
- Testes de performance (Lighthouse, tempo de carregamento, memory usage)
- Testes de segurança (SQL injection, XSS, CSRF)
- Cobertura de testes e metas
- Checklist de validação pré e pós-deploy

**Quem deve ler:** QA, desenvolvedores, DevOps

### 9. 🚀 [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md)
Deploy e monitoramento do projeto.

- Variáveis de ambiente (development, preview, production)
- Deploy na Vercel (setup e automação)
- Deploy automático com GitHub Actions
- Monitoramento (Vercel Analytics, Speed Insights, Sentry)
- Performance targets (Web Vitals, Lighthouse, custom metrics)
- Alertas e dashboards
- Segurança no deploy
- Performance optimization
- Rollback procedure

**Quem deve ler:** DevOps, desenvolvedores, SREs

### 10. 🐛 [10-TROUBLESHOOTING.md](./10-TROUBLESHOOTING.md)
Soluções para problemas comuns.

- Problemas de desenvolvimento (imports, configuration, etc.)
- Problemas de Supabase (RLS, migrations, permissions)
- Problemas de deploy (build, environment variables)
- Problemas de PWA (service worker, installation, sync)
- Problemas de performance (slow loading, memory leaks)
- Problemas de testes (CI failures, mocks)
- Ferramentas de debugging
- Recursos adicionais

**Quem deve ler:** Todos os desenvolvedores, DevOps

---

## 🔧 Documentos de Configuração

### 11. ⚙️ [GITHUB-SUPABASE-VERCEL-SETUP.md](../github-vercel-supabase-setup.md)
Setup completo passo a passo GitHub + Supabase + Vercel.

- Configuração do GitHub repository
- Setup do projeto Supabase
- Migrations e RLS policies
- Setup do projeto Vercel
- Variáveis de ambiente
- GitHub Actions workflows
- Troubleshooting de setup

**Quem deve ler:** DevOps, novos desenvolvedores

### 12. 🔄 [12-GITHUB-ACTIONS-WORKFLOWS.md](./12-GITHUB-ACTIONS-WORKFLOWS.md)
GitHub Actions workflows detalhados.

- **CI Workflow** - Testes, linting, type checking em cada PR
- **Preview Deploy Workflow** - Deploy automático para branches de feature
- **Production Deploy Workflow** - Deploy para main com aprovação manual
- Scripts do package.json
- Secrets do GitHub
- Best practices

**Quem deve ler:** DevOps, desenvolvedores

---

## 📚 Documentos do Repositório

### 🏗️ [ARCHITECTURE.md](../ARCHITECTURE.md)
Arquitetura detalhada do sistema.

### 🤝 [CONTRIBUTING.md](../CONTRIBUTING.md)
Guia para contribuidores do projeto.

### 📄 [README.md](../README.md)
Getting started do projeto.

---

## 🗺️ Mapa de Navegação por Perfil

### 👨‍💻 Novo Desenvolvedor Frontend
Comece por aqui:
1. [README.md](./README.md) - Visão geral
2. [02-TECH-STACK.md](./02-TECH-STACK.md) - Stack tecnológico
3. [05-PROJECT-STRUCTURE.md](./05-PROJECT-STRUCTURE.md) - Estrutura de pastas
4. [06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md) - Componentes críticos
5. [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md) - Hooks customizados

### 👨‍💼 Novo Desenvolvedor Backend
Comece por aqui:
1. [README.md](./README.md) - Visão geral
2. [02-TECH-STACK.md](./02-TECH-STACK.md) - Stack tecnológico
3. [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md) - Schema do banco de dados
4. [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md) - Deploy e monitoramento

### 🧪 QA / Tester
Comece por aqui:
1. [README.md](./README.md) - Visão geral
2. [03-PERSONAS.md](./03-PERSONAS.md) - Casos de uso
3. [08-TESTING.md](./08-TESTING.md) - Estratégias de teste
4. [10-TROUBLESHOOTING.md](./10-TROUBLESHOOTING.md) - Problemas comuns

### 🚀 DevOps / SRE
Comece por aqui:
1. [README.md](./README.md) - Visão geral
2. [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md) - Deploy e monitoramento
3. [12-GITHUB-ACTIONS-WORKFLOWS.md](./12-GITHUB-ACTIONS-WORKFLOWS.md) - GitHub Actions
4. [github-vercel-supabase-setup.md](../github-vercel-supabase-setup.md) - Setup completo

### 👨‍💼 Product Owner / Stakeholder
Comece por aqui:
1. [README.md](./README.md) - Visão geral rápida
2. [01-PROJECT-OVERVIEW.md](./01-PROJECT-OVERVIEW.md) - Visão detalhada do projeto
3. [03-PERSONAS.md](./03-PERSONAS.md) - Personas e casos de uso

---

## 🎯 Documentos por Categoria

### 📖 Visão Geral
- [README.md](./README.md)
- [01-PROJECT-OVERVIEW.md](./01-PROJECT-OVERVIEW.md)

### 🛠️ Implementação
- [02-TECH-STACK.md](./02-TECH-STACK.md)
- [03-PERSONAS.md](./03-PERSONAS.md)
- [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md)
- [05-PROJECT-STRUCTURE.md](./05-PROJECT-STRUCTURE.md)
- [06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md)
- [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md)

### ✅ Qualidade
- [08-TESTING.md](./08-TESTING.md)
- [10-TROUBLESHOOTING.md](./10-TROUBLESHOOTING.md)

### 🚀 Operações
- [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md)
- [12-GITHUB-ACTIONS-WORKFLOWS.md](./12-GITHUB-ACTIONS-WORKFLOWS.md)
- [github-vercel-supabase-setup.md](../github-vercel-supabase-setup.md)

---

## 🔍 Como Encontrar Informação

### Por Palavra-Chave

| Palavra-Chave | Documentos |
|--------------|------------|
| Timer | [06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md), [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md) |
| Wake Lock | [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md) |
| Offline | [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md), [06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md), [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md) |
| RLS | [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md), [08-TESTING.md](./08-TESTING.md) |
| Deploy | [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md), [12-GITHUB-ACTIONS-WORKFLOWS.md](./12-GITHUB-ACTIONS-WORKFLOWS.md) |
| PWA | [02-TECH-STACK.md](./02-TECH-STACK.md), [10-TROUBLESHOOTING.md](./10-TROUBLESHOOTING.md) |
| Performance | [08-TESTING.md](./08-TESTING.md), [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md) |
| Segurança | [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md), [08-TESTING.md](./08-TESTING.md) |

### Por Etapa do Desenvolvimento

| Etapa | Documentos |
|-------|------------|
| **Onboarding** | [README.md](./README.md), [02-TECH-STACK.md](./02-TECH-STACK.md), [05-PROJECT-STRUCTURE.md](./05-PROJECT-STRUCTURE.md) |
| **Desenvolvimento** | [06-CRITICAL-COMPONENTS.md](./06-CRITICAL-COMPONENTS.md), [07-CUSTOM-HOOKS.md](./07-CUSTOM-HOOKS.md) |
| **Backend** | [04-DATABASE-SCHEMA.md](./04-DATABASE-SCHEMA.md) |
| **Testes** | [08-TESTING.md](./08-TESTING.md), [10-TROUBLESHOOTING.md](./10-TROUBLESHOOTING.md) |
| **Deploy** | [09-DEPLOY-MONITORING.md](./09-DEPLOY-MONITORING.md), [12-GITHUB-ACTIONS-WORKFLOWS.md](./12-GITHUB-ACTIONS-WORKFLOWS.md) |
| **Setup** | [github-vercel-supabase-setup.md](../github-vercel-supabase-setup.md) |

---

## 📊 Estatísticas da Documentação

- **Total de documentos:** 12 principais + 3 de configuração
- **Total de linhas:** ~15,000+
- **Cobertura de tópicos:** Completa (desenvolvimento, deploy, testes, troubleshooting)
- **Nível de detalhe:** Profissional (código TypeScript incluído)
- **Frequência de atualização:** Contínua (acompanha mudanças no projeto)

---

## 🎓 Conclusão

Esta documentação foi criada para:

- ✅ **Onboarding rápido** - Novos desenvolvedores produtivos em dias, não semanas
- ✅ **Referência completa** - Todas as respostas em um só lugar
- ✅ **Autonomia** - Equipe pode resolver problemas sem ajuda constante
- ✅ **Consistência** - Padrões e melhores práticas documentados
- ✅ **Escalabilidade** - Documentação cresce com o projeto

**Dica:** Mantenha esta documentação atualizada conforme o projeto evolui. Uma documentação desatualizada é pior do que nenhuma documentação! 🚀

---

## 🤝 Contribuindo

Quer melhorar a documentação?

1. Identifique onde melhorar
2. Crie uma branch `docs/nome-do-tema`
3. Faça as melhorias
4. Abra um PR com descrição clara das mudanças

**Dica de ouro:** Documente enquanto codifica. É muito mais fácil documentar algo fresco na memória do que tentar lembrar semanas depois! 📝

---

**Última atualização:** Janeiro 2025
**Versão da documentação:** 1.0.0
