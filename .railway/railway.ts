import { defineRailway, github, image, preserve, project, service, volume } from "railway/iac";

export default defineRailway(() => {
  const tianji = github("mc9max/tianji", { branch: "master", checkSuites: false });

  const postgresVolume = volume("tianji-postgres-volume", {
    alerts: { usage: { "100": {}, "80": {}, "95": {} } },
    allowOnlineResize: true,
    region: "us-west2",
    sizeMB: 5000
  });

  const tianjiApp = service("tianji", {
    source: image("moonrailgun/tianji:1.32.38"),
    deploy: { healthcheckPath: "/health" },
    replicas: { "us-west2": 1 },
    env: {
      PGHOST: preserve(),
      PGPORT: preserve(),
      PGUSER: preserve(),
      PGPASSWORD: preserve(),
      PGDATABASE: preserve(),
      DATABASE_URL: preserve(),
      JWT_SECRET: preserve(),
      ALLOW_REGISTER: preserve(),
      ALLOW_OPENAPI: preserve(),
      PUBLIC_URL: preserve(),
      WEBSITE_ID: preserve(),
      JWT_ISSUER: preserve(),
      JWT_AUDIENCE: preserve(),
      CLICKHOUSE_URL: preserve(),
      CLICKHOUSE_USER: preserve(),
      CLICKHOUSE_PASSWORD: preserve(),
      CLICKHOUSE_DATABASE: preserve(),
    },
  });

  const postgres = service("postgres", {
    source: image("postgres:15.14-alpine"),
    replicas: { "us-west2": 1 },
    volumeMounts: { "/var/lib/postgresql/data": postgresVolume },
    env: {
      POSTGRES_USER: preserve(),
      POSTGRES_PASSWORD: preserve(),
      POSTGRES_DB: preserve(),
      PGDATA: "/var/lib/postgresql/data",
      RAILWAY_RUN_UID: "0",
    },
  });
});
