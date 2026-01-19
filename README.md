# Penas - Sistema PWA de Gerenciamento de Treinos

O **Penas** é um Progressive Web App (PWA) de elite desenvolvido para personal trainers e seus alunos. Ele oferece uma experiência de treino fluida, com foco em precisão, funcionamento offline e acompanhamento em tempo real.

## 🚀 Principais Funcionalidades

- **Timer de Alta Precisão**: Utiliza Web Workers para garantir erro menor que 1s em 10 minutos.
- **Offline-First**: Funcionamento completo sem internet via IndexedDB e Background Sync API.
- **Acompanhamento em Tempo Real**: Trainers podem ver o progresso dos alunos ao vivo via Supabase Realtime.
- **Avaliações Físicas**: Cálculos antropométricos automáticos e gráficos de evolução.
- **Experiência Nativa**: Wake Lock API (tela sempre ligada), feedback háptico e notificações push.

## 🛠️ Stack Tecnológica

- **Frontend**: Next.js 15.1 (App Router), TypeScript 5.7, Tailwind CSS 4.0.
- **Backend**: Supabase (PostgreSQL, Auth, Realtime, Storage).
- **Estado**: Zustand (Global) & TanStack Query (Server State).
- **PWA**: Workbox 8.0, Service Workers, Web App Manifest.
- **Deploy**: Vercel & GitHub Actions.

## 📂 Estrutura do Projeto

```bash
app/                  # Rotas e layouts (Next.js App Router)
components/           # Componentes React reutilizáveis
hooks/                # Hooks customizados (Offline, Sync, Auth)
lib/                  # Configurações de bibliotecas (Supabase, Utils)
services/             # Lógica de negócio e chamadas de API
supabase/             # Migrations e configurações do banco de dados
types/                # Definições de tipos TypeScript
public/               # Ativos estáticos (ícones, manifest)
```

## ⚙️ Configuração Local

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/lrdspc/Penas.git
   cd Penas
   ```

2. **Instale as dependências**:
   ```bash
   pnpm install
   ```

3. **Configure as variáveis de ambiente**:
   Crie um arquivo `.env.local` com as chaves do Supabase:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=seu_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=sua_chave_anon
   ```

4. **Inicie o servidor de desenvolvimento**:
   ```bash
   pnpm dev
   ```

## 📄 Documentação Adicional

- [Arquitetura e Decisões Técnicas](ARCHITECTURE.md)
- [Guia de Contribuição](CONTRIBUTING.md)
- [Schema do Banco de Dados](supabase/migrations/README.md)

---

Desenvolvido com foco em performance e experiência do usuário. 💪🚀
