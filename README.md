# Tianji

Website analytics + uptime monitor + server status, in one dashboard. Not only another Google Analytics alternative — Tianji gives you real-time visitor tracking, uptime monitoring, and server health metrics in a single self-hosted platform.

Two services: Tianji (web app) + PostgreSQL (database).

## Deploy and Host

Host your own Tianji on Railway. This template provisions the all-in-one Tianji container (website analytics, uptime monitoring, server status reporting) and a PostgreSQL companion for persistence. All data persists in a Railway volume at `/var/lib/postgresql/data`.

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.com/deploy/tianji)

## Why Deploy

Tianji is the open-source analytics platform that combines three essential tools into one:

- **Website Analytics** — privacy-friendly alternative to Google Analytics with real-time visitor tracking, page views, and session analytics
- **Uptime Monitoring** — monitor your websites and services with instant downtime alerts
- **Server Status** — track CPU, memory, disk, and network metrics from your infrastructure

Running it on Railway gives you a durable, auto-updating, globally reachable instance with:

- **Full data ownership** — your analytics data lives on your Railway volume, not a third-party server
- **Real-time dashboards** — see visitor activity and server health as it happens
- **Alerting** — get notified when services go down or metrics cross thresholds
- **Reporter agents** — lightweight agents that collect and report metrics from your infrastructure
- **No ad stack** — plain self-hosted software, your analytics

## Common Use Cases

- **Privacy-conscious site owners** who want analytics without Google tracking
- **DevOps teams** who need unified uptime + server monitoring
- **Indie hackers** who want a single dashboard for all their projects
- **Agencies** who manage multiple client sites and need consolidated reporting

### Deployment Dependencies

The deploy form pre-fills all companion variables (DB host / name / user / password are wired to the PostgreSQL service via private-domain references — nothing to type).

**After the first successful deploy:**

1. Open `https://<your-domain>` — the Tianji dashboard
2. Create your first workspace and website to start tracking
3. Add the tracking script to your website's `<head>` section
4. (Optional) Deploy the Tianji reporter agent to your servers for infrastructure monitoring

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | Full PostgreSQL connection string (auto-composed from PG* vars) | (empty) |
| `JWT_SECRET` | Random string for JWT signing (auto-generated) | (auto) |
| `ALLOW_REGISTER` | Allow new user registration | `false` |
| `ALLOW_OPENAPI` | Expose OpenAPI documentation | `true` |
| `PUBLIC_URL` | Public URL of this instance | (auto-filled) |
| `WEBSITE_ID` | UUID for self-tracking this instance | (empty) |
| `CLICKHOUSE_URL` | ClickHouse connection URL (optional) | (empty) |

## Service Architecture

- **tianji** — Main web application (analytics, uptime, server status)
- **postgres** — PostgreSQL 15 database companion

## Volumes

- `/var/lib/postgresql/data` — PostgreSQL data directory (persistent)

## Health Checks

- Tianji: `GET /health` on port 8080
- PostgreSQL: Built-in `pg_isready` check

## License

Tianji is open-source under the Apache License 2.0. This template is provided as-is for Railway deployment.
