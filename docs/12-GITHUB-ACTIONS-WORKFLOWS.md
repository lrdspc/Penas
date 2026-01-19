# 🔄 GitHub Actions Workflows

Este documento detalha todos os workflows de CI/CD usados no projeto.

## 📋 Visão Geral

O projeto usa **GitHub Actions** para automação de CI/CD com 3 workflows principais:

1. **CI** - Testes, linting e type checking em cada PR
2. **Preview** - Deploy automático para branches de feature
3. **Production** - Deploy para main com aprovação manual

---

## 🔧 Workflow 1: CI (Continuous Integration)

**Arquivo:** `.github/workflows/ci.yml`

### Objetivo

Executar testes, linting e type checking em cada pull request para garantir qualidade do código.

### Trigger

```yaml
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]
```

### Jobs

#### 1. Lint

```yaml
lint:
  name: Lint
  runs-on: ubuntu-latest

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 8

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Run ESLint
      run: pnpm lint

    - name: Run Prettier check
      run: pnpm format:check
```

#### 2. Type Check

```yaml
type-check:
  name: Type Check
  runs-on: ubuntu-latest

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 8

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Run TypeScript
      run: pnpm type-check
```

#### 3. Test

```yaml
test:
  name: Test
  runs-on: ubuntu-latest

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 8

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Run tests
      run: pnpm test

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage/coverage-final.json
        flags: unittests
        name: codecov-umbrella
```

### Workflow Completo

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run ESLint
        run: pnpm lint

      - name: Run Prettier check
        run: pnpm format:check

  type-check:
    name: Type Check
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run TypeScript
        run: pnpm type-check

  test:
    name: Test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run tests
        run: pnpm test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
          flags: unittests
          name: codecov-umbrella
```

---

## 🚀 Workflow 2: Preview Deploy

**Arquivo:** `.github/workflows/preview.yml`

### Objetivo

Deploy automático para branches de feature para revisão em PRs.

### Trigger

```yaml
on:
  pull_request:
    branches: [main, develop]
    types: [opened, synchronize, reopened]
```

### Job

#### 1. Deploy Preview

```yaml
deploy-preview:
  name: Deploy Preview
  runs-on: ubuntu-latest

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 8

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Build
      run: pnpm build

    - name: Deploy to Vercel Preview
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
        working-directory: ./
        vercel-args: '--prebuilt'

    - name: Comment PR with Preview URL
      uses: actions/github-script@v7
      with:
        script: |
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: '🚀 Preview deployment disponível em: ${{ steps.deploy.outputs.preview-url }}'
          })
```

### Workflow Completo

```yaml
name: Preview Deploy

on:
  pull_request:
    branches: [main, develop]
    types: [opened, synchronize, reopened]

jobs:
  deploy-preview:
    name: Deploy Preview
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Build
        run: pnpm build

      - name: Deploy to Vercel Preview
        id: deploy
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./
          vercel-args: '--prebuilt'

      - name: Comment PR with Preview URL
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '🚀 Preview deployment disponível em: ${{ steps.deploy.outputs.preview-url }}'
            })
```

---

## 🌐 Workflow 3: Production Deploy

**Arquivo:** `.github/workflows/production.yml`

### Objetivo

Deploy para produção na branch main com aprovação manual.

### Trigger

```yaml
on:
  push:
    branches: [main]
```

### Jobs

#### 1. Deploy Production

```yaml
deploy-production:
  name: Deploy Production
  runs-on: ubuntu-latest
  environment:
    name: production
    url: https://your-production-url.com

  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 8

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '22'
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Run tests
      run: pnpm test

    - name: Build
      run: pnpm build

    - name: Deploy to Vercel Production
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
        vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
        vercel-args: '--prod'

    - name: Run Database Migrations
      run: |
        npx supabase db push

    - name: Notify Slack
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        text: 'Deploy production concluído!'
        webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
      if: always()
```

### Workflow Completo

```yaml
name: Production Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-production:
    name: Deploy Production
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://your-production-url.com

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Run tests
        run: pnpm test

      - name: Build
        run: pnpm build

      - name: Deploy to Vercel Production
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'

      - name: Run Database Migrations
        run: |
          npx supabase db push

      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Deploy production concluído!'
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
        if: always()
```

---

## 🔑 Secrets do GitHub

Configure os seguintes secrets no GitHub repository:

### Vercel

```bash
VERCEL_TOKEN=your-vercel-token
VERCEL_ORG_ID=your-vercel-org-id
VERCEL_PROJECT_ID=your-vercel-project-id
```

### Supabase

```bash
SUPABASE_ACCESS_TOKEN=your-supabase-access-token
SUPABASE_PROJECT_REF=your-project-ref
```

### Notificações (Opcional)

```bash
SLACK_WEBHOOK_URL=your-slack-webhook-url
```

### Como Configurar

1. Vá para `Settings > Secrets and variables > Actions`
2. Clique em `New repository secret`
3. Adicione cada secret acima

---

## 📊 Scripts do package.json

Adicione os seguintes scripts ao `package.json`:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  }
}
```

---

## 🎯 Best Practices

### 1. Fast Feedback

- ✅ Fail fast em erros de lint e type-check
- ✅ Executar jobs em paralelo quando possível
- ✅ Usar cache de dependências

### 2. Segurança

- ✅ Nunca expor secrets nos logs
- ✅ Usar environment variables para produção
- ✅ Validar deploy de migrations

### 3. Monitoramento

- ✅ Notificar equipe em caso de falha
- ✅ Log de mudanças em cada deploy
- ✅ Metrics de tempo de build

### 4. Performance

- ✅ Usar pnpm para installs rápidos
- ✅ Cache de dependências GitHub Actions
- ✅ Parallel jobs para testes

---

## 🐛 Troubleshooting

### Build Falhando

**Problema:** Build falha no Vercel

**Solução:**
1. Verifique logs do GitHub Actions
2. Confirme que todas as variáveis de ambiente estão configuradas
3. Teste localmente com `pnpm build`

### Testes Falhando no CI

**Problema:** Testes passam localmente mas falham no CI

**Solução:**
1. Verifique timezone (CI usa UTC)
2. Confirme versões do Node.js
3. Verifique dependências de ambiente

### Migrations Falhando

**Problema:** Database migrations falham no deploy

**Solução:**
1. Teste migrations localmente: `supabase db push`
2. Verifique RLS policies
3. Confirme que migrations são idempotentes

---

## 🎓 Conclusão

Estes workflows de GitHub Actions garantem:

- ✅ **Qualidade** - Testes, linting e type checking automáticos
- ✅ **Velocidade** - Deploy rápido com feedback imediato
- ✅ **Segurança** - Secrets protegidos e validação de código
- ✅ **Confiabilidade** - Migrations automáticas e notificações

O setup de CI/CD profissional permite que a equipe foque em desenvolvimento ao invés de deploy manual. 🚀
