# SOBRE O PROJETO

## Nome Oficial
Sistema PWA de Gerenciamento de Treinos - Personal Trainer e Alunos

## Objetivo Principal
Criar um Progressive Web App que permita personal trainers (Persona 1) gerenciarem treinos e alunos (Persona 2) executarem sessões de treino na academia com:

✅ **Timer preciso** (Web Workers, erro máx. 1s em 10min)
✅ **Wake Lock API** (tela sempre ligada)
✅ **Vibração háptica** (Android) + Fallback iOS (som + alerta visual)
✅ **Funcionamento 100% offline** com Background Sync API
✅ **Sincronização automática** quando voltar online
✅ **Instalação no home screen** (iOS + Android + Desktop) com splash screens otimizados
✅ **Notificações push** com VAPID keys e fallback para in-app notifications
✅ **Avaliação física automatizada** com cálculos antropométricos em tempo real

## Escopo do MVP (Atualizado)
**Autenticação:**
- Login aluno/trainer com Supabase Auth
- Convites via token de 6 dígitos com expiração (24h)
- OAuth providers (Google, Apple) para melhor conversão
- Proteção contra brute force com rate limiting

**Dashboard Trainer:**
- Visualizar alunos ativos com status em tempo real
- Criar/excluir/editar treinos com drag-and-drop
- Realizar avaliações físicas com cálculos automáticos (IMC, % gordura, etc.)
- Acompanhamento em tempo real via Supabase Realtime

**Dashboard Aluno:**
- Ver treinos atribuídos com prioridade visual para "hoje"
- Histórico de execução com métricas de progresso
- Notificações push para treinos não iniciados

**Player de Treino (Componente Crítico):**
- Interface focada no exercício atual
- Timer preciso com Web Workers
- Feedback háptico em transições
- Wake Lock API com fallback para iOS
- Salvamento offline automático com IndexedDB
- Sincronização em background quando online

**Biblioteca de Exercícios:**
- CRUD de exercícios personalizado por trainer
- Upload de vídeos instrutivos (Supabase Storage)
- Categorização por grupos musculares
- Busca e filtragem avançada

**Relatório de Avaliações:**
- Gráficos de progresso com Chart.js otimizado
- Comparação entre avaliações
- Exportação para PDF (File System Access API)

**Modo Offline Completo:**
- IndexedDB com estrutura otimizada para queries
- Background Sync API com fila de prioridade
- Indicador visual de status offline/online
- Dados críticos sempre disponíveis offline

### Não está no MVP (v1)
- Integração com wearables (Apple Health, Google Fit)
- Análise de movimentos por IA (reconhecimento de postura)
- Marketplace de exercícios (compra/venda de templates)
- App Store/Google Play (PWA apenas - App Stores em v2)
- Videochamadas integradas (Zoom/WebRTC)

---

# PERSONAS E CASOS DE USO DETALHADOS

## PERSONA 1: PERSONAL TRAINER (PT)
**Dados do Perfil:**
- Email, nome completo, foto de perfil (obrigatório)
- Contato para alunos (WhatsApp/Email - opcional)
- Especialidades (múltipla escolha: musculação, funcional, cardio, crossfit, yoga)
- Certificações (títulos profissionais)
- Status ativo/inativo (controlado pelo sistema)
- Taxa por sessão (opcional para marketplace v2)

**Funcionalidades Principais:**

### Dashboard Principal
- **Visualização de Alunos Ativos:** Card com contador e gráfico de crescimento semanal
- **Treinos Pendentes:** Lista dos últimos 5 treinos não iniciados pelos alunos
- **Últimas Avaliações:** Cards resumo das últimas 3 avaliações realizadas
- **Métricas de Performance:**
  - Taxa de conclusão de treinos (média dos alunos)
  - Progresso médio em avaliações físicas
  - Tempo médio de resposta a mensagens (futuro)
- **Atalhos Rápidos:**
  - "+ Novo Treino" (botão primário)
  - "+ Nova Avaliação"
  - "+ Convidar Aluno"

### Gerenciar Alunos
- **Listagem de Alunos:** Tabela com colunas:
  - Nome + foto
  - Status (ativo, pendente, inativo)
  - Último treino (data)
  - Próximo treino (data)
  - Progresso (%)
- **Ações por Aluno:**
  - Visualizar perfil completo
  - Ver histórico de treinos
  - Ver histórico de avaliações
  - Editar status
  - Remover aluno (confirmação dupla)
