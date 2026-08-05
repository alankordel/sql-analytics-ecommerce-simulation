#!/usr/bin/env bash
set -euo pipefail

project_dir="${PROJECT_DIR:-/workspace}"
db_host="${DB_HOST:-127.0.0.1}"
db_port="${DB_PORT:-3306}"

if [[ -z "${MYSQL_ROOT_PASSWORD:-}" ]]; then
  echo "MYSQL_ROOT_PASSWORD não foi definida." >&2
  exit 1
fi

cd "$project_dir"

mysql \
  --protocol=TCP \
  --host="$db_host" \
  --port="$db_port" \
  --user=root \
  --password="$MYSQL_ROOT_PASSWORD" \
  --default-character-set=utf8mb4 \
  < install.sql

echo "Instalação concluída com sucesso."
