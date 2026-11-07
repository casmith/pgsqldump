#!/bin/bash
set -euo pipefail

DB_USER=${DB_USER:-${PGSQL_ENV_DB_USER:-}}
DB_PASS=${DB_PASS:-${PGSQL_ENV_DB_PASS:-}}
DB_NAME=${DB_NAME:-${PGSQL_ENV_DB_NAME:-}}
DB_HOST=${DB_HOST:-${PGSQL_ENV_DB_HOST:-}}
FLAGS=${FLAGS:-}
OUT_DIR=${OUT_DIR:-/pgsqldump}
# Delete this database's dumps older than RETENTION_DAYS after a successful dump.
# Unset or 0 keeps everything. The newest KEEP_MIN dumps are never deleted.
RETENTION_DAYS=${RETENTION_DAYS:-0}
KEEP_MIN=${KEEP_MIN:-3}
TS=$(date +%Y%m%dT%H%M%S)

for var in DB_USER DB_PASS DB_HOST DB_NAME; do
  if [[ -z ${!var} ]]; then
    echo "Missing ${var} env variable" >&2
    exit 1
  fi
done
if ! [[ ${RETENTION_DAYS} =~ ^[0-9]+$ && ${KEEP_MIN} =~ ^[0-9]+$ ]]; then
  echo "RETENTION_DAYS and KEEP_MIN must be whole numbers" >&2
  exit 1
fi

final="${OUT_DIR}/${DB_NAME}_${TS}.sql.gz"
tmp="${final}.partial"
trap 'rm -f "${tmp}"' EXIT

# Write to a temporary file and only rename it into place once pg_dump and gzip
# both succeed, so a failed run never leaves a truncated dump that looks valid.
# shellcheck disable=SC2086
PGPASSWORD="${DB_PASS}" pg_dump ${FLAGS} --username="${DB_USER}" --dbname="${DB_NAME}" --host="${DB_HOST}" "$@" | gzip -c >"${tmp}"
gzip -t "${tmp}"
if [[ $(gzip -dc "${tmp}" | head -c 1 | wc -c) -eq 0 ]]; then
  echo "pg_dump produced no output" >&2
  exit 1
fi
mv "${tmp}" "${final}"
echo "Wrote ${final} ($(wc -c <"${final}") bytes)"

if [[ ${RETENTION_DAYS} -gt 0 ]]; then
  # Newest first; skip the KEEP_MIN newest, then delete the rest if old enough.
  mapfile -t dumps < <(ls -1t "${OUT_DIR}/${DB_NAME}"_*.sql.gz 2>/dev/null || true)
  for f in "${dumps[@]:${KEEP_MIN}}"; do
    if [[ -n $(find "${f}" -mtime +"${RETENTION_DAYS}" 2>/dev/null) ]]; then
      rm -f "${f}"
      echo "Deleted ${f} (older than ${RETENTION_DAYS} days)"
    fi
  done
fi
