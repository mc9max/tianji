#!/bin/sh
set -e

# Tianji waits for PostgreSQL before running Prisma migrations, then starts the
# server in the FOREGROUND (PID 1) so Railway healthchecks and signals manage it
# properly. The stock image CMD instead runs migrate at boot with no DB wait and
# forks the server into the background — on Railway (app + DB boot in parallel)
# the very first migrate frequently crashes on a not-yet-ready DB and the
# container serves nothing.

# --- Compose DATABASE_URL from component vars when the app did not set one ---
# On Railway the template wires PGUSER/PGPASSWORD/PGDATABASE/PGHOST/PGPORT as
# single-value refs back to the sibling `postgres` service (each is one
# ${{postgres.VAR}} reference, which Railway resolves reliably — composing
# several refs in one value is not). The app reads them, and this entrypoint
# assembles the connection string. A manually-set DATABASE_URL always wins.
if [ -z "${DATABASE_URL}" ] && [ -n "${PGUSER}" ]; then
  PGHOST="${PGHOST:-postgres}"
  PGPORT="${PGPORT:-5432}"
  PGDATABASE="${PGDATABASE:-tianji}"
  PGPASSWORD="${PGPASSWORD:-}"
  if [ -n "${PGPASSWORD}" ]; then
    export DATABASE_URL="postgresql://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}/${PGDATABASE}"
  else
    export DATABASE_URL="postgresql://${PGUSER}@${PGHOST}:${PGPORT}/${PGDATABASE}"
  fi
  echo "[tianji-entrypoint] composed DATABASE_URL from PG* component vars (host=${PGHOST}:${PGPORT} db=${PGDATABASE})"
fi
export DATABASE_URL
echo "[tianji-entrypoint] database target host/port extracted"

# --- Parse DB host/port out of DATABASE_URL (robust to user:pass in the URL) ---
HOSTPORT=""
if [ -n "${DATABASE_URL}" ]; then
  HOSTPORT="${DATABASE_URL#*://}"   # strip scheme
  HOSTPORT="${HOSTPORT##*@}"       # strip userinfo (user:pass@)
fi
if [ -n "${HOSTPORT}" ]; then
  case "${HOSTPORT}" in
    *:*) DB_HOST="${HOSTPORT%%:*}"; DB_PORT="${HOSTPORT#*:}" ;;
    *)   DB_HOST="${HOSTPORT}";   DB_PORT="5432" ;;
  esac
  DB_PORT="${DB_PORT%%/*}"
else
  DB_HOST="postgres"
  DB_PORT="5432"
fi

echo "[tianji-entrypoint] waiting for database at ${DB_HOST}:${DB_PORT} ..."
i=0
while ! node -e "
  const net = require('net');
  const s = net.connect({ host: '${DB_HOST}', port: Number('${DB_PORT}'), timeout: 2000 });
  s.on('connect', () => { s.end(); process.exit(0); });
  s.on('error',   () => process.exit(1));
  s.on('timeout', () => { s.destroy(); process.exit(1); });
"; do
  i=$((i + 1))
  echo "[tianji-entrypoint] database not up yet (attempt ${i})"
  sleep 3
done
echo "[tianji-entrypoint] database reachable"

cd /app/tianji/src/server
echo "[tianji-entrypoint] applying Prisma migrations"
./node_modules/.bin/prisma migrate deploy

if [ -n "${CLICKHOUSE_URL}" ]; then
  echo "[tianji-entrypoint] applying ClickHouse migrations"
  ./node_modules/.bin/tsx ./clickhouse/scripts/apply.ts
else
  echo "[tianji-entrypoint] ClickHouse not configured, skipping ClickHouse migrations"
fi

echo "[tianji-entrypoint] starting Tianji server (foreground)"
exec env NODE_ENV=production node ./dist/src/server/main.js
