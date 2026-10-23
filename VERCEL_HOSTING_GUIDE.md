# VISUMO: TiDB Cloud + Vercel Hosting Guide

This guide takes the existing VISUMO project from the TiDB database setup through a working Vercel deployment. The website frontend and Express backend run together on Vercel. TiDB stores the website content and contact messages.

## Before you start

- The project is in the GitHub repository `Reilla250/Visumo`.
- You have a TiDB Cloud Starter instance in AWS Tokyo and a Vercel account.
- Node.js 20 or newer is installed on your computer.
- **Rotate the TiDB password that was pasted into chat.** Use only the replacement password in your private local `.env` and in Vercel. Never commit it or paste it into chat.

## 1. Prepare the TiDB database

1. Open your TiDB instance and choose **SQL Editor**.
2. If the editor is connected to `sys`, run this there to create the app's database:

   ```sql
   CREATE DATABASE IF NOT EXISTS visumo;
   ```

3. In the TiDB **Connect** panel, select the `visumo` database and copy the host and exact username for later. TiDB Starter uses TLS and port `4000`.
4. Open **Settings → Networking**. Keep your computer's IP allowed so the local import can connect. Add **AWS Access** so Vercel can connect too; a rule allowing only your computer blocks Vercel Functions.

## 2. Add private local settings

From a terminal in the VISUMO project folder, install dependencies and create your private environment file:

```bash
npm ci
cp .env.example .env
```

Open `.env` in a text editor and set these values. Replace each placeholder with a value from TiDB or one you create. Do not include the angle brackets.

```dotenv
DB_CLIENT=mysql
DB_HOST=<host from TiDB Connect>
DB_PORT=4000
DB_NAME=visumo
DB_USER=<username from TiDB Connect>
DB_PASSWORD=<new rotated TiDB password>
DB_SSL=true
DB_POOL_SIZE=2
ADMIN_USER=admin
ADMIN_PASSWORD=<your own long unique admin password>
SESSION_SECRET=<random 64-character hex value>
```

Generate a session secret in the terminal:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Put the command's output in `.env` as `SESSION_SECRET`. Keep `.env` private; Git ignores it.

## 3. Import the website data into TiDB

Run this from the project folder:

```bash
npm run db:seed:mysql
```

Success looks like a message saying database `visumo` was initialized on the TiDB host at port `4000`. This loads the tables and report content. Run it once against the new, empty `visumo` database.

If you see `ECONNREFUSED 127.0.0.1:3306`, the `.env` file is missing or its TiDB settings did not load. Confirm `DB_HOST` is the TiDB host, `DB_PORT=4000`, and `DB_SSL=true`.

## 4. Import the repository into Vercel

1. Go to [Vercel New Project](https://vercel.com/new), connect GitHub, and import **Reilla250/Visumo**.
2. Keep the project root as the repository root. Let Vercel detect the Express app; do not set a separate frontend framework or add a build command.
3. In the project setup or **Project → Settings → Environment Variables**, add the variables in the next section for **Production**. Vercel does not automatically use your computer's `.env` when it deploys from Git. You may use Vercel's paste/bulk entry option if it is available, or add each variable by name. See [Vercel environment variable instructions](https://vercel.com/docs/environment-variables/managing-environment-variables).

## 5. Set Vercel environment variables

Add each variable below to Vercel. Use the **same** TiDB host, username, password, admin password, and session secret you placed in your local `.env`. Enter the actual values without quote marks.

| Name | Value |
| --- | --- |
| `DB_CLIENT` | `mysql` |
| `DB_HOST` | Host from TiDB Connect |
| `DB_PORT` | `4000` |
| `DB_NAME` | `visumo` |
| `DB_USER` | Username from TiDB Connect |
| `DB_PASSWORD` | The new rotated TiDB password |
| `DB_SSL` | `true` |
| `DB_POOL_SIZE` | `2` |
| `ADMIN_USER` | `admin` (or your chosen username) |
| `ADMIN_PASSWORD` | Your unique admin password |
| `SESSION_SECRET` | The random secret stored in your local `.env` |
| `FORCE_HTTPS` | `true` |

Apply them to **Production**. Also select **Preview** if you want preview deployments to use this same database. Do not put these values in GitHub or a committed `.env` file.

## 6. Deploy and set the site URL

1. Click **Deploy** and wait for the deployment to finish. Vercel will provide an address such as `https://your-project.vercel.app`.
2. Add a `SITE_URL` environment variable with that complete address and no trailing slash.
3. In **Project → Settings → Functions**, choose the closest available function region to Tokyo.
4. Redeploy after adding or changing environment variables; changes apply to new deployments. See [Vercel's environment variable guide](https://vercel.com/docs/environment-variables).

## 7. Check the deployed site

Replace `your-project.vercel.app` with your actual Vercel address and open:

- `https://your-project.vercel.app/healthz` — should return `{"status":"ok","database":"mysql"}`.
- `https://your-project.vercel.app/` — should show the home page and report content.
- `https://your-project.vercel.app/finance` — should show the financial charts.
- `https://your-project.vercel.app/admin/login` — sign in using `ADMIN_USER` and `ADMIN_PASSWORD`.
- Submit a test message at `/contact`, then confirm it appears in `/admin`.

If `/healthz` fails, verify the database host, port `4000`, database `visumo`, username, rotated password, TLS setting, and TiDB **Settings → Networking**. Then check the Vercel deployment's function logs.

## Free plan note

TiDB Starter has monthly usage quotas. Vercel Hobby is for personal, non-commercial use; check that VISUMO's use qualifies under [Vercel's Hobby fair-use terms](https://vercel.com/docs/limits/fair-use-guidelines#commercial-usage). Admin gallery uploads are stored in TiDB, so they remain available across Vercel deployments. Vercel uploads are limited to 4 MB per image to stay within the request-size limit.
