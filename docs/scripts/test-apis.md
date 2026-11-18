# test-apis.sh - Documentação

**Arquivo:** `scripts/test-apis.sh`  
**Tipo:** Shell script (bash)  
**Compatibilidade:** Linux, macOS, WSL2

---

## Objetivo

Validar conectividade e autenticação de todos os serviços do WCIC antes de iniciar operações. Produz relatório `[OK]` / `[WARN]` / `[FAIL]` por verificação. Exit code 0 se nenhum FAIL, exit code 1 se qualquer FAIL.

---

## Pré-requisitos

| Requisito | Verificação |
|---|---|
| Docker em execução | `docker info` |
| `curl` instalado | `which curl` |
| `python3` instalado | `which python3` |
| `.env` preenchido | variáveis de API não podem ser vazias para os testes externos |

---

## Variáveis Utilizadas

| Variável | Seção | Uso |
|---|---|---|
| `POSTGRES_ROOT_PASSWORD` | postgres | Acesso ao container via psql |
| `REDIS_PASSWORD` | redis | redis-cli ping e operações |
| `WEBHOOK_URL` | n8n | Base URL para health check |
| `N8N_BASIC_AUTH_USER` | n8n | Autenticação na API |
| `N8N_BASIC_AUTH_PASSWORD` | n8n | Autenticação na API |
| `FOOTBALL_DATA_API_KEY` | football | Header X-Auth-Token |
| `RAPIDAPI_KEY` | football | Header X-RapidAPI-Key (fallback) |
| `OPENAI_API_KEY` | openai | Bearer token |
| `OPENAI_MODEL` | openai | Modelo a testar (default: gpt-4o) |

---

## Seções de Verificação

| Seção | Verificações |
|---|---|
| **PostgreSQL** | Container rodando, conexão, 4 databases, schema wcic, 5 tabelas críticas, contagem de seeds, migration 005 |
| **Redis** | Container rodando, PING, uso de memória, leitura/escrita |
| **n8n** | 3 containers, health endpoint, API autenticada, contagem de workflows |
| **Football-Data API** | HTTP 200, nome da competição, rate limit disponível, fallback RapidAPI |
| **OpenAI** | HTTP 200, modelo correto |

---

## Opções de Linha de Comando

| Flag | Comportamento |
|---|---|
| (nenhuma) | Testa todos os serviços |
| `--verbose` | Exibe detalhes adicionais em itens OK |
| `--only postgres` | Testa apenas PostgreSQL |
| `--only redis` | Testa apenas Redis |
| `--only n8n` | Testa apenas n8n |
| `--only football` | Testa apenas Football-Data API |
| `--only openai` | Testa apenas OpenAI |

---

## Exemplo de Uso

```bash
# Teste completo
./scripts/test-apis.sh

# Testar apenas banco antes de aplicar migrations
./scripts/test-apis.sh --only postgres

# Testar APIs externas
./scripts/test-apis.sh --only football --only openai

# Verificar n8n após importar workflows
./scripts/test-apis.sh --only n8n --verbose
```

---

## Saída Esperada

```
  ── PostgreSQL ──────────────────────────────────────
  [OK  ] Container wcic-postgres está rodando
  [OK  ] PostgreSQL aceitando conexões
  [OK  ] Database 'n8n' existe
  [OK  ] Database 'wcic' existe
  [OK  ] Schema 'wcic' existe
  [OK  ] Tabela 'wcic.matches' existe
  [OK  ] Times populados (48 times)
  [WARN] Migration 005 não aplicada - Execute: ./scripts/setup-database.sh

  ── Football-Data API (Provider Primário) ──────────
  [OK  ] Football-Data API respondeu - Competição: FIFA World Cup
  [OK  ] Rate limit disponível: 9 req/min restantes
  [WARN] RAPIDAPI_KEY não definido - Fallback API não testada

═══════════════════════════════════════════════════
  Relatório Final
═══════════════════════════════════════════════════
  Total de verificações : 18
  Passaram [OK]         : 16
  Avisos   [WARN]       : 2
  Falhas   [FAIL]       : 0

  Status: APROVADO COM AVISOS - sistema funcional, mas verifique os [WARN]
```

---

## Possíveis Erros

| Item | Causa Comum | Solução |
|---|---|---|
| `[FAIL] Container wcic-postgres não encontrado` | Stack não iniciada | `docker-compose up -d` |
| `[FAIL] Database 'wcic' não encontrado` | Setup não executado | `./scripts/setup-database.sh` |
| `[FAIL] Football-Data API - token inválido (HTTP 401)` | Key incorreta ou expirada | Verificar em football-data.org |
| `[FAIL] OpenAI API - chave inválida (HTTP 401)` | Key incorreta | Verificar em platform.openai.com |
| `[WARN] Migration 005 não aplicada` | Setup desatualizado | `./scripts/setup-database.sh` |

---

## Troubleshooting

**Script retorna FAIL mas serviço está rodando:**
```bash
# Verificar se o container tem o nome exato esperado
docker ps --format "{{.Names}}"
# O script espera: wcic-postgres, wcic-redis, wcic-n8n-main
```

**OpenAI retorna 429 mesmo com saldo:**
Pode ser rate limit de RPM (requests per minute) atingido. Aguardar 60s e tentar novamente.
