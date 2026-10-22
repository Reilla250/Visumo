# VISUMO website

Website for **Violence Survivors Mothers (VISUMO)**, North Kivu, DRC, built from the *Annual Narrative Report 2025*.
All page content (text, tables, testimonies, income figures) is stored in a database and rendered by a small Node.js app.
You can run it on **PostgreSQL** or **MySQL/MariaDB** - the same site, the same content.

## What is inside

```
visumo-website/
  server.js, src/, views/, public/   the website (Node.js + Express + EJS, no front-end build step)
  database/
    postgres/  schema.sql  seed.sql  visumo_postgres_full.sql   <- schema + data in one file
    mysql/     schema.sql  seed.sql  visumo_mysql_full.sql      <- schema + data in one file
    tools/generate_seed.py                                      <- regenerates seed/full files from the report text
  Dockerfile, docker-compose.postgres.yml, docker-compose.mysql.yml
  deploy/    nginx.conf, visumo.service (systemd), backup.sh
  scripts/init-db.js                                            <- loads the database without psql/mysql tools
  .env.example
  DEPLOYMENT.md                                                 <- step-by-step server guide
```

Pages: Home, About, Programmes, Partners, Voices (Kiswahili and French testimonies), Finance (2021-2025 income with
charts), Accountability, 2026 plan, Report (contents, annex, document control, report and French statutes downloads,
official letterhead), Contact (saves to the database), plus a password-protected `/admin` inbox, `/api/income`,
`/api/sections` and `/healthz`.

## Quick start (Docker - easiest)

Needs Docker with Compose. Pick one database:

```bash
cp .env.example .env            # edit DB_PASSWORD, DB_ROOT_PASSWORD (MySQL), ADMIN_PASSWORD

# PostgreSQL
docker compose -f docker-compose.postgres.yml up -d --build
# ...or MySQL
docker compose -f docker-compose.mysql.yml up -d --build
```

Open <http://localhost:3000>. The database is created and filled with the report content automatically on first start.

## Quick start (without Docker)

Needs Node.js 18+ and a running PostgreSQL 13+ or MySQL 8 / MariaDB 10.5+.

```bash
npm install --omit=dev
cp .env.example .env            # set DB_CLIENT (postgres|mysql) and the DB_* values

# create an empty database and user first (see DEPLOYMENT.md), then load the content:
node scripts/init-db.js postgres        # or: node scripts/init-db.js mysql
# (alternatively: psql -d visumo -f database/postgres/visumo_postgres_full.sql
#                 mysql visumo < database/mysql/visumo_mysql_full.sql)

npm start                               # http://localhost:3000
```

## Editing the website text

Everything visible comes from the database, so edit it there (the site caches content for 60 seconds, or press
*Refresh site content cache* on `/admin`). Examples:

```sql
UPDATE callouts SET body = 'New wording' WHERE slug = 'message-to-partners';
UPDATE site_settings SET setting_value = 'New headline' WHERE setting_key = 'hero_headline';
UPDATE annual_income SET amount_usd = 360000.12 WHERE report_year = 2026;   -- or INSERT a new year
```

To add 2026 income, insert a row in `annual_income` (and in `income_source_amounts` if you break it down by source);
the Finance page and charts update automatically. Bigger content changes: edit `database/tools/generate_seed.py`,
run `python3 database/tools/generate_seed.py`, and re-import (this resets the database - back up messages first).

## Before going public - checklist

- Set strong values for `DB_PASSWORD`, `DB_ROOT_PASSWORD` and `ADMIN_PASSWORD`; never commit `.env`.
- Put the site behind HTTPS (see `DEPLOYMENT.md`), then set `FORCE_HTTPS=true` and `SITE_URL=https://your-domain`.
- Add the official VISUMO logo by replacing `public/img/logo.svg` and `public/img/favicon.svg` (the current ones are a
  simple placeholder monogram, not the registered logo).
- `CONTACT_EMAIL` is prefilled with the official address shown on the supplied letterhead (`visumoadm@gmail.com`). Replace it in `.env` if VISUMO uses another inbox. The contact form saves submissions in the database inbox; it does not send email notifications.
- Photos come from the report. Keep VISUMO's consent and survivor-safety rules in mind before adding or changing images or quotes.
- The contact form warns visitors not to send survivor-identifying information. Treat the inbox as sensitive data and
  keep `/admin` access limited.

## Source notes

- Income: 2024 and 2025 are audited (UBT); 2021-2023 are internal comparative figures. Source totals for 2024 and 2025
  add up exactly to the audited annual totals.
- The report's dashboard graphic labels the "10" tile as *local commitments*, while the annex says *10 trainers*. The
  site follows the written annex (10 trainers). Change it in `project_design_figures` if the graphic is correct.
"# Visumo" 
