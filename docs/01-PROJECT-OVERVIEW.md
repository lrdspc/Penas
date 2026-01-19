# 📋 Visão Geral do Projeto

## 🎯 Nome Oficial

**Sistema PWA de Gerenciamento de Treinos - Personal Trainer e Alunos**

## 📖 Descrição

Este é um **Progressive Web App (PWA)** de elite para gerenciamento de treinos de musculação, projetado para personal trainers (Personal Trainers) e seus alunos. O sistema oferece uma experiência nativa-like com funcionalidades avançadas como:

- Timer preciso com Web Workers
- Wake Lock API para manter a tela sempre ligada
- Feedback háptico (Android) e fallback para iOS
- Funcionamento 100% offline com Background Sync
- Sincronização automática quando volta online
- Instalação no home screen de iOS, Android e Desktop
- Notificações push com VAPID keys
- Avaliação física automatizada com cálculos antropométricos

## 🎯 Objetivo Principal

Criar uma solução completa que permita:

### Para Personal Trainers
- Gerenciar alunos de forma eficiente
- Criar e editar treinos com interface drag-and-drop
- Realizar avaliações físicas com cálculos automáticos
- Acompanhar alunos em tempo real via Supabase Realtime
- Criar biblioteca personalizada de exercícios

### Para Alunos
- Visualizar treinos atribuídos com prioridade visual
- Executar treinos com timer preciso e feedback háptico
- Acessar histórico completo de treinos
- Ver progresso em avaliações físicas com gráficos
- Treinar 100% offline sem perder dados

## 🚀 Funcionalidades Principais

### ⏱️ Timer Preciso
- Implementado com Web Workers
- Precisão máxima: erro <1s em 10 minutos
- Correção automática de drift
- Fallback para main thread se necessário

### 🔆 Wake Lock API
- Mantém a tela sempre ligada durante treinos
- Fallback para iOS usando video loop
- Fallback alternativo com requestAnimationFrame
- Liberação automática de recursos

### 📳 Vibração Háptica
- Padrões de vibração para diferentes ações (light, medium, heavy)
- Fallback para iOS usando som + flash visual
- Feedback imediato em interações do usuário
- Padrões específicos para sucesso, erro, aviso

### 📡 Offline-First
- IndexedDB para armazenamento offline
- Background Sync API para sincronização automática
- Fila de prioridade para dados críticos
- Indicadores visuais de status de sincronização

### 🔔 Notificações Push
- Web Push Notifications com VAPID keys
- Badges API para contadores
- Fallback para in-app notifications
- Gerenciamento de permissões inteligente

### 📊 Avaliações Físicas
- Cálculos automáticos antropométricos
  - IMC (Índice de Massa Corporal)
  - Gordura em kg e percentual
  - Massa magra em kg
  - Relação cintura/quadril
  - Progresso desde última avaliação
- Gráficos de progresso
- Exportação para PDF

## 👥 Personas

### Persona 1: Personal Trainer (PT)
**Perfil:**
- Profissional que gerencia múltiplos alunos
- Cria treinos personalizados
- Realiza avaliações físicas periódicas
- Acompanha progresso em tempo real

**Funcionalidades Principais:**
- Dashboard com métricas de alunos
- Gerenciamento de alunos (convite, status, histórico)
- Biblioteca de exercícios personalizada
- Criação/edição de treinos com drag-and-drop
- Avaliações físicas com cálculos automáticos
- Acompanhamento em tempo real via Supabase Realtime

### Persona 2: Aluno (Praticante)
**Perfil:**
- Usuário final que executa os treinos
- Visualiza progresso ao longo do tempo
- Recebe notificações de treinos
- Pode treinar offline

**Funcionalidades Principais:**
- Dashboard com treino do dia
- Visualização detalhada de treinos
- Player de treino com timer e feedback háptico
- Histórico completo de sessões
- Gráficos de progresso em avaliações
- Modo offline completo

## 📊 Escopo do MVP (v1)

### ✅ Incluído no MVP

#### Autenticação
- Login aluno/trainer com Supabase Auth
- Convites via token de 6 dígitos com expiração (24h)
- OAuth providers (Google, Apple) para melhor conversão
- Proteção contra brute force com rate limiting

#### Dashboard Trainer
- Visualizar alunos ativos com status em tempo real
- Criar/excluir/editar treinos com drag-and-drop
- Realizar avaliações físicas com cálculos automáticos (IMC, % gordura, etc.)
- Acompanhamento em tempo real via Supabase Realtime

