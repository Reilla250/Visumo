-- VISUMO website database - SQLite schema
-- Compatible with content.js table queries

CREATE TABLE IF NOT EXISTS report_sections (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    section_number     INTEGER      NOT NULL UNIQUE,
    slug               TEXT         NOT NULL UNIQUE,
    title              TEXT         NOT NULL,
    listed_in_contents INTEGER      NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS section_paragraphs (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    section_number INTEGER NOT NULL,
    sort_order     INTEGER NOT NULL DEFAULT 0,
    body           TEXT    NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_section_paragraphs_section ON section_paragraphs (section_number, sort_order);

CREATE TABLE IF NOT EXISTS callouts (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    slug           TEXT    NOT NULL UNIQUE,
    section_number INTEGER,
    heading        TEXT    NOT NULL,
    body           TEXT    NOT NULL,
    sort_order     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS locations (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL UNIQUE,
    kind       TEXT    NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS organisation_profile (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    element    TEXT    NOT NULL,
    details    TEXT    NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS dashboard_areas (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    area          TEXT    NOT NULL,
    position_text TEXT    NOT NULL,
    sort_order    INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS theory_of_change (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    logic_level TEXT    NOT NULL,
    model_text  TEXT    NOT NULL,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS operational_assumptions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    assumption  TEXT    NOT NULL,
    application TEXT    NOT NULL,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS community_messages (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    message_type TEXT    NOT NULL,
    lang         TEXT    NOT NULL,
    wording      TEXT    NOT NULL,
    sort_order   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS disability_barriers (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    barrier    TEXT    NOT NULL,
    response   TEXT    NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS outreach_elements (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    element       TEXT    NOT NULL,
    practical_use TEXT    NOT NULL,
    sort_order    INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS terminology_guide (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    technical_term TEXT    NOT NULL,
    better_wording TEXT    NOT NULL,
    sort_order     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS stakeholders (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    stakeholder_group TEXT    NOT NULL,
    contribution      TEXT    NOT NULL,
    sort_order        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS testimonies (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    lang       TEXT    NOT NULL,
    title      TEXT    NOT NULL,
    quote      TEXT    NOT NULL,
    anonymised INTEGER NOT NULL DEFAULT 1,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS annual_income (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    report_year INTEGER NOT NULL UNIQUE,
    amount_usd  REAL    NOT NULL,
    basis       TEXT    NOT NULL,
    is_audited  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS income_sources (
    id         INTEGER PRIMARY KEY,
    name       TEXT    NOT NULL UNIQUE,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS income_source_amounts (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    source_id   INTEGER NOT NULL,
    report_year INTEGER NOT NULL,
    amount_usd  REAL    NOT NULL,
    UNIQUE (source_id, report_year)
);

CREATE TABLE IF NOT EXISTS me_indicators (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    area        TEXT    NOT NULL,
    indicator   TEXT    NOT NULL,
    data_source TEXT    NOT NULL,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS safeguarding_risks (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    risk         TEXT    NOT NULL,
    action_taken TEXT    NOT NULL,
    sort_order   INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS challenges (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    challenge  TEXT    NOT NULL,
    mitigation TEXT    NOT NULL,
    lesson     TEXT    NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS priorities_2026 (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    priority   TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS evidence_sources (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    source_item TEXT    NOT NULL,
    report_use  TEXT    NOT NULL,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS project_design_figures (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    figure_value   TEXT    NOT NULL,
    label          TEXT    NOT NULL,
    detail         TEXT    NOT NULL,
    is_approximate INTEGER NOT NULL DEFAULT 0,
    sort_order     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS document_control (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    field_name TEXT    NOT NULL,
    details    TEXT    NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS site_settings (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    setting_key   TEXT    NOT NULL UNIQUE,
    setting_value TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS site_images (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    filename       TEXT    NOT NULL UNIQUE,
    section_number INTEGER,
    caption        TEXT    NOT NULL,
    alt_text       TEXT    NOT NULL,
    sort_order     INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS contact_messages (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name    TEXT    NOT NULL,
    email        TEXT    NOT NULL,
    organisation TEXT,
    subject      TEXT    NOT NULL,
    message      TEXT    NOT NULL,
    is_read      INTEGER NOT NULL DEFAULT 0,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_contact_messages_created ON contact_messages (created_at);

CREATE TABLE IF NOT EXISTS gallery_images (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    filename   TEXT    NOT NULL UNIQUE,
    caption    TEXT    NOT NULL DEFAULT '',
    alt_text   TEXT    NOT NULL DEFAULT '',
    image_data BLOB,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admin_users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    password_hash TEXT    NOT NULL,
    role          TEXT    NOT NULL DEFAULT 'admin',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
