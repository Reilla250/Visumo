# Deployment guide

Two supported ways to run the site on a server. Both work with PostgreSQL **or** MySQL.
Examples assume Ubuntu 22.04/24.04 and a domain `example.org` pointing at the server's IP.

---

## Option A - Docker Compose (recommended)

### 1. Install Docker
```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER      # log out and in again
```

### 2. Upload and configure
```bash
unzip visumo-website.zip -d /opt && cd /opt/visumo-website
cp .env.example .env
nano .env
```
Set at least:
```
DB_PASSWORD=<long random password>
DB_ROOT_PASSWORD=<another one>          # MySQL only
ADMIN_PASSWORD=<long random password>   # enables /admin
SITE_URL=https://example.org
TRUST_PROXY=1
WEB_BIND=127.0.0.1                       # only nginx can reach the app
```
Generate passwords with `openssl rand -base64 24`.

### 3. Start (choose one)
```bash
docker compose -f docker-compose.postgres.yml up -d --build
# or
docker compose -f docker-compose.mysql.yml up -d --build
```
The database is created and loaded with the report content on first start. Check:
```bash
docker compose -f docker-compose.postgres.yml ps
curl http://127.0.0.1:3000/healthz        # {"status":"ok",...}
```

> Use **one** engine per server. Switching later means re-running with the other compose file (a new database,
> loaded fresh from the SQL file; contact messages do not carry over).

### 4. nginx + HTTPS
```bash
sudo apt install -y nginx certbot python3-certbot-nginx
sudo cp deploy/nginx.conf /etc/nginx/sites-available/visumo      # replace example.org inside first
sudo ln -s /etc/nginx/sites-available/visumo /etc/nginx/sites-enabled/visumo
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d example.org -d www.example.org
```
Then set `FORCE_HTTPS=true` in `.env` and restart: `docker compose -f docker-compose.<engine>.yml up -d`.
Open ports 80 and 443 in your firewall (`sudo ufw allow 'Nginx Full'`); do **not** open 3000 or the database ports.

### 5. Updates, logs, backups
```bash
docker compose -f docker-compose.postgres.yml logs -f web
docker compose -f docker-compose.postgres.yml up -d --build      # after changing code
./deploy/backup.sh postgres                                      # or mysql; schedule in cron
```
The database lives in a Docker volume (`pgdata` / `mysqldata`) and survives restarts and rebuilds.
`docker compose ... down -v` **deletes it**.

---

## Option B - without Docker (systemd)

### 1. Install Node.js 20+ and the database
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs nginx
sudo apt install -y postgresql          # OR: sudo apt install -y mysql-server   (or mariadb-server)
```

### 2. Create the database and user

PostgreSQL:
```bash
sudo -u postgres psql <<'SQL'
CREATE ROLE visumo LOGIN PASSWORD 'change-me';
CREATE DATABASE visumo OWNER visumo ENCODING 'UTF8';
SQL
```
MySQL / MariaDB:
```bash
sudo mysql <<'SQL'
CREATE DATABASE visumo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'visumo'@'localhost' IDENTIFIED BY 'change-me';
GRANT ALL ON visumo.* TO 'visumo'@'localhost';
SQL
```

### 3. Install the site and load the content
```bash
sudo mkdir -p /opt && sudo unzip visumo-website.zip -d /opt
cd /opt/visumo-website
sudo npm ci --omit=dev
sudo cp .env.example .env && sudo nano .env      # DB_CLIENT=postgres|mysql, DB_PASSWORD, ADMIN_PASSWORD, SITE_URL, TRUST_PROXY=1
sudo node scripts/init-db.js postgres            # or mysql
sudo chown -R www-data:www-data /opt/visumo-website
```
(`init-db.js` refuses to run on a database that already has VISUMO tables unless you add `--force`.)

### 4. Run as a service, then nginx + HTTPS
```bash
sudo cp deploy/visumo.service /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now visumo
curl http://127.0.0.1:3000/healthz
```
Then follow step 4 of Option A for nginx and certbot.

Backups without Docker:
```bash
pg_dump -U visumo -h 127.0.0.1 visumo | gzip > visumo-$(date +%F).sql.gz        # PostgreSQL
mysqldump -u visumo -p --single-transaction visumo | gzip > visumo-$(date +%F).sql.gz   # MySQL
```

---

## Managed database (optional)
Any hosted PostgreSQL or MySQL works: create an empty database and user, import
`database/<engine>/visumo_<engine>_full.sql` once, and set `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`,
`DB_PASSWORD` (and `DB_SSL=true` if the provider requires TLS) in `.env`.

## Troubleshooting

| Symptom | Likely cause / fix |
| --- | --- |
| Page shows "Service temporarily unavailable" | App cannot reach the database. Check `DB_*` values and `docker compose logs web` / `journalctl -u visumo`. |
| `/healthz` returns 503 | Same as above - database down or wrong password. |
| Site loads but has no styling | Browser is upgrading to HTTPS while the site is on HTTP. Keep `FORCE_HTTPS=false` until HTTPS works. |
| Contact form says "Too many messages" | Rate limit: 5 submissions per 15 minutes per visitor. With nginx make sure `TRUST_PROXY=1` so visitors are not all seen as one address. |
| `/admin` shows "Page not found" | `ADMIN_PASSWORD` is empty - set it and restart. |
| Accented characters look broken | Database must be UTF-8 (`utf8mb4` for MySQL). The provided SQL and compose files already set this. |
| MySQL container "unhealthy" on first start | First initialisation can take up to a minute; wait and re-check `docker compose ps`. |
| Changed SQL files but nothing happened | Docker only imports SQL when the volume is **new**. Use `down -v` (deletes data) or import manually with `psql` / `mysql`. |

## Security notes
- Keep `.env` private; it holds passwords. Do not expose the database port to the internet.
- `/admin` uses HTTP Basic authentication - only use it over HTTPS.
- The inbox contains personal data from visitors. Limit who has the admin password and delete messages you no longer need.
- Keep the system, Docker images and `npm` packages updated (`npm audit`, `docker compose pull`).
