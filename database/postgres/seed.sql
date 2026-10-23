-- VISUMO website data - PostgreSQL
SET client_encoding = 'UTF8';
BEGIN;

INSERT INTO report_sections (section_number, slug, title, listed_in_contents) VALUES
  (1, 'identity', 'Organisational identity and profile', TRUE),
  (3, 'executive-summary', 'Executive summary', TRUE),
  (4, 'dashboard', '2025 strategic dashboard', TRUE),
  (5, 'context', 'Operating context in North Kivu', TRUE),
  (6, 'theory-of-change', 'Theory of change and programme model', TRUE),
  (7, 'outreach', 'Community outreach, SRHR information and safe referrals', TRUE),
  (8, 'disability-inclusion', 'Disability inclusion and survivor leadership', TRUE),
  (9, 'indigenous-rural', 'Indigenous/autochthonous women and rural community engagement', TRUE),
  (10, 'health-communication', 'Health communication: HIV, family planning, safe pregnancy and post-rape care', TRUE),
  (11, 'partnerships', 'Partnerships and local accountability', TRUE),
  (12, 'voices', 'Beneficiary voices: Kiswahili and French testimonies', TRUE),
  (15, 'monitoring-learning', 'Monitoring, evaluation, accountability and learning', TRUE),
  (16, 'safeguarding', 'Safeguarding, ethics and survivor-safe documentation', TRUE),
  (17, 'challenges', 'Challenges, mitigation and lessons learned', TRUE),
  (18, 'priorities-2026', '2026 priorities and sustainability plan', TRUE);

