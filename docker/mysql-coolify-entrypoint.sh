#!/bin/bash
# Coolify injects shared app env into EVERY compose service.
# Official MySQL image exits if MYSQL_USER=root, or MYSQL_PASSWORD without a
# non-root MYSQL_USER. Normalize env, then hand off to the real entrypoint.
set -euo pipefail

ROOT_PW="${MYSQL_ROOT_PASSWORD:-${MYSQL_PASSWORD:-infini_rag_flow}}"
DB_NAME="${MYSQL_DATABASE:-rag_flow}"

if [ "${MYSQL_USER:-}" = "root" ]; then
  echo "coolify-entrypoint: ignoring MYSQL_USER=root from Coolify shared env"
  APP_USER="rag_flow"
  APP_PW="$ROOT_PW"
else
  APP_USER="${MYSQL_USER:-rag_flow}"
  APP_PW="${MYSQL_PASSWORD:-$ROOT_PW}"
fi

export MYSQL_ROOT_PASSWORD="$ROOT_PW"
export MYSQL_DATABASE="$DB_NAME"
export MYSQL_USER="$APP_USER"
export MYSQL_PASSWORD="$APP_PW"

echo "coolify-entrypoint: starting mysqld (database=$MYSQL_DATABASE user=$MYSQL_USER)"
exec docker-entrypoint.sh mysqld
