FROM postgres:15.14-alpine

# Railway volumes mount root-owned. The official postgres image runs as uid 999
# (postgres user), which cannot write to a root-owned volume and crash-loops.
# RAILWAY_RUN_UID=0 makes the container run as root so the volume is writable.
# The official image's entrypoint handles the actual postgres process switching.

USER root

# Ensure the data directory exists and is owned by postgres
RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql/data

ENV PGDATA=/var/lib/postgresql/data
