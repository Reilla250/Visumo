# VISUMO website

Website for **Violence Survivors Mothers (VISUMO)**, North Kivu, DRC.
Page content (text, tables and testimonies) is stored in a database and rendered by a small Node.js app.
You can run it on **PostgreSQL** or **MySQL/MariaDB** - the same site, the same content.

## What is inside

```
visumo-website/
  server.js, src/, views/, public/   the website (Node.js + Express + EJS, no front-end build step)
  database/
    postgres/  schema.sql  seed.sql  visumo_postgres_full.sql   <- schema + data in one file
    mysql/     schema.sql  seed.sql  visumo_mysql_full.sql      <- schema + data in one file
    tools/generate_seed.py                                      <- regenerates seed/full files from website content
  Dockerfile, docker-compose.postgres.yml, docker-compose.mysql.yml
  deploy/    nginx.conf, visumo.service (systemd), backup.sh
  scripts/init-db.js                                            <- loads the database without psql/mysql tools
  .env.example
  DEPLOYMENT.md                                                 <- step-by-step server guide
```

Pages: Home, About, Programmes, Partners, Voices (Kiswahili and French testimonies), Accountability, 2026 plan,
Gallery and Contact (saves to the database), plus a password-protected `/admin` inbox and `/healthz`.

## Deploy the full website free: TiDB Cloud + Vercel

For a separate, printable walkthrough, see [VERCEL_HOSTING_GUIDE.md](VERCEL_HOSTING_GUIDE.md).

The **frontend and backend deploy together to Vercel**. Vercel serves the pages, CSS, JavaScript, images, contact form, admin pages, and API routes. TiDB Cloud stores the page content and contact messages in a MySQL-compatible database. You do not need to deploy a second backend server.