- **Convidar Novo Aluno:**
  - Formulário com email do aluno
  - Geração automática de token único de 6 dígitos
  - Envio automático de email com link de convite
  - Token expira em 24h
  - Histórico de convites (ativos/expirados/aceitos)

### Biblioteca de Exercícios (Personalizada por PT)
- **Criar Exercício:**
  - Nome (obrigatório, máx. 100 caracteres)
  - Descrição detalhada (opcional)
  - Grupos musculares (múltipla escolha)
  - Nível de dificuldade (iniciante/intermediário/avançado)
  - Vídeo instrutivo (upload ou URL YouTube/Vimeo)
  - Imagem de referência
  - Notas adicionais
- **Gerenciamento:**
  - Ordenação por nome/data/uso
  - Busca por nome ou grupo muscular
  - Filtro por dificuldade
  - Duplicar exercício existente
  - Exportar biblioteca como CSV
- **Integração com Treinos:**
  - Drag-and-drop para adicionar a treinos
  - Preview rápido do vídeo
  - Sugestões baseadas em histórico

### Criar/Editar Treino
- **Informações Básicas:**
  - Nome do treino (ex: "Dia A - Peito e Tríceps")
  - Descrição (objetivo do treino)
  - Tipo (força, resistência, HIIT, funcional)
  - Duração estimada (em minutos)
- **Construção do Treino:**
  - Interface de drag-and-drop para exercícios
  - Para cada exercício:
    - Número de séries (1-10)
    - Repetições por série (1-100 ou "até falha")
    - Descanso entre séries (15-300 segundos)
    - Peso sugerido (kg/lbs)
    - Notas específicas por exercício
  - Ordem personalizável dos exercícios
  - Preview do tempo total estimado
- **Ações:**
  - Salvar como template
  - Duplicar treino existente
  - Atribuir a aluno específico
  - Atribuir a múltiplos alunos
  - Agendar para data específica

### Acompanhamento em Tempo Real
- **Presença em Tempo Real:**
  - Indicador visual de alunos online
  - Última atividade (online/offline há X minutos)
- **Acompanhamento de Execução:**
  - Ver aluno executando treino atual
  - Exercício e série atual
  - Tempo decorrido na sessão
  - Tempo de descanso restante
- **Interações:**
  - Enviar mensagem rápida durante o treino
  - Ajustar peso/séries em tempo real
  - Notificação quando aluno completa treino
  - Opção de "pausar treino" remotamente (emergências)
- **Histórico:**
  - Lista de sessões recentes
  - Detalhes por sessão (exercícios completados, peso usado, notas)

### Avaliações Físicas
- **Dados da Avaliação:**
  - Data da avaliação (obrigatório)
  - Antropometria:
    - Altura (cm)
    - Peso atual (kg)
    - % gordura corporal (medido)
    - % massa muscular
  - Medidas corporais:
    - Peito (cm)
    - Cintura (cm)
    - Quadril (cm)
    - Braço direito/esquerdo (cm)
    - Coxa direita/esquerda (cm)
    - Panturrilha (cm)
  - Fotos de referência (antes/depois)
  - Notas gerais (observações do trainer)
- **Cálculos Automáticos:**
  - IMC (Índice de Massa Corporal)
  - Gordura em kg (peso total × % gordura)
  - Massa magra em kg
  - Relação cintura/quadril
  - Progresso desde última avaliação
- **Visualização:**
  - Gráficos de linha para métricas-chave
  - Comparação lado a lado entre avaliações
  - Tendências (melhora/estagnação/regressão)
  - Projeção de metas
- **Compartilhamento:**
  - Gerar relatório PDF
  - Enviar para aluno via app
  - Opção de compartilhar resultados (com permissão)

## PERSONA 2: ALUNO (PRATICANTE)
**Dados do Perfil:**
- Email, nome completo, foto de perfil
- Objetivo principal (ganhar massa muscular, perder peso, melhorar performance, saúde geral)
- Objetivos secundários (múltipla escolha)
- Lesões/restrições médicas (texto livre)
- Nível de experiência (iniciante/intermediário/avançado)
- Disponibilidade semanal (dias/horários)
- Equipamentos disponíveis (academia/casa)
- Data de adesão ao programa

**Funcionalidades Principais:**

### Primeiros Passos (Onboarding)
- **Recebimento de Convite:**
  - Email com token de 6 dígitos e link de acesso
  - Página de aceitação de convite com token
  - Validação automática do token (expira em 24h)