#### Dashboard Aluno
- Ver treinos atribuídos com prioridade visual para "hoje"
- Histórico de execução com métricas de progresso
- Notificações push para treinos não iniciados

#### Player de Treino (Componente Crítico)
- Interface focada no exercício atual
- Timer preciso com Web Workers
- Feedback háptico em transições
- Wake Lock API com fallback para iOS
- Salvamento offline automático com IndexedDB
- Sincronização em background quando online

#### Biblioteca de Exercícios
- CRUD de exercícios personalizado por trainer
- Upload de vídeos instrutivos (Supabase Storage)
- Categorização por grupos musculares
- Busca e filtragem avançada

#### Relatório de Avaliações
- Gráficos de progresso com Chart.js otimizado
- Comparação entre avaliações
- Exportação para PDF (File System Access API)

#### Modo Offline Completo
- IndexedDB com estrutura otimizada para queries
- Background Sync API com fila de prioridade
- Indicador visual de status offline/online
- Dados críticos sempre disponíveis offline

### ❌ Não está no MVP (v2)

- Integração com wearables (Apple Health, Google Fit)
- Análise de movimentos por IA (reconhecimento de postura)
- Marketplace de exercícios (compra/venda de templates)
- App Store/Google Play (PWA apenas - App Stores em v2)
- Videochamadas integradas (Zoom/WebRTC)

## 🎯 Diferenciais Competitivos

### 1. Timer Extremamente Preciso
- Implementado com Web Workers em thread separada
- Correção de drift automática
- Erro máximo <1s em 10 minutos
- Fallback robusto para main thread

### 2. Offline-First Real
- Não apenas "funciona offline", mas otimizado para isso
- IndexedDB com estrutura otimizada
- Background Sync API inteligente
- Fila de prioridade para dados críticos

### 3. Experiência Nativa-Like
- Wake Lock para tela sempre ligada
- Feedback háptico consistente
- Instalação no home screen
- Splash screens otimizados

### 4. Acompanhamento em Tempo Real
- Supabase Realtime para presence tracking
- Atualizações live de progresso
- Notificações automáticas para trainers

### 5. Avaliações Automatizadas
- Cálculos antropométricos automáticos
- Gráficos de progresso interativos
- Exportação para relatórios PDF

## 📈 Métricas de Sucesso

### Técnica
- ⚡ Lighthouse Score >90 em todas as categorias
- ⚡ Tempo de carregamento <2s em 3G
- ⚡ Memory usage <100MB durante treino
- ⚡ Battery consumption <5% por hora de uso
- ⚡ Offline startup <1s para carregar treino salvo

### Usuário
- 💪 Taxa de conclusão de treinos >80%
- 💪 Tempo médio de sessão >30 minutos
- 💪 Taxa de ativos semanais >60%
- 💪 Avaliações realizadas mensalmente >90% dos alunos

### Negócio
- 📈 CAC (Cost Acquisition Cost) <R$50
- 📈 LTV (Lifetime Value) >R$500
- 📈 Churn mensal <5%
- 📈 NPS (Net Promoter Score) >50

## 🔄 Roadmap

### Semana 1-2: Setup e Autenticação
- Configuração do projeto Next.js
- Setup Supabase e migrations
- Implementação de autenticação
- Dashboard básico

### Semana 3: Player de Treino (Crítico)
- Implementação de timer com Web Workers
- Wake Lock e feedback háptico
- Interface de execução de treino
- Salvamento offline

### Semana 4: Biblioteca e Treinos
- CRUD de exercícios
- Interface de criação de treinos
- Drag-and-drop para exercícios
- Atribuição de treinos a alunos

### Semana 5: Avaliações e Relatórios
- Interface de avaliações físicas
- Cálculos antropométricos
- Gráficos de progresso
- Exportação para PDF

### Semana 6: Offline e Sync
- Implementação completa de IndexedDB
- Background Sync API
- Fila de sincronização
- Indicadores visuais

### Semana 7: PWA e Deploy
- Configuração completa do PWA
- Service Worker e caching strategies
- Setup GitHub Actions
- Deploy no Vercel

### Semana 8: Testes e Polimento
- Testes unitários e de integração
- Testes de performance e segurança
- Correção de bugs
- Polimento de UI/UX

## 🎓 Conclusão

Este projeto representa uma oportunidade única de criar um PWA profissional de alta qualidade para o mercado fitness. A combinação de funcionalidades avançadas (timer preciso, offline-first, avaliações automatizadas) com uma experiência de usuário nativa-like e segurança robusta o torna diferenciado no mercado.

**O projeto está pronto para implementação imediata com alta confiança de qualidade, segurança e performance.** 💪🚀