This setup uses TiDB Cloud Starter's monthly free quota and Vercel Hobby's free tier. TiDB currently includes 5 GiB of row storage and 50 million request units per month for each of the first five MySQL-compatible Starter instances in an organization. If the database reaches its free quota, new connections are refused until the next monthly reset. [TiDB free quota details](https://docs.pingcap.com/tidbcloud/serverless-limitations/)

Vercel Hobby is restricted to personal or non-commercial use. Vercel defines commercial use by financial gain, including when a paid employee or consultant worked on the project. Confirm that VISUMO's use qualifies before choosing Hobby; otherwise Vercel requires a paid plan. [Vercel Hobby rules](https://vercel.com/docs/limits/fair-use-guidelines#commercial-usage)

### What you need

- A TiDB Cloud account and a Vercel account.
- Node.js 20 or newer on your computer.
- This project pushed to a GitHub repository in your personal GitHub account. Vercel can deploy an existing Express app directly from a Git repository. [Vercel Express deployment guide](https://vercel.com/kb/guide/ship-a-express-app-on-vercel)

### Step 1: Create your TiDB database

If you already created the VISUMO instance in TiDB Cloud, keep using it and skip the instance-creation steps below. Your current instance is AWS Tokyo; when setting up Vercel, choose the closest available function region to Tokyo.

1. Sign in to [TiDB Cloud](https://tidbcloud.com/).
2. Choose **Create Resource**, select **Starter**, and select **MySQL Compatible**.
3. Choose a cloud region. When Vercel is set up, choose its function region close to this database region to reduce delay.
4. Set the monthly spending limit to **0** so the instance stays on the free quota, then create it.
5. Open your new instance and choose **Connect**. Use the public connection. Generate and save the password. Copy the host and the exact username shown in the connection details. TiDB Starter requires TLS; this app uses it when `DB_SSL=true`. [TiDB create and connect guide](https://docs.pingcap.com/tidbcloud/create-tidb-cluster-serverless/)

The connection dialog may initially select the `sys` database. Do not use `sys` for the website. In TiDB's **SQL Editor**, select the `sys` database and run:

```sql
CREATE DATABASE IF NOT EXISTS visumo;
```

Then choose `visumo` in the **Connect** dialog's **Database** selector. TiDB recommends creating an application database rather than using its default `test` database. [Create a TiDB database](https://docs.pingcap.com/developer/dev-guide-create-database/)

If a TiDB password has been pasted into chat, shared in a screenshot, or committed to Git, reset it in the **Connect** panel and use only the replacement password in `.env` and Vercel. Never paste it into chat.

Check the instance's **Settings → Networking** page. If it only allows your current computer IP, add **AWS Access** for this AWS hosted cluster, or leave `Allow_all_public_connections` enabled. Vercel Functions use dynamic outbound IPs, so allowing only your computer will block Vercel. TiDB documents the AWS access rule for Starter instances, and Vercel documents its dynamic outbound addresses. [TiDB firewall rules](https://docs.pingcap.com/tidbcloud/configure-serverless-firewall-rules-for-public-endpoints/), [Vercel outbound IPs](https://vercel.com/kb/guide/can-i-get-a-fixed-ip-address)

### Step 2: Import the website content into TiDB

Open a terminal in the project folder and install the locked dependencies:

```bash
npm ci
```

Create a private local environment file:

```bash
cp .env.example .env
```

Open `.env` in a text editor and set these values. Replace the angle bracket examples with values from TiDB's **Connect** panel. Do not include the angle brackets themselves.

```dotenv
DB_CLIENT=mysql
DB_HOST=<TiDB host>
DB_PORT=4000
DB_NAME=visumo
DB_USER=<TiDB username>
DB_PASSWORD="<TiDB password>"
DB_SSL=true
DB_POOL_SIZE=2
ADMIN_USER=admin
ADMIN_PASSWORD="<a long unique password>"
SESSION_SECRET=<a random secret>
```

Generate a random session secret by running this command in the terminal, then paste its output as `SESSION_SECRET` in `.env`:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Load the tables and website content into TiDB:

```bash
node scripts/init-db.js mysql
```

The script should finish with a message like `Database "visumo" ... initialised`. It refuses to overwrite an existing VISUMO database. Run it once for the new database, not each time you deploy.

### Step 3: Push the project to GitHub

If the project is already connected to your personal GitHub repository, commit and push the current changes:

```bash
git add .
git commit -m "Prepare VISUMO for TiDB and Vercel"
git push
```

If it is not on GitHub yet, create a repository under your personal GitHub account, connect this local project to it, then push. Keep `.env` out of Git; it is ignored by `.gitignore`. Never put database passwords in source files or commit messages.

### Step 4: Deploy the frontend and backend on Vercel

1. Sign in at [Vercel](https://vercel.com/) and choose **Add New → Project**.
2. Import the GitHub repository containing this project.
3. Leave the project root as the repository root. Vercel detects the Express app; do not choose a separate frontend framework or add a build command. The root `index.js` exports the app, and `vercel.json` includes the EJS templates and public files in the deployment. Vercel runs the Express site as a Function and serves the static files with it.
4. Use [`vercel.env.example`](vercel.env.example) as the Vercel variable template. It contains the connection values from your TiDB instance and placeholders for secrets. Replace `DB_PASSWORD` with the new password after rotating it, set a unique `ADMIN_PASSWORD`, and replace `SESSION_SECRET` with the output of the random-secret command in Step 2. Do not commit a filled-in copy of this file.

   Add the variables under **Project → Settings → Environment Variables** for **Production**; also apply them to **Preview** if you want preview deployments to connect to the same database. Vercel's documented project setup is to add variables in this page; its `.env` import option is available for team-level Shared Environment Variables. If you use that option, link the shared variables to this project. Enter passwords as their exact values, without quote marks. [Vercel environment variable guide](https://vercel.com/docs/environment-variables/managing-environment-variables) · [Shared variable import guide](https://vercel.com/docs/environment-variables/shared-environment-variables)

   | Name | Value |
   | --- | --- |
   | `DB_CLIENT` | `mysql` |
   | `DB_HOST` | TiDB host from Connect |
   | `DB_PORT` | `4000` |
   | `DB_NAME` | `visumo` |
   | `DB_USER` | Exact TiDB username from Connect |
   | `DB_PASSWORD` | TiDB password |
   | `DB_SSL` | `true` |
   | `DB_POOL_SIZE` | `2` |
   | `ADMIN_USER` | `admin` or your chosen admin username |
   | `ADMIN_PASSWORD` | The strong password you made in Step 2 |
   | `SESSION_SECRET` | The random secret you made in Step 2 |
   | `FORCE_HTTPS` | `true` |
   | `SITE_URL` | Add after the first deploy |

5. Click **Deploy**. Wait for the deployment to finish. Vercel gives you an address like `https://your-project.vercel.app`.
6. Add `SITE_URL` using that address, without a trailing slash, then redeploy so the sitemap and page previews use the right URL.
7. In Vercel **Settings → Functions**, set the function region close to your TiDB region, then redeploy if you change it. Vercel's function region affects database request delay; static assets are served globally.

Environment variable changes only affect new deployments, so redeploy after changing them. [Vercel environment variable guide](https://vercel.com/docs/environment-variables)

### Step 5: Check that everything works

Open these pages on the Vercel URL:

- `/healthz` should return `{"status":"ok","database":"mysql"}`.
- `/` should show the home page content, rather than blank or sample data.
- `/admin/login` should let you sign in with `ADMIN_USER` and `ADMIN_PASSWORD`.
- Submit a test message at `/contact`, then confirm it appears in `/admin`.

If `npm run db:seed:mysql` reports `ECONNREFUSED 127.0.0.1:3306`, the local `.env` file is missing or `DB_HOST`/`DB_PORT` were not loaded. Create `.env` from `.env.example`, then set `DB_HOST` to the TiDB host from **Connect**, `DB_PORT=4000`, `DB_NAME=visumo`, `DB_USER` and `DB_PASSWORD` from **Connect**, and `DB_SSL=true`. Run the seed command from the project root. Do not paste the password into chat.

If `/healthz` returns an error, check that the TiDB hostname, exact username, password, database name, port `4000`, and `DB_SSL=true` match the Connect panel. If the deployment build fails, open **Vercel → Deployments → failed deployment → Build Logs** and check that the project root is the repository root and Node.js is version 20 or newer.

### Updating the site after deployment

Push code changes to the connected GitHub branch and Vercel deploys them. Text and page content are stored in TiDB and can be edited through SQL; the site caches content for 60 seconds. Contact messages are stored in TiDB and remain after redeployment. Gallery images already in `public/img/gallery` are deployed with the site. New gallery photos must be added to that folder in Git and pushed; Vercel's function filesystem is temporary, so the admin upload form is replaced with instructions on Vercel.

For a separate Linux or Docker deployment, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Quick start (Docker - easiest)

Needs Docker with Compose. Pick one database:

```bash
cp .env.example .env            # edit DB_PASSWORD, DB_ROOT_PASSWORD (MySQL), ADMIN_PASSWORD

# PostgreSQL
docker compose -f docker-compose.postgres.yml up -d --build
# ...or MySQL
docker compose -f docker-compose.mysql.yml up -d --build
```

Open <http://localhost:3000>. The database is created and filled with website content automatically on first start.

## Quick start (without Docker)

Needs Node.js 20+ and a running PostgreSQL 13+ or MySQL 8 / MariaDB 10.5+.

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

Most page content comes from the database, so edit it there (the site caches content for 60 seconds, or press
*Refresh site content cache* on `/admin`). Examples:

```sql
UPDATE callouts SET body = 'New wording' WHERE slug = 'message-to-partners';
UPDATE site_settings SET setting_value = 'New headline' WHERE setting_key = 'hero_headline';
```

The `annual_income` and `income_source_amounts` records remain in the database for internal use; no public page or API
serves them. For other content changes, edit `database/tools/generate_seed.py`, run
`python3 database/tools/generate_seed.py`, and re-import (this resets the database - back up messages first).

## Before going public - checklist

- Set strong values for `DB_PASSWORD`, `DB_ROOT_PASSWORD` and `ADMIN_PASSWORD`; never commit `.env`.
- Put the site behind HTTPS (see `DEPLOYMENT.md`), then set `FORCE_HTTPS=true` and `SITE_URL=https://your-domain`.
- Add the official VISUMO logo by replacing `public/img/logo.svg` and `public/img/favicon.svg` (the current ones are a
  simple placeholder monogram, not the registered logo).
- `CONTACT_EMAIL` is prefilled with the official address shown on the supplied letterhead (`visumoadm@gmail.com`). Replace it in `.env` if VISUMO uses another inbox. The contact form saves submissions in the database inbox; it does not send email notifications.
- Keep VISUMO's consent and survivor-safety rules in mind before adding or changing images or quotes.
- The contact form warns visitors not to send survivor-identifying information. Treat the inbox as sensitive data and
  keep `/admin` access limited.

## Source notes

- The registration date displayed on About is 21 July 2018, as shown on the supplied certificate.
- Financial records are retained in the database for internal use and are not part of the public website.
"# Visumo" 
