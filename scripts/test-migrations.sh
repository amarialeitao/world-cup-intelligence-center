#!/usr/bin/env bash
# =============================================================================
# WCIC — scripts/test-migrations.sh
#
# Objetivo:
#   Criar o banco do zero num PostgreSQL + TimescaleDB vazio e confirmar que
#   o init, todas as migrations (em ordem) e os seeds rodam sem erro.
#   Usado pelo CI; também pode ser executado localmente contra um banco
#   descartável.
#
# Uso:
#   PGHOST=localhost PGUSER=postgres PGPASSWORD=postgres ./scripts/test-migrations.sh
#
# ATENÇÃO: cria os databases n8n, wcic, metabase e grafana. Não use contra
# um banco com dados reais.
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PSQL=(psql -v ON_ERROR_STOP=1 --quiet)

# Senhas descartáveis, apenas para o banco de teste
export POSTGRES_N8N_PASSWORD=test POSTGRES_WCIC_PASSWORD=test \
       POSTGRES_METABASE_PASSWORD=test POSTGRES_GRAFANA_PASSWORD=test

echo ">>> init.sql (usuários, databases e extensões)"
envsubst '${POSTGRES_N8N_PASSWORD}${POSTGRES_WCIC_PASSWORD}${POSTGRES_METABASE_PASSWORD}${POSTGRES_GRAFANA_PASSWORD}' \
  < "$PROJECT_ROOT/docker/postgres/init.sql" | "${PSQL[@]}" -d postgres

for file in "$PROJECT_ROOT"/database/migrations/*.sql; do
  echo ">>> migration $(basename "$file")"
  "${PSQL[@]}" -d wcic -f "$file"
done

for file in "$PROJECT_ROOT"/database/seeds/*.sql; do
  echo ">>> seed $(basename "$file")"
  "${PSQL[@]}" -d wcic -f "$file"
done

echo ">>> conferência"
"${PSQL[@]}" -d wcic -c "
  SELECT
    (SELECT COUNT(*) FROM information_schema.tables
      WHERE table_schema = 'wcic' AND table_type = 'BASE TABLE') AS tabelas,
    (SELECT COUNT(*) FROM information_schema.views
      WHERE table_schema = 'wcic') AS views,
    (SELECT COUNT(*) FROM timescaledb_information.hypertables) AS hypertables,
    (SELECT COUNT(*) FROM wcic.teams) AS selecoes,
    (SELECT COUNT(*) FROM wcic.venues) AS estadios;"

hypertables=$("${PSQL[@]}" -d wcic -tAc "SELECT COUNT(*) FROM timescaledb_information.hypertables")
teams=$("${PSQL[@]}" -d wcic -tAc "SELECT COUNT(*) FROM wcic.teams")

if [[ "$hypertables" -lt 3 || "$teams" -eq 0 ]]; then
  echo "[ERR] Esperado: ao menos 3 hypertables e seleções carregadas." >&2
  exit 1
fi

echo "[OK] Banco criado do zero com sucesso."
