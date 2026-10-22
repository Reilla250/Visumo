/*'use strict';
require('dotenv').config();

const path = require('path');
const fs   = require('fs');
const crypto = require('crypto');
const express = require('express');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const multer = require('multer');

const db = require('./src/db');
const { getContent, clearCache } = require('./src/content');
const charts = require('./src/charts');
const { i18nMiddleware } = require('./src/i18n');

const app = express();
const PORT = Number(process.env.PORT) || 3000;
const HOST = process.env.HOST || '0.0.0.0';
const SITE_URL = (process.env.SITE_URL || '').replace(/\/$/, '');

if (process.env.TRUST_PROXY) app.set('trust proxy', Number(process.env.TRUST_PROXY) || process.env.TRUST_PROXY);
app.disable('x-powered-by');
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(helmet({
  contentSecurityPolicy: {
    useDefaults: true,
    directives: {
      'default-src': ["'self'"],
      'img-src': ["'self'", 'data:'],
      'style-src': ["'self'", 'https://fonts.googleapis.com', "'unsafe-inline'"],
      'font-src': ["'self'", 'https://fonts.gstatic.com'],
      'script-src': ["'self'", "'unsafe-inline'"],
      'form-action': ["'self'"],
      'frame-ancestors': ["'none'"],
      'upgrade-insecure-requests': process.env.FORCE_HTTPS === 'true' ? [] : null,
    },
  },
  hsts: process.env.FORCE_HTTPS === 'true',
}));
app.use(compression());
app.use(express.urlencoded({ extended: false, limit: '20kb' }));

// -- Multer for gallery uploads --------------------------------------------------------
const GALLERY_DIR = path.join(__dirname, 'public', 'img', 'gallery');
if (!fs.existsSync(GALLERY_DIR)) fs.mkdirSync(GALLERY_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, GALLERY_DIR),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const name = `gallery-${Date.now()}-${Math.random().toString(36).slice(2, 8)}${ext}`;
    cb(null, name);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 8 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, allowed.includes(ext));
  },
});

// -- Shared locals -------------------------------------------------------------------
const assetVersion = Date.now().toString(36);
app.locals.assetV = assetVersion;
app.locals.fmt = charts.fmt;
app.locals.usd = (n) => `USD ${charts.fmt(n)}`;
app.locals.signed = (n) => `${n >= 0 ? '+' : '-'}${charts.fmt(Math.abs(n))}`;
app.locals.siteUrl = SITE_URL;
app.locals.contactEmail = process.env.CONTACT_EMAIL || 'visumoadm@gmail.com';
app.locals.year = new Date().getFullYear();

app.use(express.static(path.join(__dirname, 'public'), { maxAge: '7d', index: false }));

// -- Content middleware (Temporary Mock for Vercel Preview) -----------------------------
app.use((req, res, next) => {
  res.locals.c = {
    settings: { tagline: "VISUMO website" },
    income: { years: [], sources: [] }
  };
  res.locals.path = req.path;
  res.locals.noindex = false;
  res.locals.title = '';
  res.locals.description = "Website for Violence Survivors Mothers (VISUMO)";
  next();
});

  } catch (err) {
    next(err);
  }
});

// -- Page routes -----------------------------------------------------------------------
const page = (view, titleKey, active, extra = {}) => (req, res) => {
  const title = res.locals.t[titleKey] || titleKey;
  res.render(`pages/${view}`, { title, active, ...extra });
};

app.get('/', (req, res) => res.render('pages/home', {
  title: '',
  active: 'home',
  description: res.locals.t.hero_eyebrow + ' — VISUMO',
}));
app.get('/about', page('about', 'page_about_title', 'about'));
app.get('/programmes', page('programmes', 'page_programmes_title', 'about'));
app.get('/partners', page('partners', 'page_partners_title', 'impact'));
app.get('/voices', page('voices', 'page_voices_title', 'about'));
app.get('/finance', (req, res) => res.render('pages/finance', {
  title: res.locals.t.page_finance_title,
  active: 'impact',
  incomeChart: charts.incomeBars(res.locals.c.income.years),
  sourceChart: charts.sourceBars(res.locals.c.income.sources),
}));
app.get('/accountability', page('accountability', 'page_accountability_title', 'about'));
app.get('/2026', page('priorities', 'page_priorities_title', 'impact'));
app.get('/report', page('report', 'page_report_title', 'impact'));

// -- Gallery ---------------------------------------------------------------------------
app.get('/gallery', async (req, res, next) => {
  try {
    const images = await db.query('SELECT id, filename, caption, alt_text FROM gallery_images ORDER BY sort_order, created_at DESC');
    res.render('pages/gallery', {
      title: res.locals.t.gallery_title,
      active: 'gallery',
      images,
    });
  } catch (err) {
    next(err);
  }
});

// -- Contact form ----------------------------------------------------------------------
const contactLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 5,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => res.status(429).render('pages/contact', {
    title: res.locals.t.page_contact_title, active: 'contact', status: 'ratelimited', form: req.body || {}, errors: {},
  }),
});

app.get('/contact', (req, res) => res.render('pages/contact', {
  title: res.locals.t.page_contact_title, active: 'contact', status: req.query.sent ? 'sent' : '', form: {}, errors: {},
}));

app.post('/contact', contactLimiter, async (req, res, next) => {
  try {
    const clean = (v, max) => String(v || '').replace(/\r\n/g, '\n').trim().slice(0, max);
    const form = {
      full_name: clean(req.body.full_name, 150),
      email: clean(req.body.email, 200),
      organisation: clean(req.body.organisation, 200),
      subject: clean(req.body.subject, 200),
      message: clean(req.body.message, 4000),
    };
    if (clean(req.body.website, 200)) return res.redirect('/contact?sent=1');

    const errors = {};
    if (form.full_name.length < 2) errors.full_name = 'Veuillez saisir votre nom.';
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) errors.email = 'Veuillez saisir une adresse e-mail valide.';
    if (form.subject.length < 3) errors.subject = 'Veuillez indiquer un objet.';
    if (form.message.length < 10) errors.message = 'Veuillez écrire un message d\'au moins 10 caractères.';
    if (Object.keys(errors).length) {
      return res.status(422).render('pages/contact', {
        title: res.locals.t.page_contact_title, active: 'contact', status: 'invalid', form, errors,
      });
    }
    await db.query(
      'INSERT INTO contact_messages (full_name, email, organisation, subject, message) VALUES (?, ?, ?, ?, ?)',
      [form.full_name, form.email, form.organisation || null, form.subject, form.message],
    );
    res.redirect('/contact?sent=1');
  } catch (err) {
    next(err);
  }
});

// ---- Admin Authentication (Database & Session Cookie + HTTP Basic fallback) ----
const SESSION_SECRET = process.env.SESSION_SECRET || 'visumo-secret-key-2026-safe-token';

function createAdminToken(username) {
  const expires = Date.now() + 7 * 24 * 60 * 60 * 1000; // 7 days
  const data = `${username}:${expires}`;
  const sig = crypto.createHmac('sha256', SESSION_SECRET).update(data).digest('hex');
  return Buffer.from(`${data}:${sig}`).toString('base64');
}

function verifyAdminToken(token) {
  if (!token) return null;
  try {
    const raw = Buffer.from(token, 'base64').toString('utf8');
    const parts = raw.split(':');
    if (parts.length !== 3) return null;
    const [username, expiresStr, sig] = parts;
    const expires = Number(expiresStr);
    if (!expires || Date.now() > expires) return null;
    const expectedSig = crypto.createHmac('sha256', SESSION_SECRET).update(`${username}:${expires}`).digest('hex');
    const bSig = Buffer.from(sig);
    const bExpected = Buffer.from(expectedSig);
    if (bSig.length === bExpected.length && crypto.timingSafeEqual(bSig, bExpected)) {
      return { username };
    }
  } catch (e) {
    return null;
  }
  return null;
}

function parseCookie(req, name) {
  const header = req.headers.cookie || '';
  const match = header.match(new RegExp('(?:^|;\\s*)' + name + '=([^;]+)'));
  return match ? decodeURIComponent(match[1]) : null;
}

function safeEqual(a, b) {
  const ha = crypto.createHash('sha256').update(String(a)).digest();
  const hb = crypto.createHash('sha256').update(String(b)).digest();
  return crypto.timingSafeEqual(ha, hb);
}

async function adminAuth(req, res, next) {
  // 1. Check session cookie
  const sessionToken = parseCookie(req, 'admin_session');
  if (sessionToken) {
    const user = verifyAdminToken(sessionToken);
    if (user) {
      req.adminUser = user;
      return next();
    }
  }

  // 2. Check Basic Auth (fallback)
  const pass = process.env.ADMIN_PASSWORD || 'visumo2025admin';
  const header = req.headers.authorization || '';
  const [scheme, encoded] = header.split(' ');
  if (scheme === 'Basic' && encoded) {
    try {
      const decoded = Buffer.from(encoded, 'base64').toString('utf8');
      const i = decoded.indexOf(':');
      const user = decoded.slice(0, i);
      const given = decoded.slice(i + 1);
      const envUser = process.env.ADMIN_USER || 'admin';
      if (safeEqual(user, envUser) && safeEqual(given, pass)) {
        req.adminUser = { username: user };
        return next();
      }
      const hash = crypto.createHash('sha256').update(given).digest('hex');
      const rows = await db.query('SELECT username FROM admin_users WHERE username = ? AND password_hash = ?', [user, hash]);
      if (rows && rows.length > 0) {
        req.adminUser = { username: user };
        return next();
      }
    } catch (_) {}
  }

  // 3. Not authenticated: redirect browser to login page, or 401 for API
  if (req.accepts('html')) {
    return res.redirect('/admin/login');
  }
  res.set('WWW-Authenticate', 'Basic realm="VISUMO admin", charset="UTF-8"');
  return res.status(401).send('Authentication required.');
}

function sameOrigin(req, res, next) {
  const origin = req.headers.origin || req.headers.referer;
  if (!origin) return next();
  try {
    const originHost = new URL(origin).host;
    if (originHost && originHost !== req.headers.host) {
      return res.status(403).send('Cross-origin request blocked.');
    }
  } catch (e) {
    // Malformed URL, e.g. string 'null'
  }
  next();
}

// Admin login routes
app.get('/admin/login', (req, res) => {
  const sessionToken = parseCookie(req, 'admin_session');
  if (sessionToken && verifyAdminToken(sessionToken)) {
    return res.redirect('/admin');
  }
  res.render('pages/admin-login', { error: null });
});

app.post('/admin/login', async (req, res) => {
  const username = String(req.body.username || '').trim();
  const password = String(req.body.password || '');
  if (!username || !password) {
    return res.render('pages/admin-login', { error: "Veuillez saisir votre nom d'utilisateur et votre mot de passe.", username });
  }

  try {
    const hash = crypto.createHash('sha256').update(password).digest('hex');
    const rows = await db.query('SELECT username FROM admin_users WHERE username = ? AND password_hash = ?', [username, hash]);

    const envUser = process.env.ADMIN_USER || 'admin';
    const envPass = process.env.ADMIN_PASSWORD || 'visumo2025admin';
    const isEnvMatch = (username === envUser && password === envPass);

    if ((rows && rows.length > 0) || isEnvMatch) {
      const token = createAdminToken(username);
      res.cookie('admin_session', token, {
        httpOnly: true,
        sameSite: 'lax',
        maxAge: 7 * 24 * 60 * 60 * 1000,
      });
      return res.redirect('/admin');
    }
  } catch (err) {
    console.error('[admin login error]', err);
  }

  res.render('pages/admin-login', { error: "Nom d'utilisateur ou mot de passe incorrect.", username });
});

app.get('/admin/logout', (req, res) => {
  res.clearCookie('admin_session');
  res.redirect('/admin/login');
});

app.post('/admin/logout', (req, res) => {
  res.clearCookie('admin_session');
  res.redirect('/admin/login');
});

// Admin dashboard
app.get('/admin', adminAuth, async (req, res, next) => {
  try {
    const section = req.query.section || 'dashboard';
    const messages = await db.query(
      'SELECT id, full_name, email, organisation, subject, message, is_read, created_at FROM contact_messages ORDER BY created_at DESC, id DESC LIMIT 200',
    );
    const galleryImages = await db.query(
      'SELECT id, filename, caption, alt_text, sort_order, created_at FROM gallery_images ORDER BY sort_order, created_at DESC',
    );
    const settingsRows = await db.query('SELECT setting_key, setting_value FROM site_settings');
    const settings = Object.fromEntries(settingsRows.map((r) => [r.setting_key, r.setting_value]));
    const unreadCount = messages.filter((m) => !m.is_read).length;

    res.render('pages/admin', {
      title: 'Administration',
      active: '',
      noindex: true,
      section,
      messages,
      galleryImages,
      settings,
      unreadCount,
      totalImages: galleryImages.length,
      adminUser: req.adminUser ? req.adminUser.username : 'admin',
      query: req.query,
    });
  } catch (err) {
    next(err);
  }
});

// Admin: mark message as read
app.post('/admin/messages/:id/read', adminAuth, sameOrigin, async (req, res, next) => {
  try {
    const id = Number.parseInt(req.params.id, 10);
    if (Number.isInteger(id)) await db.query('UPDATE contact_messages SET is_read = TRUE WHERE id = ?', [id]);
    res.redirect('/admin?section=messages');
  } catch (err) {
    next(err);
  }
});

// Admin: delete message
app.post('/admin/messages/:id/delete', adminAuth, sameOrigin, async (req, res, next) => {
  try {
    const id = Number.parseInt(req.params.id, 10);
    if (Number.isInteger(id)) await db.query('DELETE FROM contact_messages WHERE id = ?', [id]);
    res.redirect('/admin?section=messages');
  } catch (err) {
    next(err);
  }
});

// Admin: upload gallery image
app.post('/admin/gallery/upload', adminAuth, sameOrigin, (req, res, next) => {
  upload.single('image')(req, res, (err) => {
    if (err) {
      console.error('[gallery upload multer error]', err);
      return res.redirect('/admin?section=gallery&error=' + encodeURIComponent(err.message || 'upload_failed'));
    }
    next();
  });
}, async (req, res, next) => {
  try {
    if (!req.file) return res.redirect('/admin?section=gallery&error=no-file');
    const caption = String(req.body.caption || '').trim().slice(0, 300);
    const alt_text = String(req.body.alt_text || '').trim().slice(0, 300) || caption;
    await db.query(
      'INSERT INTO gallery_images (filename, caption, alt_text) VALUES (?, ?, ?)',
      [req.file.filename, caption, alt_text],
    );
    clearCache();
    res.redirect('/admin?section=gallery&success=uploaded');
  } catch (err) {
    console.error('[gallery insert error]', err);
    res.redirect('/admin?section=gallery&error=db_error');
  }
});

// Admin: delete gallery image
app.post('/admin/gallery/:id/delete', adminAuth, sameOrigin, async (req, res, next) => {
  try {
    const id = Number.parseInt(req.params.id, 10);
    if (Number.isInteger(id)) {
      const rows = await db.query('SELECT filename FROM gallery_images WHERE id = ?', [id]);
      if (rows.length) {
        const filePath = path.join(GALLERY_DIR, rows[0].filename);
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
        await db.query('DELETE FROM gallery_images WHERE id = ?', [id]);
      }
    }
    clearCache();
    res.redirect('/admin?section=gallery');
  } catch (err) {
    next(err);
  }
});

// Admin: update site settings
app.post('/admin/content/update', adminAuth, sameOrigin, async (req, res, next) => {
  try {
    const keys = ['hero_headline', 'tagline', 'sw_motto', 'site_name', 'org_full_name', 'footer_note', 'reporting_period'];
    for (const key of keys) {
      if (req.body[key] !== undefined) {
        const val = String(req.body[key]).trim().slice(0, 2000);
        await db.query('UPDATE site_settings SET setting_value = ? WHERE setting_key = ?', [val, key]);
      }
    }
    clearCache();
    res.redirect('/admin?section=content&success=saved');
  } catch (err) {
    next(err);
  }
});

// Admin: clear cache
app.post('/admin/cache/clear', adminAuth, sameOrigin, (req, res) => {
  clearCache();
  res.redirect('/admin?section=dashboard');
});

// ---- JSON API, health, SEO ----------------------------------------------------------
app.get('/api/income', (req, res) => {
  const { years, sources, growth } = res.locals.c.income;
  res.json({ currency: 'USD', years, sources, growth_2024_to_2025: growth });
});

app.get('/api/sections', (req, res) => {
  res.json(res.locals.c.contents.map((s) => ({ number: s.section_number, slug: s.slug, title: s.title })));
});

app.get('/healthz', async (req, res) => {
  try {
    await db.ping();
    res.json({ status: 'ok', database: db.client });
  } catch (err) {
    res.status(503).json({ status: 'error', database: db.client });
  }
});

app.get('/robots.txt', (req, res) => {
  res.type('text/plain').send(`User-agent: *\nDisallow: /admin\n${SITE_URL ? `Sitemap: ${SITE_URL}/sitemap.xml\n` : ''}`);
});

app.get('/sitemap.xml', (req, res) => {
  const base = SITE_URL || `${req.protocol}://${req.get('host')}`;
  const urls = ['/', '/about', '/programmes', '/partners', '/voices', '/finance', '/accountability', '/2026', '/report', '/gallery', '/contact'];
  res.type('application/xml').send(
    `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls.map((u) => `  <url><loc>${base}${u}</loc></url>`).join('\n')}\n</urlset>\n`,
  );
});

// ---- Errors -------------------------------------------------------------------------
app.use((req, res) => {
  res.status(404).render('pages/error', {
    title: res.locals.t.error_title_404, active: '', code: 404, message: res.locals.t.error_404,
  });
});

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('[error]', err);
  const c = res.locals.c;
  if (!c) return res.status(500).send('Service temporairement indisponible.');
  res.status(500).render('pages/error', {
    title: res.locals.t.error_title_500, active: '', code: 500, message: res.locals.t.error_500,
  });
});

if (require.main === module) {
  const server = app.listen(PORT, HOST, () => console.log(`VISUMO website listening on ${HOST}:${PORT} (database: ${db.client})`));
  const shutdown = async () => {
    server.close();
    try { await db.pool.end(); } catch (e) { /* ignore */ }
   // process.exit(0);
 // };
 // process.on('SIGTERM', shutdown);
  //process.on('SIGINT', shutdown);
