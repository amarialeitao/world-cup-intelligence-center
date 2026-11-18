# import-workflows.sh - Documentação

**Arquivo:** `scripts/import-workflows.sh`  
**Tipo:** Shell script (bash)  
**Compatibilidade:** Linux, macOS, WSL2

---

## Objetivo

Importar todos os arquivos JSON de `n8n/workflows/` para a instância n8n via API REST. Detecta automaticamente se cada workflow já existe (por nome) e executa PUT para atualizar ou POST para criar. Idempotente: pode ser executado múltiplas vezes.

---

## Pré-requisitos

| Requisito | Verificação |
|---|---|
| Container `wcic-n8n-main` em execução | `docker ps \| grep wcic-n8n-main` |
| `curl` instalado | `which curl` |
| `jq` instalado | `which jq` (instalar: `sudo apt-get install -y jq`) |
| `.env` com `N8N_BASIC_AUTH_*` e `WEBHOOK_URL` | `grep N8N_BASIC_AUTH .env` |
| Arquivos JSON em `n8n/workflows/` | `ls n8n/workflows/*.json` |

---

## Variáveis Utilizadas

| Variável | Obrigatória | Uso |
|---|---|---|
| `WEBHOOK_URL` | ✅ | Base URL do n8n (ex: `http://localhost:5678/`) |
| `N8N_BASIC_AUTH_USER` | ✅ | Usuário para autenticação básica |
| `N8N_BASIC_AUTH_PASSWORD` | ✅ | Senha para autenticação básica |

---

## Fluxo de Execução

```
1. Verifica dependências (curl, jq)
2. Carrega .env
3. Constrói N8N_API_URL a partir de WEBHOOK_URL
4. Testa conectividade: GET /api/v1/workflows → espera HTTP 200
5. Busca workflows existentes: GET /api/v1/workflows?limit=100
   └─► Constrói mapa: nome → id
6. Para cada *.json em n8n/workflows/:
   a. Valida JSON (jq empty)
   b. Extrai nome do workflow (.name)
   c. Se já existe (por nome): PUT /api/v1/workflows/{id}
   d. Se não existe: POST /api/v1/workflows
   e. Registra resultado: IMPORTADO | ATUALIZADO | FALHOU
7. Exibe resumo
8. Avisa que workflows ficam INATIVOS após importação
```

---

## Opções de Linha de Comando

| Flag | Comportamento |
|---|---|
| (nenhuma) | Importa todos os arquivos em `n8n/workflows/` |
| `--dry-run` | Valida JSONs sem fazer requisições |
| `--file NOME.json` | Importa apenas o arquivo especificado |

---

## Exemplo de Uso

```bash
# Importar todos os workflows
./scripts/import-workflows.sh

# Testar sem importar
./scripts/import-workflows.sh --dry-run

# Importar apenas WF-01
./scripts/import-workflows.sh --file WF-01-match-collector.json

# Atualizar WF-07 após modificação
./scripts/import-workflows.sh --file WF-07-notification-hub.json
```

---

## Saída Esperada

```
  [OK]   curl disponível
  [OK]   jq disponível
  [OK]   n8n URL: http://localhost:5678
  [OK]   n8n API autenticada (HTTP 200)
  [OK]   2 workflow(s) já existente(s) no n8n

▶ Importando workflows

  [INFO] Processando: WF-01-match-collector.json
  [OK]   IMPORTADO: 'WF-01 - Match Collector' (novo id: abc123)
  [INFO] Processando: WF-02-live-event-monitor.json
  [OK]   ATUALIZADO: 'WF-02 - Live Event Monitor' (id: def456)
  [INFO] Processando: WF-07-notification-hub.json
  [OK]   IMPORTADO: 'WF-07 - Notification Hub' (novo id: ghi789)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Resultado da importação
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Novos importados : 2
  Atualizados      : 1
  Com falha        : 0

  [WARN] workflows importados ficam INATIVOS por padrão.
  [WARN] Ative cada workflow manualmente na UI: http://localhost:5678
```

---

## Possíveis Erros

| Mensagem | Causa | Solução |
|---|---|---|
| `n8n inacessível em http://localhost:5678` | Container não iniciado | `docker-compose up -d n8n` |
| `Credenciais n8n inválidas (HTTP 401)` | Senha incorreta | Verificar `N8N_BASIC_AUTH_PASSWORD` no `.env` |
| `JSON inválido: WF-XX.json` | Arquivo corrompido | Reexportar do n8n ou corrigir manualmente |
| `FALHOU ao importar: HTTP 400` | Schema de node inválido | Verificar versão do n8n vs versão usada para criar o JSON |
| `jq não encontrado` | Pacote não instalado | `sudo apt-get install -y jq` |

---

## Troubleshooting

**Workflow importado mas sem os nodes corretos:**
O JSON pode ter sido gerado para uma versão diferente do n8n. Verificar `typeVersion` dos nodes vs versão instalada: `docker exec wcic-n8n-main n8n --version`.

**Workflow duplicado (dois com o mesmo nome):**
O script detecta por nome. Se houver dois workflows com o mesmo nome no n8n, o comportamento é indefinido. Remover o duplicado via UI antes de importar.

**Após importação, workflow não aparece na UI:**
Fazer refresh da página. O n8n pode ter cacheado a lista anterior.