INSERT INTO section_paragraphs (section_number, sort_order, body) VALUES
  (1, 1, 'Registered in the Democratic Republic of the Congo and rooted in North Kivu community realities.'),
  (1, 2, 'Formal legal evidence can be supplied separately as a due-diligence document when requested by donors, authorities or partners. VISUMO''s public information focuses on identity, results, learning, community accountability and programme readiness.'),
  (3, 1, 'VISUMO entered 2025 with a clear identity: a survivor-led civil society organisation in North Kivu that stands beside women and girls affected by violence, displacement, trauma, HIV-related stigma, disability exclusion and barriers to sexual and reproductive health and rights. The year confirmed that VISUMO''s greatest strength is not only its proximity to communities, but the trust it has built among women who are often ignored by formal systems.'),
  (3, 2, 'The organisation''s work is shaped by the realities of Beni and surrounding displacement-affected communities, including Oicha, Mavivi, Mbau and Eringeti. In these areas, conflict and economic hardship increase exposure to sexual violence, unwanted pregnancy, unsafe abortion, untreated post-rape complications, HIV vulnerability, stigma and delayed access to care. Women and adolescent girls with disabilities face an even higher risk because communication, transport, confidentiality and referral systems often exclude them.'),
  (3, 3, 'In response, VISUMO consolidated a model that combines community listening, safe referral orientation, psychosocial first aid, disability inclusion, HIV and SRHR information, local accountability dialogues and advocacy with health and protection actors. VISUMO is preparing to scale the Inclusive Safety and Abortion Care Desk (ISACAD), a disability-led advocacy model focused on safe information, referrals and accountability for GBV survivors'' abortion and post-abortion care where legally permitted.'),
  (5, 1, 'VISUMO operates in a fragile and conflict-affected environment. In North Kivu, the daily lives of women and girls are shaped by insecurity, displacement, disrupted livelihoods, family separation, stigma and limited access to confidential health and protection services. Rural communities and indigenous/autochthonous women often face additional exclusion from decision-making, service information and public accountability mechanisms.'),
  (5, 2, 'Beni and surrounding communities are especially important to VISUMO''s future work because they combine multiple vulnerabilities: displacement, poverty, sexual violence, HIV risk, unwanted pregnancy, disability exclusion and weak referral pathways. Survivors may know that care exists but still fail to reach it because they lack transport, fear stigma, cannot communicate safely with providers, or face costs and judgment at the service point.'),
  (5, 3, 'In this context, VISUMO''s approach is practical. The organisation does not present itself as a parallel clinic. It works as a community-based bridge between survivors and the systems responsible for protecting them: health facilities, psychosocial workers, legal aid, police/protection actors, community leaders, women''s groups and local authorities.'),
  (6, 1, 'VISUMO''s theory of change is simple and grounded in lived experience: when women and girls who survived violence are organised, informed, protected and listened to, they can move from silence to leadership, and local systems can be pushed to treat them as rights holders rather than cases to hide.'),
  (7, 1, 'VISUMO''s outreach model prioritises safe conversations close to where women live: host-family areas, churches, markets, women''s groups, informal displacement sites, rural villages and community gatherings. This approach recognises that survivors often cannot come first to an office. The organisation therefore brings information to community spaces in ways that reduce shame and avoid exposing individual cases.'),
  (7, 2, 'In 2025, VISUMO strengthened messaging around SRHR as a human right. Community members were oriented on the value of early post-rape care, respectful treatment, HIV awareness and testing, family planning options, safe pregnancy support, confidentiality and referral pathways. Community materials use short, practical language, combining English for donors with French and Kiswahili for community visibility.'),
  (8, 1, 'VISUMO''s most distinctive contribution is the commitment to make disabled survivors visible in GBV and SRHR advocacy. Women and girls with disabilities often experience violence and pregnancy-related risks while being excluded from information and complaint systems. A Deaf survivor may not find a safe interpreter. A blind young mother may fail to reach a facility on time. A survivor with an intellectual disability may be hidden by relatives because of shame.'),
  (8, 2, 'The ISACAD model responds by placing women and adolescent girls with disabilities in leadership, not only as beneficiaries. Peer advocates will help shape messages, document barriers and bring evidence into dialogues with health centres, police, protection actors and local authorities. The model also promotes practical changes: disability focal points, sign-language support, accessible SRHR materials, safe referral protocols and respectful treatment.'),
  (9, 1, 'VISUMO''s legal identity and community mission include the rights and dignity of indigenous/autochthonous women and girls. In North Kivu, these communities can face overlapping exclusion: poverty, limited schooling, low representation in public forums, weak access to health information, displacement pressure and stigma when women report violence or pregnancy-related complications.'),
  (9, 2, 'VISUMO''s work is grounded in local dignity: women are not passive beneficiaries. They are mothers, youth leaders, survivors, peer supporters, indigenous/autochthonous community members, women with disabilities and community organisers. VISUMO''s outreach uses local meeting points and trusted women leaders to reach those who may not attend formal workshops.'),
  (10, 1, 'VISUMO uses community-friendly health wording so posters and outreach messages are understandable for women with limited literacy and for community members who do not work in health systems. Instead of using “ANC” alone, materials use clear language such as “Consultation prénatale”, “Grossesse en bonne santé”, or Kiswahili wording such as “Uzazi salama”.'),
  (11, 1, 'VISUMO''s work depends on cooperation with local actors because survivor safety cannot be carried by one organisation alone. The strongest referral pathway connects women''s groups, disability organisations, community volunteers, health centres, psychosocial workers, legal aid providers, police/protection actors, local authorities and responsible media.'),
  (11, 2, 'The goal is not only to refer survivors but to change the way services respond. Community scorecards, barrier forms and dialogue minutes can help VISUMO move from isolated complaints to evidence-based advocacy. If several peer advocates report the same barrier - costs, poor privacy, lack of sign-language support or judgemental treatment - VISUMO can present this evidence to service actors and seek practical commitments.'),
  (15, 1, 'VISUMO''s monitoring approach protects survivors while producing useful evidence for advocacy. Because the work includes GBV, abortion-related information, HIV stigma and disability exclusion, the organisation avoids collecting unnecessary personal details. Evidence focuses on barriers, referrals, commitments and community learning rather than names and stories that could expose survivors.'),
  (16, 1, 'VISUMO''s credibility depends on how safely it handles sensitive information. The organisation''s public communications never expose survivors to stigma, retaliation, family rejection or community gossip. Consent, confidentiality and dignity guide every photo, referral note, testimony and public communication.'),
  (17, 1, 'VISUMO works in a setting where good intentions are not enough. Programmes must be realistic about insecurity, stigma, weak transport, poverty, disability barriers, mistrust of authorities and the emotional weight carried by survivors. The 2025 learning agenda therefore focused on being close to communities while strengthening systems that donors and partners can trust.'),
  (18, 1, 'VISUMO''s next stage is to strengthen ISACAD as a practical, locally owned disability-led advocacy model. Sustainability will come from people, tools, commitments and systems that remain after individual grants end.');

