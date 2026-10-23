# Deployment guide

This guide covers Docker, a Linux server, and the TiDB Cloud + Vercel setup.

---

## Option C - TiDB Cloud + Vercel

This runs the Express website as a Vercel Function and stores the site content and contact messages in TiDB Cloud Starter using its MySQL interface. TiDB Cloud Starter currently includes 5 GiB of row storage and 50 million request units per month for each of the first five MySQL-compatible instances in an organization. If the free quota is reached, TiDB refuses new connections until the monthly reset. Set the spending limit to **0** when creating the instance to keep it free.

### 1. Create the TiDB database

1. Sign in at [TiDB Cloud](https://tidbcloud.com/) and create a **Starter** instance with **MySQL Compatible** mode.
2. Choose a region near your Vercel function region and create the instance with a **0** monthly spending limit.
3. Open the instance's **Connect** panel, choose the public connection, and generate/save its password. Copy the host and the exact username shown there. TiDB Starter requires TLS; this project enables it with `DB_SSL=true`.

The default database in a new TiDB Starter instance is usually `test`. Use that unless you create another database first.

### 2. Load the website content into TiDB

On your computer, install the project dependencies and make a private local `.env` file:

```bash
npm ci
cp .env.example .env
```

Set these values in `.env` from TiDB's **Connect** panel. Use a unique strong password for the admin and a random session secret; never put real values in Git:

```dotenv
DB_CLIENT=mysql
DB_HOST=<TiDB host>
DB_PORT=4000
DB_NAME=test
DB_USER=<TiDB username>
DB_PASSWORD=<TiDB password>
DB_SSL=true
DB_POOL_SIZE=2
ADMIN_USER=admin
ADMIN_PASSWORD=<long unique admin password>
SESSION_SECRET=<long random secret>
```

Generate a session secret with `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`. Then create all tables and import the report content:

```bash
node scripts/init-db.js mysql
```

This script refuses to overwrite existing VISUMO tables. It is safe to run once on the new empty database.

### 3. Deploy the app to Vercel

Push this project to a Git repository in your personal GitHub account, then import it from [Vercel New Project](https://vercel.com/new). Vercel should detect the Express app at the project root; leave the build and output settings on their defaults. The included `index.js` exports the Express app, and `vercel.json` includes the EJS templates and public assets in the function bundle.

In the Vercel project's **Settings → Environment Variables**, add the same database and admin values from `.env` for **Production** (and Preview too if you want preview deployments to work). Also set:

```dotenv
DB_CLIENT=mysql
DB_PORT=4000
DB_NAME=test
DB_SSL=true
DB_POOL_SIZE=2
FORCE_HTTPS=true
```

Set `SITE_URL` to the Vercel deployment URL after the first deploy, then redeploy. Vercel's standard Express deployment runs the whole app as a Function. The contact form and admin inbox persist through TiDB. Image uploads to the gallery are disabled on Vercel because function files do not persist; add images under `public/img/gallery` in Git and redeploy.

When deployment finishes, open `https://<your-project>.vercel.app/healthz`. It should return `{"status":"ok","database":"mysql"}`. Then open `/admin/login`, sign in with `ADMIN_USER` and `ADMIN_PASSWORD`, and send a contact form message to confirm it appears in the inbox.

Vercel Hobby is free for personal and non-commercial use. Vercel defines commercial usage by financial gain, including cases where a paid employee or consultant wrote the code. Confirm the project qualifies before using Hobby for the VISUMO organization; if it does not, Vercel requires Pro, so the Vercel portion cannot stay free under its current terms. TiDB's free quota is also bounded and can temporarily stop database requests if exhausted.

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
