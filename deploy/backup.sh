#!/usr/bin/env bash
# Back up the VISUMO database (includes contact-form messages) from a Docker Compose install.
#
#   ./deploy/backup.sh postgres      # or: ./deploy/backup.sh mysql
#
# Writes a compressed dump to ./backups/. Run it daily from cron, e.g.
#   0 2 * * *  cd /opt/visumo-website && ./deploy/backup.sh postgres
# and copy the files off the server regularly.
set -euo pipefail

engine="${1:-}"
if [[ "$engine" != "postgres" && "$engine" != "mysql" ]]; then
  echo "Usage: $0 <postgres|mysql>" >&2
  exit 1
fi

cd "$(dirname "$0")/.."
set -a; [[ -f .env ]] && . ./.env; set +a
compose=(docker compose -f "docker-compose.${engine}.yml")
stamp="$(date +%Y%m%d-%H%M%S)"
mkdir -p backups
out="backups/visumo-${engine}-${stamp}.sql.gz"

if [[ "$engine" == "postgres" ]]; then
  "${compose[@]}" exec -T db pg_dump -U "${DB_USER:-visumo}" --clean --if-exists "${DB_NAME:-visumo}" | gzip > "$out"
else
  "${compose[@]}" exec -T db sh -c 'mysqldump --no-tablespaces --single-transaction -u root -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' | gzip > "$out"
fi

# keep the 30 most recent backups
ls -1t backups/visumo-"${engine}"-*.sql.gz 2>/dev/null | tail -n +31 | xargs -r rm --
echo "Backup written: $out"
