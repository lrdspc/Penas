# Arquitetura do Projeto Penas

Este documento detalha as decisões arquiteturais e a estrutura técnica do projeto **Penas**.

## 🏗️ Visão Geral

O projeto segue uma arquitetura moderna baseada em **Next.js 15.1** com **App Router**, utilizando **Supabase** como Backend-as-a-Service (BaaS). A aplicação é projetada para ser um PWA (Progressive Web App) de alta performance com capacidades offline robustas.

## 🔒 Segurança (RLS & Auth)

A segurança é implementada no nível do banco de dados usando **Row Level Security (RLS)** do PostgreSQL.
- **Autenticação**: Gerenciada pelo Supabase Auth (JWT + PKCE Flow).
- **Autorização**: Políticas granulares garantem que trainers acessem apenas seus alunos e alunos acessem apenas seus próprios treinos.

## 📶 Estratégia Offline

O Penas utiliza uma abordagem **Offline-First**:
1. **IndexedDB**: Armazenamento local persistente para treinos, exercícios e sessões.
2. **Background Sync API**: Sincronização automática de dados quando a conexão é restabelecida.
3. **Sync Queue**: Uma fila de ações pendentes (`offline_sync_queue`) gerencia a ordem e as tentativas de sincronização.

## ⏱️ Timer e Web Workers

Para garantir a precisão do timer de treino (crítico para a experiência), utilizamos **Web Workers**. Isso evita que o timer sofra atrasos devido ao processamento na thread principal do navegador ou quando a aba entra em modo de suspensão.

## 📊 Modelagem de Dados

O banco de dados PostgreSQL no Supabase conta com as seguintes tabelas principais:
- `users`: Perfis estendidos (Trainer/Aluno).
- `exercises`: Biblioteca de exercícios.
- `workouts`: Templates de treinos criados por trainers.
- `workout_exercises`: Associação de exercícios a treinos com séries/repetições.
- `student_workouts`: Treinos atribuídos a alunos específicos.
- `workout_sessions`: Registros de execuções de treinos.
- `assessments`: Avaliações físicas antropométricas.
- `offline_sync_queue`: Fila de sincronização offline.

## 🚀 CI/CD

- **GitHub Actions**: Executa linting, testes e type checking em cada Pull Request.
- **Vercel**: Deploy automático de previews para PRs e produção para a branch `main`.

---

Para detalhes sobre o schema SQL, consulte `supabase/migrations/`.
