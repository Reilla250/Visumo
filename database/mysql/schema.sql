-- VISUMO website database - MySQL schema (MySQL 8.0+ / MariaDB 10.5+)
-- Content source: VISUMO Annual Narrative Report 2025

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS contact_messages;
DROP TABLE IF EXISTS gallery_images;
DROP TABLE IF EXISTS admin_users;
DROP TABLE IF EXISTS site_images;
DROP TABLE IF EXISTS site_settings;
DROP TABLE IF EXISTS document_control;
DROP TABLE IF EXISTS project_design_figures;
DROP TABLE IF EXISTS evidence_sources;
DROP TABLE IF EXISTS priorities_2026;
DROP TABLE IF EXISTS challenges;
DROP TABLE IF EXISTS safeguarding_risks;
DROP TABLE IF EXISTS me_indicators;
DROP TABLE IF EXISTS income_source_amounts;
DROP TABLE IF EXISTS income_sources;
DROP TABLE IF EXISTS annual_income;
DROP TABLE IF EXISTS testimonies;
DROP TABLE IF EXISTS stakeholders;
DROP TABLE IF EXISTS terminology_guide;
DROP TABLE IF EXISTS outreach_elements;
DROP TABLE IF EXISTS disability_barriers;
DROP TABLE IF EXISTS community_messages;
DROP TABLE IF EXISTS operational_assumptions;
DROP TABLE IF EXISTS theory_of_change;
DROP TABLE IF EXISTS dashboard_areas;
DROP TABLE IF EXISTS organisation_profile;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS callouts;
DROP TABLE IF EXISTS section_paragraphs;
DROP TABLE IF EXISTS report_sections;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE report_sections (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    section_number     INT          NOT NULL UNIQUE,
    slug               VARCHAR(80)  NOT NULL UNIQUE,
    title              VARCHAR(200) NOT NULL,
    listed_in_contents BOOLEAN      NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE section_paragraphs (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    section_number INT  NOT NULL,
    sort_order     INT  NOT NULL DEFAULT 0,
    body           TEXT NOT NULL,
    INDEX idx_section_paragraphs_section (section_number, sort_order),
    CONSTRAINT fk_paragraph_section FOREIGN KEY (section_number)
        REFERENCES report_sections (section_number) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE callouts (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    slug           VARCHAR(80)  NOT NULL UNIQUE,
    section_number INT NULL,
    heading        VARCHAR(200) NOT NULL,
    body           TEXT         NOT NULL,
    sort_order     INT          NOT NULL DEFAULT 0,
    CONSTRAINT fk_callout_section FOREIGN KEY (section_number)
        REFERENCES report_sections (section_number) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE locations (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(120) NOT NULL UNIQUE,
    kind       VARCHAR(60)  NOT NULL,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE organisation_profile (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    element    VARCHAR(200) NOT NULL,
    details    TEXT         NOT NULL,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dashboard_areas (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    area          VARCHAR(200) NOT NULL,
    position_text TEXT         NOT NULL,
    sort_order    INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE theory_of_change (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    logic_level VARCHAR(80) NOT NULL,
    model_text  TEXT        NOT NULL,
    sort_order  INT         NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE operational_assumptions (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    assumption  VARCHAR(200) NOT NULL,
    application TEXT         NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE community_messages (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    message_type VARCHAR(120) NOT NULL,
    lang         VARCHAR(10)  NOT NULL,
    wording      TEXT         NOT NULL,
    sort_order   INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE disability_barriers (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    barrier    VARCHAR(200) NOT NULL,
    response   TEXT         NOT NULL,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE outreach_elements (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    element       VARCHAR(200) NOT NULL,
    practical_use TEXT         NOT NULL,
    sort_order    INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE terminology_guide (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    technical_term VARCHAR(120) NOT NULL,
    better_wording TEXT         NOT NULL,
    sort_order     INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE stakeholders (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    stakeholder_group VARCHAR(200) NOT NULL,
    contribution      TEXT         NOT NULL,
    sort_order        INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE testimonies (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    lang       VARCHAR(10)  NOT NULL,
    title      VARCHAR(200) NOT NULL,
    quote      TEXT         NOT NULL,
    anonymised BOOLEAN      NOT NULL DEFAULT TRUE,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE annual_income (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    report_year INT           NOT NULL UNIQUE,
    amount_usd  DECIMAL(14,2) NOT NULL CHECK (amount_usd >= 0),
    basis       VARCHAR(200)  NOT NULL,
    is_audited  BOOLEAN       NOT NULL DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE income_sources (
    id         INT PRIMARY KEY,
    name       VARCHAR(200) NOT NULL UNIQUE,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE income_source_amounts (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    source_id   INT           NOT NULL,
    report_year INT           NOT NULL,
    amount_usd  DECIMAL(14,2) NOT NULL CHECK (amount_usd >= 0),
    UNIQUE KEY uq_source_year (source_id, report_year),
    CONSTRAINT fk_amount_source FOREIGN KEY (source_id)
        REFERENCES income_sources (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE me_indicators (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    area        VARCHAR(200) NOT NULL,
    indicator   TEXT         NOT NULL,
    data_source TEXT         NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE safeguarding_risks (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    risk         VARCHAR(300) NOT NULL,
    action_taken TEXT         NOT NULL,
    sort_order   INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE challenges (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    challenge  VARCHAR(300) NOT NULL,
    mitigation TEXT         NOT NULL,
    lesson     TEXT         NOT NULL,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE priorities_2026 (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    sort_order INT  NOT NULL DEFAULT 0,
    priority   TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE evidence_sources (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    source_item VARCHAR(200) NOT NULL,
    report_use  TEXT         NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE project_design_figures (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    figure_value   INT          NOT NULL,
    label          VARCHAR(120) NOT NULL,
    detail         VARCHAR(300) NOT NULL,
    is_approximate BOOLEAN      NOT NULL DEFAULT FALSE,
    sort_order     INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE document_control (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    field_name VARCHAR(200) NOT NULL,
    details    TEXT         NOT NULL,
    sort_order INT          NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE site_settings (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    setting_key   VARCHAR(80) NOT NULL UNIQUE,
    setting_value TEXT        NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE site_images (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    filename       VARCHAR(200) NOT NULL UNIQUE,
    section_number INT NULL,
    caption        TEXT         NOT NULL,
    alt_text       VARCHAR(300) NOT NULL,
    sort_order     INT          NOT NULL DEFAULT 0,
    CONSTRAINT fk_image_section FOREIGN KEY (section_number)
        REFERENCES report_sections (section_number) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE contact_messages (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    email        VARCHAR(200) NOT NULL,
    organisation VARCHAR(200) NULL,
    subject      VARCHAR(200) NOT NULL,
    message      TEXT         NOT NULL,
    is_read      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_contact_messages_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE gallery_images (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    filename   VARCHAR(255) NOT NULL UNIQUE,
    caption    TEXT         NOT NULL,
    alt_text   VARCHAR(300) NOT NULL DEFAULT '',
    sort_order INT          NOT NULL DEFAULT 0,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(80)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(30)  NOT NULL DEFAULT 'admin',
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
