# Tianji — website analytics + uptime monitor + server status, in one dashboard.
#
# Base is the official prebuilt image (pnpm monorepo already built, Chromium +
# tianji-reporter bundled). We only wrap the entrypoint to:
#   1. WAIT for PostgreSQL before `prisma migrate deploy` (the stock CMD migrates
#      immediately at boot — on Railway the app and DB start in parallel, so the
#      first boot frequently crashes migrate before the DB is up and the server
#      never serves),
#   2. apply ClickHouse migrations only when CLICKHOUSE_URL is configured,
#   3. run the Node server in the FOREGROUND as PID 1 (the stock CMD forks it
#      into the background behind the telemetry reporter).
#
# The server runs as root in the stock image (uid 0), which Railway volumes
# tolerate — and Postgres (companion service) owns its own data volume.

FROM moonrailgun/tianji:1.32.38

USER root

EXPOSE 12345

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD curl -sf http://localhost:12345/health || exit 1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