INSERT INTO callouts (slug, section_number, heading, body, sort_order) VALUES
  ('identity-statement', 1, 'Identity statement', 'VISUMO is a local, survivor-led and community-rooted organisation. Its legitimacy comes from both legal registration and day-to-day trust with women, indigenous/autochthonous communities and survivors who are often excluded from formal systems.', 1),
  ('image-use-note', 16, 'Image-use note', 'VISUMO applies consent, confidentiality and survivor-safety principles to all photos and visual materials used in organisational communications, partner engagement and community accountability. Images are used only when they do not expose survivors, children or people with disabilities to stigma, retaliation or other protection risks.', 2),
  ('message-to-partners', 3, '2025 message to partners', 'VISUMO is locally rooted, legally recognised, financially traceable, survivor-led and ready to strengthen disability-inclusive SRHR advocacy in North Kivu.', 3),
  ('guiding-principle', 6, 'Guiding principle', 'No survivor is denied dignity because she is poor, displaced, indigenous, disabled, HIV-affected, pregnant from violence or afraid to speak publicly.', 4),
  ('dignity-messages', 9, 'Community dignity messages', 'French: «Femmes autochtones, femmes rurales, femmes en situation de handicap: vos droits, votre santé, votre dignité.»
Kiswahili: “Wanawake wa asili na wa vijijini: afya, haki na heshima.”', 5),
  ('communications-rule', 10, 'Communications rule', 'Every VISUMO poster answers three questions clearly: What is the service? Why does it matter? Where can a woman safely ask for guidance?', 6),
  ('protection-note', 12, 'Protection note', 'The testimonies below are anonymised and composite-style statements prepared for safe communication. VISUMO uses them only in non-identifying form unless written informed consent has been provided.', 7),
  ('learning-rhythm', 15, 'Learning rhythm', 'Quarterly reflection meetings with peer advocates review what is changing, what remains unsafe and which advocacy message needs adjustment.', 8),
  ('ethical-photography', 16, 'Ethical photography rule', 'VISUMO uses images publicly only when the people shown have consented, understand the purpose and are not placed at risk because of the topic or setting.', 9),
  ('sustainability-statement', 18, 'Sustainability statement', 'By strengthening peer advocates, accessible tools, local commitments and financial systems, VISUMO can continue survivor-led SRHR advocacy beyond a single funding cycle.', 10);

INSERT INTO locations (name, kind, sort_order) VALUES
  ('Beni', 'Town (primary operating base)', 1),
  ('Oicha', 'Displacement-affected community', 2),
  ('Mavivi', 'Displacement-affected community', 3),
  ('Mbau', 'Displacement-affected community', 4),
  ('Eringeti', 'Displacement-affected community', 5);

INSERT INTO organisation_profile (element, details, sort_order) VALUES
  ('Organisation name', 'Violence Survivors Mothers (VISUMO)', 1),
  ('Community identity', 'Survivor-led women''s organisation supporting women and girls affected by violence, displacement, trauma, disability exclusion and SRHR stigma', 2),
  ('Country and province', 'Democratic Republic of the Congo - North Kivu', 3),
  ('Primary operating geography', 'Beni town and displacement-affected communities around Beni, including Oicha, Mavivi, Mbau and Eringeti', 4),
  ('Core constituencies', 'GBV survivors, young mothers, women and adolescent girls with disabilities, indigenous/autochthonous women, rural women and displaced families', 5),
  ('Strategic focus', 'Dignity, safe referral orientation, disability-led SRHR advocacy, HIV awareness, family planning information, post-rape care pathways and post-abortion care advocacy', 6);

INSERT INTO dashboard_areas (area, position_text, sort_order) VALUES
  ('Survivor-led identity', 'VISUMO was created by and for women affected by violence, conflict, displacement and exclusion.', 1),
  ('Core geography', 'North Kivu, with operational focus around Beni town and displacement-affected communities including Oicha, Mavivi, Mbau and Eringeti.', 2),
  ('Core constituencies', 'Women and adolescent girls affected by GBV, disabled survivors, young mothers, displaced women, indigenous/autochthonous women and rural community members.', 3),
  ('SRHR focus', 'Post-rape care, emergency contraception information, family planning, HIV awareness, safe pregnancy, lawful abortion information where permitted, post-abortion care and confidential referrals.', 4),
  ('Advocacy model', 'Peer groups, community dialogues, accessible materials, local radio, health-facility dialogues, scorecards and commitments from service actors.', 5);

INSERT INTO theory_of_change (logic_level, model_text, sort_order) VALUES
  ('Problem', 'Conflict, displacement, disability exclusion and stigma prevent survivors from claiming safe SRHR information, post-rape care, HIV services, family planning, lawful abortion information where permitted and post-abortion care.', 1),
  ('Inputs', 'Survivor trust, peer advocates, disability inclusion skills, community volunteers, referral partners, health workers, local radio and accountability tools.', 2),
  ('Activities', 'Community dialogues, peer support groups, accessible information, referral orientation, service mapping, scorecards, facility dialogues and advocacy meetings.', 3),
  ('Outputs', 'Informed women, trained advocates, documented barriers, safer referrals, service commitments and reduced silence around SRHR and GBV.', 4),
  ('Outcome', 'Disabled survivors, indigenous/autochthonous women and rural women can speak, seek help and influence local SRHR and GBV systems with dignity.', 5);

INSERT INTO operational_assumptions (assumption, application, sort_order) VALUES
  ('Community trust', 'Use peer advocates and trusted women leaders rather than one-off public meetings.', 1),
  ('Safe access', 'Bring information closer to host-family areas, informal sites, churches, markets and rural villages.', 2),
  ('System change', 'Convert repeated survivor barriers into scorecards, facility dialogue points and written commitments.', 3);

INSERT INTO community_messages (message_type, lang, wording, sort_order) VALUES
  ('Kiswahili message', 'sw', 'Afya ya uzazi ni haki yako. Tafuta msaada mapema.', 1),
  ('French message', 'fr', 'Santé sexuelle et reproductive: information sûre, choix éclairé, accompagnement digne.', 2),
  ('Survivor-safe message', 'en', 'Speak when it is safe. VISUMO can guide you confidentially toward trusted services.', 3);

INSERT INTO disability_barriers (barrier, response, sort_order) VALUES
  ('No sign-language support', 'Build sign-language referral contacts and sensitise service actors.', 1),
  ('Inaccessible information', 'Use simple, visual, oral and community-based SRHR messages.', 2),
  ('Stigma and judgment', 'Promote provider commitments on dignity, privacy and survivor-safe care.', 3),
  ('Late referrals', 'Train peer advocates to guide women quickly toward trusted services.', 4);

INSERT INTO outreach_elements (element, practical_use, sort_order) VALUES
  ('Rural entry points', 'Markets, churches, host-family areas, women''s savings groups and community football gatherings.', 1),
  ('Trusted messengers', 'Indigenous/autochthonous women leaders, peer mothers, women with disabilities and community volunteers.', 2),
  ('Safe language', 'Short French and Kiswahili phrases that speak about health, dignity, rights and confidential guidance.', 3);

INSERT INTO terminology_guide (technical_term, better_wording, sort_order) VALUES
  ('ANC', 'Consultation prénatale / Uzazi salama / Safe pregnancy care', 1),
  ('HIV', 'Dépistage VIH / Jipime / Know your status', 2),
  ('SRHR', 'Santé sexuelle et reproductive / Afya ya uzazi na haki', 3),
  ('Family Planning', 'Planification familiale / Uzazi wa mpango / Choose safely, plan freely', 4),
  ('Post-rape care', 'Soins apres viol / Huduma baada ya ukatili / urgent confidential care', 5);

INSERT INTO stakeholders (stakeholder_group, contribution, sort_order) VALUES
  ('Health centres and Beni health zone', 'Confidential care, respectful treatment, post-rape care, family planning and post-abortion care where appropriate.', 1),
  ('Police and protection actors', 'Safe reporting, survivor protection and non-discriminatory treatment.', 2),
  ('Disability organisations', 'Accessibility advice, sign-language contacts and peer leadership.', 3),
  ('Women leaders and churches', 'Trusted community entry points and support for survivors who fear stigma.', 4),
  ('Local radio and journalists', 'Stigma reduction messages without exposing survivors'' identities.', 5);

INSERT INTO testimonies (lang, title, quote, anonymised, sort_order) VALUES
  ('sw', 'Kiswahili testimony - young mother from a rural area', 'Nilikuwa naogopa kwenda kituo cha afya kwa sababu nilifikiri watanihukumu. Baada ya mazungumzo ya VISUMO, nilielewa kwamba nina haki ya kupata huduma kwa heshima. Sasa najua wapi ninaweza kuuliza msaada bila kufichua maisha yangu kwa watu wote.', TRUE, 1),
  ('sw', 'Kiswahili testimony - woman with a disability', 'Mimi ni mama mwenye ulemavu. Zamani nilinyamaza kwa sababu hakuna mtu aliyenisaidia kueleza shida yangu. Kupitia VISUMO, niliona kwamba sisi pia tuna sauti. Tunahitaji huduma zilizo salama, lugha tunayoelewa, na watu wanaotuheshimu.', TRUE, 2),
  ('fr', 'Témoignage en français - survivante accompagnée', 'Avant, je pensais que la honte etait plus forte que mes droits. VISUMO m''a aidée à comprendre que je pouvais demander une orientation sûre, parler sans être exposée et être traitée comme une femme digne, pas comme un problème.', TRUE, 3),
  ('fr', 'Témoignage en français - femme autochtone', 'Dans notre communauté, les femmes autochtones sont rarement invitées à parler de santé et de droits. Avec VISUMO, nous avons appris que notre corps, notre sécurité et notre avenir comptent aussi. Nous voulons participer aux décisions qui nous concernent.', TRUE, 4);

INSERT INTO annual_income (report_year, amount_usd, basis, is_audited) VALUES
  (2021, '304317.36', 'Internal financial records, comparative trend figure', FALSE),
  (2022, '304517.36', 'Internal financial records, comparative trend figure', FALSE),
  (2023, '304647.36', 'Internal financial records, comparative trend figure', FALSE),
  (2024, '304797.36', 'Audited financial statements', TRUE),
  (2025, '349529.25', 'Audited financial statements', TRUE);

INSERT INTO income_sources (id, name, sort_order) VALUES
  (1, 'Donor grants and programme support', 1),
  (2, 'Community and survivor-support contributions', 2),
  (3, 'Training / partnership reimbursements', 3),
  (4, 'Other income and exchange differences', 4);

INSERT INTO income_source_amounts (source_id, report_year, amount_usd) VALUES
  (1, 2024, '276268.49'),
  (1, 2025, '319057.47'),
  (2, 2024, '19668.28'),
  (2, 2025, '18506.35'),
  (3, 2024, '6777.74'),
  (3, 2025, '10525.81'),
  (4, 2024, '2082.85'),
  (4, 2025, '1439.62');

INSERT INTO me_indicators (area, indicator, data_source, sort_order) VALUES
  ('Peer leadership', 'Number of women and girls with disabilities trained as peer advocates', 'Training registers, consent-safe attendance sheets', 1),
  ('Information and referrals', 'Number of women/survivors receiving safe information or referral orientation', 'Anonymous referral logs and peer feedback', 2),
  ('Service barriers', 'Types of barriers reported: fees, stigma, late referral, inaccessible communication', 'Barrier forms and quarterly analysis', 3),
  ('Accountability', 'Number of facility or authority commitments made and followed up', 'Dialogue minutes and commitment tracker', 4),
  ('Community learning', 'Changes in knowledge of post-rape care, family planning, HIV testing and survivor rights', 'Pre/post forms, focus groups and learning meetings', 5);

INSERT INTO safeguarding_risks (risk, action_taken, sort_order) VALUES
  ('Identifying survivors in public materials or images', 'Use anonymous or composite stories unless written informed consent exists. Avoid showing identifiable survivors in sensitive contexts.', 1),
  ('Community backlash around abortion-related information', 'Use rights-based, legally careful language and focus on safe information, referrals and post-abortion care.', 2),
  ('Data leaks from referral records', 'Limit access to staff with protection roles; use secure storage and coded referral logs.', 3),
  ('Exclusion of Deaf, blind or intellectually disabled women', 'Use accessible communication, trusted accompaniment and disability focal points.', 4),
  ('Tokenistic participation of indigenous women', 'Engage local women leaders and hold dialogues in community spaces and languages.', 5);

INSERT INTO challenges (challenge, mitigation, lesson, sort_order) VALUES
  ('Insecurity and displacement disrupt participation', 'Use flexible community meeting points and avoid requiring survivors to travel far.', 'Bring information closer to women and adapt schedules quickly.', 1),
  ('Stigma around SRHR, HIV and abortion care', 'Frame messages around dignity, safety, rights and confidential referral rather than public exposure.', 'Language matters; short French/Kiswahili messages work better than technical abbreviations.', 2),
  ('Disability exclusion remains normalized', 'Make women with disabilities peer advocates and evidence holders.', 'Inclusion must be led by disabled women, not only discussed by others.', 3),
  ('Small-team financial control pressures', 'Strengthen separation of approvals, payments, recording and review.', 'Donor confidence grows when systems improve alongside programmes.', 4),
  ('Survivor stories can create risk', 'Use composite testimonies and obtain consent before public images or quotes.', 'Protection is part of good communication.', 5);

INSERT INTO priorities_2026 (sort_order, priority) VALUES
  (1, 'Maintain and mentor Disability SRHR Advocacy Peer Groups in Beni, Oicha, Mavivi, Mbau and Eringeti.'),
  (2, 'Train women and adolescent girls with disabilities as peer advocates and prepare selected advocates as trainers.'),
  (3, 'Strengthen referral protocols with health centres, psychosocial workers, legal aid providers, police/protection actors and disability organisations.'),
  (4, 'Develop accessible French/Kiswahili SRHR materials on post-rape care, family planning, HIV testing, safe pregnancy and post-abortion care.'),
  (5, 'Use scorecards and commitment trackers to secure practical changes from service providers and authorities.'),
  (6, 'Strengthen safeguarding, data protection, monitoring and fundraising systems.');

INSERT INTO project_design_figures (figure_value, label, detail, is_approximate, sort_order) VALUES
  (5, 'priority locations', 'Beni, Oicha, Mavivi, Mbau, Eringeti', FALSE, 1),
  (35, 'peer advocates', 'Women and girls with disabilities', FALSE, 2),
  (10, 'trainers', 'Selected advocates prepared as trainers', FALSE, 3),
  (700, 'women / survivors', 'Targeted for safe information and referrals', TRUE, 4),
  (30, 'months', 'ISACAD design period', FALSE, 5);

INSERT INTO site_settings (setting_key, setting_value) VALUES
  ('site_name', 'VISUMO'),
  ('org_full_name', 'Violence Survivors Mothers'),
  ('tagline', 'Survivor-led dignity, disability inclusion and SRHR accountability in North Kivu, Democratic Republic of the Congo'),
  ('hero_headline', 'From silence to dignity. From exclusion to voice.'),
  ('footer_note', 'Violence Survivors Mothers (VISUMO) | North Kivu, DRC'),
  ('sw_motto', 'Tuko pamoja, tutavunja ukimya!');

INSERT INTO site_images (filename, section_number, caption, alt_text, sort_order) VALUES
  ('hero-community.jpg', NULL, 'VISUMO community visual identity: SRHR information, disability inclusion, safe referrals and rural outreach.', 'Collage of VISUMO community activities: outreach, disability-inclusive sport, prenatal care, HIV testing, family planning and a safe space for survivors', 1),
  ('dashboard.png', 4, 'Strategic programme figures drawn from VISUMO''s ISACAD scale-up design and 2025 organisational positioning.', 'Four tiles: 5 priority locations, 35 peer advocates, 700 women and survivors, 10 local commitments', 2),
  ('community-solidarity.jpg', 5, 'Community prayer and solidarity around a sports field: a visual reminder that local mobilisation often begins where communities gather naturally.', 'Community members in VISUMO t-shirts gathered together', 3),
  ('srhr-education.jpg', 7, 'Community SRHR education in a rural setting: VISUMO messaging uses simple language and local trust points.', 'Women attending a community SRHR education session', 4),
  ('disability-inclusion.jpg', 8, 'Inclusive training visual: disability inclusion is central to VISUMO''s SRHR advocacy model.', 'Facilitator leading a training with participants who use wheelchairs', 5),
  ('rural-awareness.jpg', 9, 'Community health awareness visual with women and girls from rural areas of eastern DRC.', 'Women and girls from rural eastern DRC at a health awareness session', 6),
  ('safe-pregnancy.jpg', 10, 'Safe pregnancy and prenatal care: community materials use understandable French and Kiswahili wording rather than unexplained abbreviations.', 'Mother holding her baby beside a poster on prenatal consultations in French and Kiswahili', 7),
  ('peer-leadership.jpg', 18, 'Inclusive skills and peer leadership visual: VISUMO''s sustainability depends on trained community advocates and practical local commitments.', 'Peer advocates practising inclusive skills together', 8);

COMMIT;
