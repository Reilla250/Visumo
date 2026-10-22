'use strict';
/**
 * Creates the VISUMO tables and loads the report content into an EMPTY database,
 * using the connection settings in .env (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD).
 *
 *   node scripts/init-db.js postgres
 *   node scripts/init-db.js mysql
 *   node scripts/init-db.js postgres --force     (drops and recreates the VISUMO tables, DELETES contact messages)
 *
 * You can also import database/<engine>/visumo_<engine>_full.sql with psql / mysql directly.
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');

const engine = (process.argv[2] || process.env.DB_CLIENT || '').toLowerCase();
const force = process.argv.includes('--force');

if (!['postgres', 'mysql'].includes(engine)) {
  console.error('Usage: node scripts/init-db.js <postgres|mysql> [--force]');
  process.exit(1);
}

const file = path.join(__dirname, '..', 'database', engine, `visumo_${engine}_full.sql`);
const sql = fs.readFileSync(file, 'utf8');

const cfg = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT) || (engine === 'mysql' ? 3306 : 5432),
  database: process.env.DB_NAME || 'visumo',
  user: process.env.DB_USER || 'visumo',
  password: process.env.DB_PASSWORD || '',
};

async function run() {
  if (engine === 'postgres') {
    const { Client } = require('pg');
    const client = new Client(cfg);
    await client.connect();
    try {
      const exists = await client.query("SELECT to_regclass('public.report_sections') AS t");
      if (exists.rows[0].t && !force) throw new Error('VISUMO tables already exist. Re-run with --force to drop and recreate them.');
      await client.query(sql);
    } finally {
      await client.end();
    }
  } else {
    const mysql = require('mysql2/promise');
    const conn = await mysql.createConnection({ ...cfg, charset: 'utf8mb4', multipleStatements: true });
    try {
      const [rows] = await conn.query(
        'SELECT COUNT(*) AS n FROM information_schema.tables WHERE table_schema = ? AND table_name = ?',
        [cfg.database, 'report_sections'],
      );
      if (rows[0].n > 0 && !force) throw new Error('VISUMO tables already exist. Re-run with --force to drop and recreate them.');
      await conn.query(sql);
    } finally {
      await conn.end();
    }
  }
  console.log(`Database "${cfg.database}" on ${cfg.host}:${cfg.port} initialised from ${path.relative(process.cwd(), file)}`);
}

run().catch((err) => {
  console.error('Initialisation failed:', err.message);
  process.exit(1);
});
