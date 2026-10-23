'use strict';
/**
 * Loads all public website content from the database and shapes it for the views.
 * Results are cached in memory for CACHE_TTL_SECONDS (default 60) so the database
 * is not hit on every page view. Set CACHE_TTL_SECONDS=0 to disable.
 */
const { query } = require('./db');
const localizeToFrench = require('./french-content');

const TTL_MS = (process.env.CACHE_TTL_SECONDS === undefined ? 60 : Number(process.env.CACHE_TTL_SECONDS)) * 1000;
let cache = null;
let cachedAt = 0;
let inflight = null;

async function load() {
  const [
    settingsRows, sections, paragraphs, callouts, locations, profile, dashboard, theory, assumptions,
    messages, barriers, outreach, terms, stakeholders, testimonies,
    indicators, risks, challenges, priorities, figures, images,
  ] = await Promise.all([
    query('SELECT setting_key, setting_value FROM site_settings'),
    query('SELECT section_number, slug, title, listed_in_contents FROM report_sections ORDER BY section_number'),
    query('SELECT section_number, sort_order, body FROM section_paragraphs ORDER BY section_number, sort_order'),
    query('SELECT slug, section_number, heading, body FROM callouts ORDER BY sort_order'),
    query('SELECT name, kind FROM locations ORDER BY sort_order'),
    query('SELECT element, details FROM organisation_profile ORDER BY sort_order'),
    query('SELECT area, position_text FROM dashboard_areas ORDER BY sort_order'),
    query('SELECT logic_level, model_text FROM theory_of_change ORDER BY sort_order'),
    query('SELECT assumption, application FROM operational_assumptions ORDER BY sort_order'),
    query('SELECT message_type, lang, wording FROM community_messages ORDER BY sort_order'),
    query('SELECT barrier, response FROM disability_barriers ORDER BY sort_order'),
    query('SELECT element, practical_use FROM outreach_elements ORDER BY sort_order'),
    query('SELECT technical_term, better_wording FROM terminology_guide ORDER BY sort_order'),
    query('SELECT stakeholder_group, contribution FROM stakeholders ORDER BY sort_order'),
    query('SELECT lang, title, quote, anonymised FROM testimonies ORDER BY sort_order'),
    query('SELECT area, indicator, data_source FROM me_indicators ORDER BY sort_order'),
    query('SELECT risk, action_taken FROM safeguarding_risks ORDER BY sort_order'),
    query('SELECT challenge, mitigation, lesson FROM challenges ORDER BY sort_order'),
    query('SELECT priority FROM priorities_2026 ORDER BY sort_order'),
    query('SELECT figure_value, label, detail, is_approximate FROM project_design_figures ORDER BY sort_order'),
    query('SELECT filename, section_number, caption, alt_text FROM site_images ORDER BY sort_order'),
  ]);

  const settings = Object.fromEntries(settingsRows.map((r) => [r.setting_key, r.setting_value]));

  const sec = {};
  sections.forEach((s) => { sec[s.section_number] = { ...s, listed_in_contents: !!s.listed_in_contents }; });

  const paras = {};
  paragraphs.forEach((p) => { (paras[p.section_number] = paras[p.section_number] || []).push(p.body); });

  const call = {};
  callouts.forEach((c) => { call[c.slug] = c; });

  const img = {};
  images.forEach((i) => { img[i.filename] = i; });

  return localizeToFrench({
    settings,
    sections: sec,
    contents: sections.filter((s) => s.listed_in_contents),
    paras,
    call,
    img,
    locations,
    profile,
    dashboard,
    theory,
    assumptions,
    messages,
    barriers,
    outreach,
    terms,
    stakeholders,
    testimonies: testimonies.map((t) => ({ ...t, anonymised: !!t.anonymised })),
    indicators,
    risks,
    challenges,
    priorities: priorities.map((p) => p.priority),
    figures: figures.map((f) => ({ ...f, is_approximate: !!f.is_approximate })),
  });
}

async function getContent() {
  const now = Date.now();
  if (cache && TTL_MS > 0 && now - cachedAt < TTL_MS) return cache;
  if (inflight) return inflight;
  inflight = load()
    .then((data) => {
      cache = data;
      cachedAt = Date.now();
      return data;
    })
    .finally(() => { inflight = null; });
  return inflight;
}

function clearCache() { cache = null; }

module.exports = { getContent, clearCache };