//}

//module.exports = app;
'use strict';
const path = require('path');
const express = require('express');
const compression = require('compression');

const app = express();

app.disable('x-powered-by');
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(compression());
app.use(express.static(path.join(__dirname, 'public'), { maxAge: '7d', index: false }));

// This block forces dummy text into your templates so your views don't throw a 500 error
app.use((req, res, next) => {
  res.locals.t = {
    hero_eyebrow: "VISUMO",
    hero_headline: "Mères survivantes de violences",
    page_about_title: "A propos",
    page_programmes_title: "Programmes",
    page_partners_title: "Partenaires",
    page_voices_title: "Témoignages",
    page_finance_title: "Finances",
    page_accountability_title: "Responsabilité",
    page_priorities_title: "Priorités 2026",
    page_report_title: "Rapport Annuel",
    page_contact_title: "Contact",
    gallery_title: "Galerie"
  };
  res.locals.c = {
    settings: { tagline: "Site Web VISUMO", hero_headline: "VISUMO" },
    income: { years: [], sources: [] }
  };
  res.locals.path = req.path;
  res.locals.noindex = false;
  res.locals.title = 'VISUMO';
  res.locals.description = 'Mères survivantes de violences';
  res.locals.assetV = '1.0';
  res.locals.contactEmail = 'visumoadm@gmail.com';
  res.locals.year = new Date().getFullYear();
  
  res.locals.fmt = (n) => String(n);
  res.locals.usd = (n) => `USD ${n}`;
  res.locals.signed = (n) => String(n);
  next();
});

const page = (view) => (req, res) => res.render(`pages/${view}`, { active: view });

app.get('/', (req, res) => res.render('pages/home', { active: 'home' }));
app.get('/about', page('about'));
app.get('/programmes', page('programmes'));
app.get('/partners', page('partners'));
app.get('/voices', page('voices'));
app.get('/finance', (req, res) => res.render('pages/finance', { active: 'impact', incomeChart: '', sourceChart: '' }));
app.get('/accountability', page('accountability'));
app.get('/2026', page('priorities'));
app.get('/report', page('report'));
app.get('/gallery', (req, res) => res.render('pages/gallery', { active: 'gallery', images: [] }));
app.get('/contact', (req, res) => res.render('pages/contact', { active: 'contact', status: '', form: {}, errors: {} }));

module.exports = app;
