# DEPLOY E MONITORAMENTO

## Variáveis de Ambiente
```bash
# Development (.env.local)
NEXT_PUBLIC_SUPABASE_URL=your-dev-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-dev-key
SUPABASE_SERVICE_ROLE_KEY=your-dev-service-key
NEXT_PUBLIC_VAPID_PUBLIC_KEY=your-dev-vapid-public
VAPID_PRIVATE_KEY=your-dev-vapid-private
UPSTASH_REDIS_REST_URL=your-dev-redis-url
UPSTASH_REDIS_REST_TOKEN=your-dev-redis-token

# Preview (Vercel Environment Variables)
NEXT_PUBLIC_SUPABASE_URL=your-preview-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-preview-key
# ... etc

# Production (Vercel Environment Variables)
NEXT_PUBLIC_SUPABASE_URL=your-prod-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-prod-key
# ... etc
```

## GitHub Actions Workflows
✅ **CI:** Testes, linting, type checking em cada PR
✅ **Preview Deploy:** Deploy automático para branches feature
✅ **Production Deploy:** Deploy para main com aprovação
✅ **Database Migrations:** Execução automática de migrations

## Monitoramento
✅ **Vercel Analytics:** Métricas de performance e conversão
✅ **Sentry:** Captura de erros em produção
✅ **Supabase Logs:** Monitoramento de queries e auth
✅ **Custom Metrics:** Tempo de treino, taxa de conclusão, etc.

---

# TROUBLESHOOTING COMUM

## Problemas de RLS
**Sintoma:** "new row violates row-level security policy"
**Solução:** Verificar políticas no Supabase Dashboard e garantir que o usuário está autenticado corretamente

## Problemas de CORS
**Sintoma:** Erros CORS em requisições Supabase
**Solução:** Adicionar domínios do Vercel nas configurações de CORS do Supabase

## Problemas de Offline
**Sintoma:** Dados não salvam offline
**Solução:** Verificar se o service worker está registrado e se o IndexedDB está funcionando

## Problemas de Wake Lock
**Sintoma:** Tela desliga durante treino
**Solução:** Verificar suporte do dispositivo e implementação do fallback iOS

## Problemas de Notificações Push
**Sintoma:** Notificações não chegam
**Solução:** Verificar VAPID keys e permissões do usuário

## Problemas de Performance
**Sintoma:** App lento ou travando
**Solução:** Verificar memory leaks, otimizar queries, implementar lazy loading