- **Criação de Conta:**
  - Opções de cadastro:
    - Email + senha (mínimo 8 caracteres, maiúsculas, números)
    - Google OAuth
    - Apple OAuth (para iOS)
  - Termos de uso e política de privacidade
  - Vinculação automática ao trainer após aceitação
- **Setup Inicial:**
  - Questionário de metas e restrições
  - Upload de foto de perfil (opcional)
  - Configuração de notificações preferenciais
  - Configuração de unidade de medida (kg/lbs)
- **Primeiro Acesso:**
  - Tutorial interativo do app
  - Destaque para primeiro treino
  - Explicação do player de treino
  - Configuração de PWA (instalar no dispositivo)

### Dashboard Principal
- **Treino de Hoje:**
  - Card destacado com nome do treino
  - Progresso (se já iniciado)
  - Botão grande "Iniciar Treino" (se não iniciado)
  - Tempo estimado de duração
- **Próximos Treinos:**
  - Lista dos próximos 3 treinos da semana
  - Data e dia da semana
  - Status (pendente, concluído, faltou)
- **Últimas Avaliações:**
  - Cards resumo das últimas 2 avaliações
  - Destaque para mudanças significativas
  - Botão "Ver Progresso Completo"
- **Métricas Pessoais:**
  - Séries completadas esta semana
  - Tempo total de treino
  - Comparação com semana anterior
- **Notificações:**
  - Ícone com contador de notificações não lidas
  - Push notifications para treinos diários
  - Lembretes de avaliações próximas

### Visualizar Treino
- **Informações do Treino:**
  - Nome e descrição
  - Data de atribuição
  - Tempo estimado total
  - Nível de dificuldade
- **Lista de Exercícios:**
  - Ordem sequencial de execução
  - Para cada exercício:
    - Nome e imagem/vídeo preview
    - Número de séries
    - Repetições por série
    - Peso sugerido
    - Descanso entre séries
    - Notas específicas do trainer
- **Ações:**
  - Botão "Executar Treino" (se não iniciado)
  - Botão "Continuar Treino" (se em progresso)
  - Botão "Ver Histórico" (se concluído)
  - Compartilhar treino (com permissão)
- **Status Visual:**
  - Indicador de progresso geral (ex: 3/6 exercícios)
  - Destaque para próximo exercício
  - Badge de "treino do dia" se aplicável

### Executar Treino (CRÍTICO - Player)
**Interface Principal:**
- **Área Central (70% da tela):**
  - Foto/vídeo grande do exercício atual
  - Nome do exercício em destaque
  - Demonstração animada (se disponível)
- **Informações do Exercício:**
  - Grupo muscular principal
  - Nível de dificuldade
  - Notas específicas do trainer
- **Progresso Visual:**
  - Contador de séries: "Série 2 de 4"
  - Contador de repetições: "10 reps"
  - Peso utilizado: "10kg (sugerido: 12kg)"
  - Barra de progresso visual

**Componentes de Controle:**
- **Botão Principal "Série Completa":**
  - Tamanho grande, fácil de tocar
  - Haptic feedback imediato ao tocar
  - Animação de confirmação
  - Desativa brevemente para evitar cliques múltiplos
- **Timer de Descanso:**
  - Contador regressivo grande e legível
  - Barra visual de progresso do tempo
  - Cores que mudam conforme tempo (verde → amarelo → vermelho)
  - Botão "Pular Descanso" (visível após 10s)
- **Navegação:**
  - Botão "< Exercício Anterior" (desativado no primeiro)
  - Botão "Próximo Exercício >" (desativado durante descanso)
  - Menu de opções (3 pontos) com:
    - Pausar treino
    - Ajustar peso
    - Adicionar nota
    - Ver instruções completas

**Funcionamento do Timer:**
- **Ao clicar "Série Completa":**
  1. Haptic feedback imediato
  2. Ativa Wake Lock (tela SEMPRE ligada)
  3. Inicia timer de descanso no Web Worker
  4. Mostra contagem regressiva visual
  5. Desabilita botões de navegação durante descanso
- **Durante o Descanso:**
  - Timer rodando em thread separada (Web Worker)
  - Atualização visual a cada segundo
  - Botão "Pular Descanso" disponível após 10s
  - Indicador visual de progresso do tempo
