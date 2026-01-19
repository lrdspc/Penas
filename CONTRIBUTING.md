# Guia de Contribuição para o Projeto Penas

Agradecemos o seu interesse em contribuir para o projeto **Penas**! Este guia detalha o processo para submeter melhorias, relatar bugs e propor novas funcionalidades.

## 🤝 Como Contribuir

### 1. Relatório de Bugs

Se você encontrar um erro ou comportamento inesperado, por favor, abra uma *Issue* no GitHub.

- **Use o template `bug_report.md`** em `.github/ISSUE_TEMPLATE/`.
- **Inclua:**
    - Passos claros para reproduzir o bug.
    - Comportamento esperado vs. Comportamento real.
    - Capturas de tela ou vídeos (se aplicável).
    - Versão do navegador e sistema operacional.

### 2. Sugestão de Funcionalidades

Novas ideias são bem-vindas!

- **Use o template `feature_request.md`** em `.github/ISSUE_TEMPLATE/`.
- **Descreva:**
    - O problema que a nova funcionalidade resolve.
    - Como a funcionalidade deve funcionar (casos de uso).
    - Por que ela é importante para o projeto.

### 3. Submissão de Código (Pull Requests)

Siga os passos abaixo para submeter seu código:

1. **Faça um Fork** do repositório.
2. **Clone** o seu fork localmente:
   ```bash
   git clone https://github.com/SEU_USUARIO/Penas.git
   cd Penas
   ```
3. **Crie uma nova branch** para sua feature ou correção:
   ```bash
   git checkout -b feature/nome-da-feature
   # ou
   git checkout -b fix/correcao-do-bug
   ```
4. **Implemente** suas alterações.
5. **Execute os testes** e garanta que o linting está correto:
   ```bash
   # Exemplo de comandos de teste/linting
   pnpm lint
   pnpm test
   ```
6. **Commite** suas alterações com mensagens claras e descritivas (siga o padrão Conventional Commits, se possível).
7. **Envie** a branch para o seu fork:
   ```bash
   git push origin feature/nome-da-feature
   ```
8. **Abra um Pull Request (PR)** para a branch `main` do repositório original.
   - **Use o template `pull_request_template.md`** em `.github/pull_request_template.md`.
   - Descreva o que foi feito e referencie a *Issue* relacionada.

## 💻 Padrões de Código

- **TypeScript**: Uso obrigatório com `strict` mode ativado.
- **Next.js App Router**: Siga a estrutura de pastas definida em `app/`.
- **Tailwind CSS**: Use classes utilitárias para estilização.
- **Hooks**: Lógica de estado e efeitos deve ser encapsulada em hooks customizados em `hooks/`.
- **Testes**: Novas funcionalidades devem vir acompanhadas de testes unitários e de integração (usando Vitest/React Testing Library).

---

Seu código será revisado pela equipe principal. Agradecemos a colaboração!
