-- VISUMO website database - PostgreSQL schema (PostgreSQL 13+)
-- Content source: VISUMO Annual Narrative Report 2025

DROP TABLE IF EXISTS contact_messages CASCADE;
DROP TABLE IF EXISTS site_images CASCADE;
DROP TABLE IF EXISTS site_settings CASCADE;
DROP TABLE IF EXISTS document_control CASCADE;
DROP TABLE IF EXISTS project_design_figures CASCADE;
DROP TABLE IF EXISTS evidence_sources CASCADE;
DROP TABLE IF EXISTS priorities_2026 CASCADE;
DROP TABLE IF EXISTS challenges CASCADE;
DROP TABLE IF EXISTS safeguarding_risks CASCADE;
DROP TABLE IF EXISTS me_indicators CASCADE;
DROP TABLE IF EXISTS income_source_amounts CASCADE;
DROP TABLE IF EXISTS income_sources CASCADE;
DROP TABLE IF EXISTS annual_income CASCADE;
DROP TABLE IF EXISTS testimonies CASCADE;
DROP TABLE IF EXISTS stakeholders CASCADE;
DROP TABLE IF EXISTS terminology_guide CASCADE;
DROP TABLE IF EXISTS outreach_elements CASCADE;
DROP TABLE IF EXISTS disability_barriers CASCADE;
DROP TABLE IF EXISTS community_messages CASCADE;
DROP TABLE IF EXISTS operational_assumptions CASCADE;
DROP TABLE IF EXISTS theory_of_change CASCADE;
DROP TABLE IF EXISTS dashboard_areas CASCADE;
DROP TABLE IF EXISTS organisation_profile CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS callouts CASCADE;
DROP TABLE IF EXISTS section_paragraphs CASCADE;
DROP TABLE IF EXISTS report_sections CASCADE;