- **Ao Final do Descanso:**
  - Vibração forte (Android) ou som + flash (iOS)
  - Transição automática para próximo exercício
  - Feedback visual de mudança
  - Atualização do progresso geral
- **Tratamento de Interrupções:**
  - Se app for para background: pausa timer
  - Se app voltar para foreground: retoma timer
  - Se conexão cair: continua funcionando offline
  - Se bateria < 15%: alerta visual para conclusão rápida

**Histórico Durante Execução:**
- **Dados Salvos por Série:**
  - Timestamp de início/fim
  - Peso realmente utilizado
  - Número de repetições completadas
  - Notas opcionais adicionadas pelo aluno
  - Fotos de antes/depois (opcional)
- **Progresso em Tempo Real:**
  - Atualização visual do progresso geral
  - Indicador de tempo total decorrido
  - Previsão de tempo restante
  - Percentual de conclusão do treino
- **Offline Storage:**
  - Todos os dados salvos em IndexedDB imediatamente
  - Confirmação visual de salvamento offline
  - Indicador de status de sincronização

**Finalização:**
- **Tela de Resumo:**
  - Tempo total de treino
  - Número de séries realizadas vs planejado
  - Peso médio utilizado
  - Calorias estimadas (fórmula simples)
  - Notas gerais adicionadas pelo aluno
- **Ações de Finalização:**
  - Botão "Finalizar Treino" (confirmação)
  - Opção "Treino Incompleto" (com motivo)
  - Adicionar foto de finalização (opcional)
  - Classificar dificuldade do treino (1-5)
- **Pós-Finalização:**
  - Salvamento em IndexedDB
  - Agendamento de Background Sync
  - Notificação ao trainer
  - Redirecionamento para dashboard
  - Sugestão de hidratação/alongamento

### Offline Completo:
- **Detecção de Conexão:**
  - Navigator.onLine API
  - Fallback para heartbeat API
  - Indicador visual claro de status offline
- **Funcionalidades Disponíveis Offline:**
  - Executar treinos atribuídos
  - Ver histórico recente
  - Acessar exercícios favoritos
  - Ver último treino concluído
- **Funcionalidades Restritas Offline:**
  - Novos treinos (requer conexão para download)
  - Avaliações físicas (dados sensíveis)
  - Mensagens com trainer (fila para envio)
- **Sincronização Automática:**
  - Background Sync API quando online
  - Prioridade para dados críticos (sessões de treino)
  - Retry automático em falhas
  - Indicador visual de sincronização em progresso
- **Gestão de Espaço:**
  - Limpeza automática de dados antigos (>30 dias offline)
  - Alerta quando espaço de armazenamento está baixo
  - Opção manual de limpar cache

### Histórico de Treinos
- **Lista de Sessões:**
  - Data e dia da semana
  - Nome do treino
  - Status (concluído, incompleto, abandonado)
  - Tempo total
  - Percentual de conclusão
- **Filtros e Ordenação:**
  - Período (última semana, último mês, personalizado)
  - Tipo de treino
  - Status
  - Ordenar por data, duração, etc.
- **Detalhes da Sessão:**
  - Todos os exercícios executados
  - Séries completadas por exercício
  - Peso utilizado vs sugerido
  - Notas adicionadas durante execução
  - Fotos anexadas
- **Gráficos de Progresso:**
  - Evolução de peso utilizado por exercício
  - Tempo total de treino por semana
  - Consistência (dias treinados/semana)
  - Comparação com metas estabelecidas
- **Exportação:**
  - Exportar histórico como CSV
  - Gerar relatório mensal em PDF
  - Compartilhar progresso (com permissão)

### Avaliações
- **Visualização de Avaliações:**
  - Lista cronológica de avaliações
  - Destaque para últimas mudanças significativas
  - Comparação visual entre avaliações
- **Gráficos de Progresso:**
  - Peso corporal (linha)
  - % gordura corporal (linha)
  - Medidas corporais (barras comparativas)
  - IMC (gauge com zonas)
- **Métricas Chave:**
  - Progresso desde início
  - Progresso último mês
  - Comparação com metas
  - Taxa de progresso (semanal/mensal)
- **Tendências:**
  - Setas indicando direção (↑↓→)
  - Cores para status (verde=melhora, amarelo=estagnado, vermelho=regressão)
  - Previsões baseadas em histórico
- **Ações:**
  - Solicitar nova avaliação ao trainer
  - Adicionar notas pessoais
  - Upload de fotos de progresso
  - Definir novas metas
