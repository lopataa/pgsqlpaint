#!/bin/bash
set -e

# Run all setup scripts in lexicographical order
for f in /docker-entrypoint-initdb.d/setup/*.sql; do
    [ -e "$f" ] || continue
    echo "Running setup script $f"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
done

# Recursively run all .sql scripts in procedure/
find /docker-entrypoint-initdb.d/procedures -type f -name "*.sql" | sort | while read -r f; do
    echo "Running procedure script $f"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$f"
done
