'use strict';
/**
 * Server-side SVG charts built from database values (no client JS, no external libraries).
 * Colours come from CSS classes defined in public/css/site.css so light/dark and contrast stay in one place.
 */
const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

const fmt = (n) => Number(n).toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Five-year annual income, vertical bars drawn from zero (honest scale). */
function incomeBars(years) {
  const W = 760, H = 380, left = 24, right = 24, top = 44, bottom = 78;
  const plotW = W - left - right, plotH = H - top - bottom;
  const max = Math.max(...years.map((y) => y.amount));
  const slot = plotW / years.length;
  const barW = Math.min(88, slot * 0.62);
  let out = `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img" aria-labelledby="inc-t inc-d" xmlns="http://www.w3.org/2000/svg">`;
  out += `<title id="inc-t">Revenus annuels de 2021 à 2025 en dollars américains</title>`;
  out += `<desc id="inc-d">${esc(years.map((y) => `${y.year} : ${fmt(y.amount)} USD (${y.audited ? 'comptes audités' : 'documents internes'})`).join(' ; '))}</desc>`;
  out += `<line class="axis" x1="${left}" y1="${top + plotH}" x2="${W - right}" y2="${top + plotH}"/>`;
  years.forEach((y, i) => {
    const h = (y.amount / max) * plotH;
    const x = left + slot * i + (slot - barW) / 2;
    const yy = top + plotH - h;
    out += `<rect class="bar ${y.audited ? 'bar-audited' : 'bar-internal'}" x="${x.toFixed(1)}" y="${yy.toFixed(1)}" width="${barW.toFixed(1)}" height="${h.toFixed(1)}" rx="3"/>`;
    out += `<text class="val" x="${(x + barW / 2).toFixed(1)}" y="${(yy - 10).toFixed(1)}" text-anchor="middle">${fmt(y.amount)}</text>`;
    out += `<text class="lbl" x="${(x + barW / 2).toFixed(1)}" y="${top + plotH + 24}" text-anchor="middle">${y.year}</text>`;
    out += `<text class="sub" x="${(x + barW / 2).toFixed(1)}" y="${top + plotH + 44}" text-anchor="middle">${y.audited ? 'Audité' : 'Données internes'}</text>`;
  });
  out += `<text class="sub" x="${left}" y="22">USD, montants exacts — axe à zéro</text>`;
  out += `</svg>`;
  return out;
}

/** 2024 vs 2025 income by source, horizontal grouped bars. */
function sourceBars(sources) {
  const W = 760, left = 24, right = 150, groupH = 92, top = 36;
  const H = top + groupH * sources.length + 8;
  const max = Math.max(...sources.flatMap((s) => [s.y2024, s.y2025]));
  const plotW = W - left - right;
  let out = `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img" aria-labelledby="src-t src-d" xmlns="http://www.w3.org/2000/svg">`;
  out += `<title id="src-t">Revenus audités par source, comparaison entre 2024 et 2025</title>`;
  out += `<desc id="src-d">${esc(sources.map((s) => `${s.name} : 2024 : ${fmt(s.y2024)} USD, 2025 : ${fmt(s.y2025)} USD`).join(' ; '))}</desc>`;
  out += `<rect class="bar bar-2024" x="${left}" y="8" width="14" height="14" rx="2"/><text class="sub" x="${left + 20}" y="20">2024 audité</text>`;
  out += `<rect class="bar bar-audited" x="${left + 130}" y="8" width="14" height="14" rx="2"/><text class="sub" x="${left + 150}" y="20">2025 audité</text>`;
  sources.forEach((s, i) => {
    const y0 = top + groupH * i;
    out += `<text class="lbl" x="${left}" y="${y0 + 14}">${esc(s.name)}</text>`;
    [['y2024', 'bar-2024', 22], ['y2025', 'bar-audited', 52]].forEach(([k, cls, dy]) => {
      const w = Math.max(2, (s[k] / max) * plotW);
      out += `<rect class="bar ${cls}" x="${left}" y="${y0 + dy}" width="${w.toFixed(1)}" height="24" rx="3"/>`;
      out += `<text class="val" x="${(left + w + 8).toFixed(1)}" y="${y0 + dy + 17}">${fmt(s[k])}</text>`;
    });
  });
  out += `</svg>`;
  return out;
}

module.exports = { incomeBars, sourceBars, fmt };
