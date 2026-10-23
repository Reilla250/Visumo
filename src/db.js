'use strict';
/**
 * Tiny database adapter so the same application code runs on PostgreSQL, MySQL/MariaDB, or SQLite.
 * Select the engine with DB_CLIENT=postgres | mysql | sqlite  (see .env.example).
 * Queries are written with "?" placeholders; they are converted to $1, $2 ... for PostgreSQL.
 */
const client = String(process.env.DB_CLIENT || 'sqlite').toLowerCase();

const cfg = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT) || (client === 'mysql' ? 3306 : 5432),
  database: process.env.DB_NAME || 'visumo',
  user: process.env.DB_USER || 'visumo',
  password: process.env.DB_PASSWORD || '',
};

let pool;
let query;

if (client === 'postgres' || client === 'postgresql' || client === 'pg') {
  const { Pool } = require('pg');
  pool = new Pool({
    ...cfg,
    max: Number(process.env.DB_POOL_SIZE) || 10,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
  });
  // keep the process alive on idle-client errors (e.g. database restart)
  pool.on('error', (err) => console.error('[db] idle client error:', err.message));
  query = async (sql, params = []) => {
    let i = 0;
    const text = sql.replace(/\?/g, () => `$${++i}`);
    const res = await pool.query(text, params);
    return res.rows;
  };
} else if (client === 'mysql' || client === 'mariadb') {
  const mysql = require('mysql2/promise');
  pool = mysql.createPool({
    host: cfg.host,
    port: cfg.port,
    user: cfg.user,
    password: cfg.password,
    database: cfg.database,
    charset: 'utf8mb4',
    waitForConnections: true,
    // A small pool suits Vercel's short-lived function instances and keeps
    // well below TiDB Cloud Starter's connection cap.
    connectionLimit: Number(process.env.DB_POOL_SIZE) || (process.env.VERCEL === '1' ? 2 : 10),
    maxIdle: Number(process.env.DB_POOL_SIZE) || (process.env.VERCEL === '1' ? 2 : 10),
    idleTimeout: 60_000,
    connectTimeout: 10_000,
    ssl: process.env.DB_SSL === 'true' ? { minVersion: 'TLSv1.2' } : undefined,
  });
  query = async (sql, params = []) => {
    const [rows] = await pool.query(sql, params);
    return rows;
  };
} else if (client === 'sqlite') {
  const path = require('path');
  const fs   = require('fs');
  const Database = require('better-sqlite3');

  const dbPath = process.env.DB_SQLITE_PATH || path.join(__dirname, '..', 'visumo.sqlite');
  const needsInit = !fs.existsSync(dbPath);

  const sqliteDb = new Database(dbPath);
  sqliteDb.pragma('journal_mode = WAL');
  sqliteDb.pragma('foreign_keys = ON');

  // Auto-create schema on first run
  if (needsInit) {
    console.log('[db] SQLite: creating schema and seeding data…');
    const schemaPath = path.join(__dirname, '..', 'database', 'sqlite', 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    sqliteDb.exec(schema);

    // Load seed data
    const seedPath = path.join(__dirname, '..', 'database', 'sqlite', 'seed.sql');
    if (fs.existsSync(seedPath)) {
      const seed = fs.readFileSync(seedPath, 'utf8');
      try { sqliteDb.exec(seed); } catch (e) { console.warn('[db] seed warning:', e.message); }
    }
    console.log('[db] SQLite: database ready.');
  }

  // Ensure contact_messages always exists (even on subsequent runs)
  sqliteDb.exec(`
    CREATE TABLE IF NOT EXISTS contact_messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      email TEXT NOT NULL,
      organisation TEXT,
      subject TEXT NOT NULL,
      message TEXT NOT NULL,
      is_read INTEGER NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Ensure gallery_images table exists
  sqliteDb.exec(`
    CREATE TABLE IF NOT EXISTS gallery_images (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      filename TEXT NOT NULL UNIQUE,
      caption TEXT NOT NULL DEFAULT '',
      alt_text TEXT NOT NULL DEFAULT '',
      image_data BLOB,
      sort_order INTEGER NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Ensure admin_users table exists
  sqliteDb.exec(`
    CREATE TABLE IF NOT EXISTS admin_users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'admin',
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Seed default admin user into SQLite database
  const crypto = require('crypto');
  const defaultUser = process.env.ADMIN_USER || 'admin';
  const defaultPass = process.env.ADMIN_PASSWORD || 'visumo2025admin';
  const defaultHash = crypto.createHash('sha256').update(defaultPass).digest('hex');
  const existingAdmin = sqliteDb.prepare('SELECT id FROM admin_users WHERE username = ?').get(defaultUser);
  if (!existingAdmin) {
    sqliteDb.prepare('INSERT INTO admin_users (username, password_hash, role) VALUES (?, ?, ?)').run(defaultUser, defaultHash, 'admin');
  } else {
    sqliteDb.prepare('UPDATE admin_users SET password_hash = ? WHERE username = ?').run(defaultHash, defaultUser);
  }

  // Synchronous SQLite wrapped as async to match the rest of the adapter
  query = async (sql, params = []) => {
    const stmt = sqliteDb.prepare(sql);
    if (/^\s*(SELECT|PRAGMA)/i.test(sql)) {
      return stmt.all(...params);
    }
    const info = stmt.run(...params);
    // Return an object mimicking pg/mysql for INSERT/UPDATE
    return info;
  };

  // Expose the raw db for graceful shutdown
  pool = { end: async () => { try { sqliteDb.close(); } catch (_) {} } };

} else {
  throw new Error(`Unsupported DB_CLIENT "${client}". Use "postgres", "mysql", or "sqlite".`);
}

const rawQuery = query;
let galleryImageStorageReady;
async function ensureGalleryImageStorage() {
  if (!galleryImageStorageReady) {
    galleryImageStorageReady = (async () => {
      let columns;
      if (client === 'sqlite') {
        columns = await rawQuery('PRAGMA table_info(gallery_images)');
        if (!columns.some((column) => column.name === 'image_data')) {
          await rawQuery('ALTER TABLE gallery_images ADD COLUMN image_data BLOB');
        }
      } else if (client === 'mysql' || client === 'mariadb') {
        columns = await rawQuery(
          "SELECT COLUMN_NAME AS column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gallery_images' AND COLUMN_NAME = 'image_data'",
        );
        if (!columns.length) {
          await rawQuery('ALTER TABLE gallery_images ADD COLUMN image_data LONGBLOB NULL');
        }
      } else {
        columns = await rawQuery(
          "SELECT column_name FROM information_schema.columns WHERE table_schema = current_schema() AND table_name = 'gallery_images' AND column_name = 'image_data'",
        );
        if (!columns.length) {
          await rawQuery('ALTER TABLE gallery_images ADD COLUMN image_data BYTEA');
        }
      }
    })();
  }
  return galleryImageStorageReady;
}

query = async (sql, params = []) => {
  await ensureGalleryImageStorage();
  return rawQuery(sql, params);
};

async function ping() {
  await query('SELECT 1 AS ok');
  return true;
}

module.exports = { client, query, ping, pool, cfg };