CREATE TABLE report_sections (
    id                 SERIAL PRIMARY KEY,
    section_number     INTEGER      NOT NULL UNIQUE,
    slug               VARCHAR(80)  NOT NULL UNIQUE,
    title              VARCHAR(200) NOT NULL,
    listed_in_contents BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE section_paragraphs (
    id             SERIAL PRIMARY KEY,
    section_number INTEGER NOT NULL REFERENCES report_sections (section_number) ON DELETE CASCADE,
    sort_order     INTEGER NOT NULL DEFAULT 0,
    body           TEXT    NOT NULL
);
CREATE INDEX idx_section_paragraphs_section ON section_paragraphs (section_number, sort_order);

CREATE TABLE callouts (
    id             SERIAL PRIMARY KEY,
    slug           VARCHAR(80)  NOT NULL UNIQUE,
    section_number INTEGER REFERENCES report_sections (section_number) ON DELETE SET NULL,
    heading        VARCHAR(200) NOT NULL,
    body           TEXT         NOT NULL,
    sort_order     INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE locations (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(120) NOT NULL UNIQUE,
    kind       VARCHAR(60)  NOT NULL,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE organisation_profile (
    id         SERIAL PRIMARY KEY,
    element    VARCHAR(200) NOT NULL,
    details    TEXT         NOT NULL,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE dashboard_areas (
    id            SERIAL PRIMARY KEY,
    area          VARCHAR(200) NOT NULL,
    position_text TEXT         NOT NULL,
    sort_order    INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE theory_of_change (
    id          SERIAL PRIMARY KEY,
    logic_level VARCHAR(80) NOT NULL,
    model_text  TEXT        NOT NULL,
    sort_order  INTEGER     NOT NULL DEFAULT 0
);

CREATE TABLE operational_assumptions (
    id          SERIAL PRIMARY KEY,
    assumption  VARCHAR(200) NOT NULL,
    application TEXT         NOT NULL,
    sort_order  INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE community_messages (
    id           SERIAL PRIMARY KEY,
    message_type VARCHAR(120) NOT NULL,
    lang         VARCHAR(10)  NOT NULL,
    wording      TEXT         NOT NULL,
    sort_order   INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE disability_barriers (
    id         SERIAL PRIMARY KEY,
    barrier    VARCHAR(200) NOT NULL,
    response   TEXT         NOT NULL,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE outreach_elements (
    id            SERIAL PRIMARY KEY,
    element       VARCHAR(200) NOT NULL,
    practical_use TEXT         NOT NULL,
    sort_order    INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE terminology_guide (
    id             SERIAL PRIMARY KEY,
    technical_term VARCHAR(120) NOT NULL,
    better_wording TEXT         NOT NULL,
    sort_order     INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE stakeholders (
    id                SERIAL PRIMARY KEY,
    stakeholder_group VARCHAR(200) NOT NULL,
    contribution      TEXT         NOT NULL,
    sort_order        INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE testimonies (
    id         SERIAL PRIMARY KEY,
    lang       VARCHAR(10)  NOT NULL,
    title      VARCHAR(200) NOT NULL,
    quote      TEXT         NOT NULL,
    anonymised BOOLEAN      NOT NULL DEFAULT TRUE,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE annual_income (
    id          SERIAL PRIMARY KEY,
    report_year INTEGER       NOT NULL UNIQUE,
    amount_usd  NUMERIC(14,2) NOT NULL CHECK (amount_usd >= 0),
    basis       VARCHAR(200)  NOT NULL,
    is_audited  BOOLEAN       NOT NULL DEFAULT FALSE
);

CREATE TABLE income_sources (
    id         INTEGER PRIMARY KEY,
    name       VARCHAR(200) NOT NULL UNIQUE,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE income_source_amounts (
    id          SERIAL PRIMARY KEY,
    source_id   INTEGER       NOT NULL REFERENCES income_sources (id) ON DELETE CASCADE,
    report_year INTEGER       NOT NULL,
    amount_usd  NUMERIC(14,2) NOT NULL CHECK (amount_usd >= 0),
    UNIQUE (source_id, report_year)
);

CREATE TABLE me_indicators (
    id          SERIAL PRIMARY KEY,
    area        VARCHAR(200) NOT NULL,
    indicator   TEXT         NOT NULL,
    data_source TEXT         NOT NULL,
    sort_order  INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE safeguarding_risks (
    id           SERIAL PRIMARY KEY,
    risk         VARCHAR(300) NOT NULL,
    action_taken TEXT         NOT NULL,
    sort_order   INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE challenges (
    id         SERIAL PRIMARY KEY,
    challenge  VARCHAR(300) NOT NULL,
    mitigation TEXT         NOT NULL,
    lesson     TEXT         NOT NULL,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE priorities_2026 (
    id         SERIAL PRIMARY KEY,
    sort_order INTEGER NOT NULL DEFAULT 0,
    priority   TEXT    NOT NULL
);

CREATE TABLE evidence_sources (
    id          SERIAL PRIMARY KEY,
    source_item VARCHAR(200) NOT NULL,
    report_use  TEXT         NOT NULL,
    sort_order  INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE project_design_figures (
    id             SERIAL PRIMARY KEY,
    figure_value   INTEGER      NOT NULL,
    label          VARCHAR(120) NOT NULL,
    detail         VARCHAR(300) NOT NULL,
    is_approximate BOOLEAN      NOT NULL DEFAULT FALSE,
    sort_order     INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE document_control (
    id         SERIAL PRIMARY KEY,
    field_name VARCHAR(200) NOT NULL,
    details    TEXT         NOT NULL,
    sort_order INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE site_settings (
    id            SERIAL PRIMARY KEY,
    setting_key   VARCHAR(80) NOT NULL UNIQUE,
    setting_value TEXT        NOT NULL
);

CREATE TABLE site_images (
    id             SERIAL PRIMARY KEY,
    filename       VARCHAR(200) NOT NULL UNIQUE,
    section_number INTEGER REFERENCES report_sections (section_number) ON DELETE SET NULL,
    caption        TEXT         NOT NULL,
    alt_text       VARCHAR(300) NOT NULL,
    sort_order     INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE contact_messages (
    id           SERIAL PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    email        VARCHAR(200) NOT NULL,
    organisation VARCHAR(200),
    subject      VARCHAR(200) NOT NULL,
    message      TEXT         NOT NULL,
    is_read      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_contact_messages_created ON contact_messages (created_at);

CREATE TABLE gallery_images (
    id         SERIAL PRIMARY KEY,
    filename   VARCHAR(255) NOT NULL UNIQUE,
    caption    TEXT NOT NULL DEFAULT '',
    alt_text   VARCHAR(300) NOT NULL DEFAULT '',
    image_data BYTEA,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admin_users (
    id            SERIAL PRIMARY KEY,
    username      VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(30) NOT NULL DEFAULT 'admin',
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
