# SECURITY

## 2. Segurança como Primeiro Cidadão
- **RLS policies granulares** para cada tabela com exemplos reais de SQL
- **Content Security Policy detalhada** para Next.js
- **Rate limiting via Upstash Redis** - algo raramente documentado em projetos reais
- **Auth flow seguro** com redirecionamento baseado em user_type
- **CSRF protection nativa do Next.js** explicada corretamente

## RLS Policies (Row Level Security)
Todas as tabelas possuem RLS habilitado. As políticas garantem que:
- **Trainers** só podem ver e gerenciar seus próprios alunos, treinos e avaliações.
- **Alunos** só podem ver seus próprios dados e os treinos atribuídos a eles pelo trainer vinculado.
- Dados sensíveis são protegidos no nível do banco de dados.

Consulte `docs/04-DATABASE-SCHEMA.md` para ver as políticas SQL específicas.
