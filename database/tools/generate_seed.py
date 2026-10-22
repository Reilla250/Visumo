#!/usr/bin/env python3
"""
Generates the seed data for the VISUMO website database from the content of the
VISUMO Annual Narrative Report 2025.

Outputs (relative to the database/ folder):
  postgres/seed.sql, postgres/visumo_postgres_full.sql
  mysql/seed.sql,    mysql/visumo_mysql_full.sql

Run:  python3 database/tools/generate_seed.py
Edit the CONTENT below, re-run, and re-import to change website text.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def q(v):
    """SQL literal that is valid in both PostgreSQL and MySQL."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


# ----------------------------------------------------------------------------
# CONTENT
# ----------------------------------------------------------------------------
SECTIONS = [
    (1, "identity", "Organisational identity and profile", True),
    (2, "contents", "Contents and evidence basis", True),
    (3, "executive-summary", "Executive summary", True),
    (4, "dashboard", "2025 strategic dashboard", True),
    (5, "context", "Operating context in North Kivu", True),
    (6, "theory-of-change", "Theory of change and programme model", True),
    (7, "outreach", "Community outreach, SRHR information and safe referrals", True),
    (8, "disability-inclusion", "Disability inclusion and survivor leadership", True),
    (9, "indigenous-rural", "Indigenous/autochthonous women and rural community engagement", True),
    (10, "health-communication", "Health communication: HIV, family planning, safe pregnancy and post-rape care", True),
    (11, "partnerships", "Partnerships and local accountability", True),
    (12, "voices", "Beneficiary voices: Kiswahili and French testimonies", True),
    (13, "income-analysis", "Annual income analysis, 2021-2025", True),
    (14, "income-sources", "Income sources and financial resilience", True),
    (15, "monitoring-learning", "Monitoring, evaluation, accountability and learning", True),
    (16, "safeguarding", "Safeguarding, ethics and survivor-safe documentation", True),
    (17, "challenges", "Challenges, mitigation and lessons learned", True),
    (18, "priorities-2026", "2026 priorities and sustainability plan", True),
    (19, "annex", "Annex: evidence sources and document control", True),
    (20, "closing-commitment", "Closing commitment", False),
    (21, "approval", "Approval and certification", False),
]

PARAGRAPHS = {
    1: [
        "Registered in the Democratic Republic of the Congo and rooted in North Kivu community realities.",
        "Formal legal evidence can be supplied separately as a due-diligence document when requested by donors, authorities or partners. This narrative report keeps the main body focused on identity, results, learning, community accountability and programme readiness.",
    ],
    3: [
        "VISUMO entered 2025 with a clear identity: a survivor-led civil society organisation in North Kivu that stands beside women and girls affected by violence, displacement, trauma, HIV-related stigma, disability exclusion and barriers to sexual and reproductive health and rights. The year confirmed that VISUMO's greatest strength is not only its proximity to communities, but the trust it has built among women who are often ignored by formal systems.",
        "The organisation's work is shaped by the realities of Beni and surrounding displacement-affected communities, including Oicha, Mavivi, Mbau and Eringeti. In these areas, conflict and economic hardship increase exposure to sexual violence, unwanted pregnancy, unsafe abortion, untreated post-rape complications, HIV vulnerability, stigma and delayed access to care. Women and adolescent girls with disabilities face an even higher risk because communication, transport, confidentiality and referral systems often exclude them.",
        "In response, VISUMO consolidated a model that combines community listening, safe referral orientation, psychosocial first aid, disability inclusion, HIV and SRHR information, local accountability dialogues and advocacy with health and protection actors. The report also presents VISUMO's readiness to scale the Inclusive Safety and Abortion Care Desk (ISACAD), a disability-led advocacy model focused on safe information, referrals and accountability for GBV survivors' abortion and post-abortion care where legally permitted.",
        "Financially, the report presents an income-focused view of VISUMO's organisational growth. VISUMO's audited income increased from USD 304,797.36 in 2024 to USD 349,529.25 in 2025, showing improved capacity to mobilise and manage resources. The five-year income presentation uses exact USD values and avoids rounded figures ending in 000 for donor-facing transparency.",
    ],
    5: [
        "VISUMO operates in a fragile and conflict-affected environment. In North Kivu, the daily lives of women and girls are shaped by insecurity, displacement, disrupted livelihoods, family separation, stigma and limited access to confidential health and protection services. Rural communities and indigenous/autochthonous women often face additional exclusion from decision-making, service information and public accountability mechanisms.",
        "Beni and surrounding communities are especially important to VISUMO's future work because they combine multiple vulnerabilities: displacement, poverty, sexual violence, HIV risk, unwanted pregnancy, disability exclusion and weak referral pathways. Survivors may know that care exists but still fail to reach it because they lack transport, fear stigma, cannot communicate safely with providers, or face costs and judgment at the service point.",
        "In this context, VISUMO's approach is practical. The organisation does not present itself as a parallel clinic. It works as a community-based bridge between survivors and the systems responsible for protecting them: health facilities, psychosocial workers, legal aid, police/protection actors, community leaders, women's groups and local authorities.",
    ],
    6: [
        "VISUMO's theory of change is simple and grounded in lived experience: when women and girls who survived violence are organised, informed, protected and listened to, they can move from silence to leadership, and local systems can be pushed to treat them as rights holders rather than cases to hide.",
    ],
    7: [
        "VISUMO's outreach model prioritises safe conversations close to where women live: host-family areas, churches, markets, women's groups, informal displacement sites, rural villages and community gatherings. This approach recognises that survivors often cannot come first to an office. The organisation therefore brings information to community spaces in ways that reduce shame and avoid exposing individual cases.",
        "In 2025, VISUMO strengthened messaging around SRHR as a human right. Community members were oriented on the value of early post-rape care, respectful treatment, HIV awareness and testing, family planning options, safe pregnancy support, confidentiality and referral pathways. Community materials use short, practical language, combining English for donors with French and Kiswahili for community visibility.",
    ],
    8: [
        "VISUMO's most distinctive contribution is the commitment to make disabled survivors visible in GBV and SRHR advocacy. Women and girls with disabilities often experience violence and pregnancy-related risks while being excluded from information and complaint systems. A Deaf survivor may not find a safe interpreter. A blind young mother may fail to reach a facility on time. A survivor with an intellectual disability may be hidden by relatives because of shame.",
        "The ISACAD model responds by placing women and adolescent girls with disabilities in leadership, not only as beneficiaries. Peer advocates will help shape messages, document barriers and bring evidence into dialogues with health centres, police, protection actors and local authorities. The model also promotes practical changes: disability focal points, sign-language support, accessible SRHR materials, safe referral protocols and respectful treatment.",
    ],
    9: [
        "VISUMO's legal identity and community mission include the rights and dignity of indigenous/autochthonous women and girls. In North Kivu, these communities can face overlapping exclusion: poverty, limited schooling, low representation in public forums, weak access to health information, displacement pressure and stigma when women report violence or pregnancy-related complications.",
        "For this reason, VISUMO's report uses the language of local dignity: women are not passive beneficiaries. They are mothers, youth leaders, survivors, peer supporters, indigenous/autochthonous community members, women with disabilities and community organisers. VISUMO's outreach uses local meeting points and trusted women leaders to reach those who may not attend formal workshops.",
    ],
    10: [
        "VISUMO uses community-friendly health wording so posters and outreach messages are understandable for women with limited literacy and for community members who do not work in health systems. Instead of using “ANC” alone, materials use clear language such as “Consultation prénatale”, “Grossesse en bonne santé”, or Kiswahili wording such as “Uzazi salama”.",
    ],
    11: [
        "VISUMO's work depends on cooperation with local actors because survivor safety cannot be carried by one organisation alone. The strongest referral pathway connects women's groups, disability organisations, community volunteers, health centres, psychosocial workers, legal aid providers, police/protection actors, local authorities and responsible media.",
        "The goal is not only to refer survivors but to change the way services respond. Community scorecards, barrier forms and dialogue minutes can help VISUMO move from isolated complaints to evidence-based advocacy. If several peer advocates report the same barrier - costs, poor privacy, lack of sign-language support or judgemental treatment - VISUMO can present this evidence to service actors and seek practical commitments.",
    ],
    13: [
        "The five-year income line gives partners a clearer view of VISUMO's resource mobilisation trajectory. The strongest audited increase is visible from 2024 to 2025, where income rose by USD 44,731.89. This growth supports the case that VISUMO is moving toward stronger donor readiness, more structured financial reporting and increased capacity to manage SRHR and disability inclusion programmes.",
    ],
    14: [
        "The income profile shows that donor grants and programme support remain the largest financing source. However, community and survivor-support contributions, training reimbursements and partnership reimbursements show that VISUMO has multiple forms of support. The organisation continues to diversify income while protecting its survivor-led identity and avoiding funding that weakens confidentiality or community trust.",
    ],
    15: [
        "VISUMO's monitoring approach protects survivors while producing useful evidence for advocacy. Because the work includes GBV, abortion-related information, HIV stigma and disability exclusion, the organisation avoids collecting unnecessary personal details. Evidence focuses on barriers, referrals, commitments and community learning rather than names and stories that could expose survivors.",
    ],
    16: [
        "VISUMO's credibility depends on how safely it handles sensitive information. The organisation's reporting never exposes survivors to stigma, retaliation, family rejection or community gossip. Consent, confidentiality and dignity guide every photo, referral note, testimony and public communication.",
    ],
    17: [
        "VISUMO works in a setting where good intentions are not enough. Programmes must be realistic about insecurity, stigma, weak transport, poverty, disability barriers, mistrust of authorities and the emotional weight carried by survivors. The 2025 learning agenda therefore focused on being close to communities while strengthening systems that donors and partners can trust.",
    ],
    18: [
        "VISUMO's next stage is to strengthen ISACAD as a practical, locally owned disability-led advocacy model. Sustainability will come from people, tools, commitments and systems that remain after individual grants end.",
    ],
    19: [
        "Evidence summary: the report uses exact USD income amounts, bilingual Kiswahili and French testimonies, local indigenous/autochthonous community framing, graphics, tables and a visual dashboard. It also reflects VISUMO's DRC/North Kivu identity and applies survivor-safe reporting and ethical image-use principles.",
    ],
    20: [
        "VISUMO closes this report with a commitment to keep women and girls at the centre of its work: survivors, indigenous/autochthonous women, rural women, women living with disabilities, young mothers and displaced families. The organisation will continue to use community trust, safe referral orientation, rights-based SRHR information, disability inclusion and local accountability to move women from silence to dignity and from exclusion to voice.",
    ],
    21: [
        "This Annual Narrative Report for the period January–December 2025 has been prepared by Violence Survivors Mothers (VISUMO) to present the organisation's work, learning, accountability, community engagement and financial position for the reporting year.",
        "We confirm that the information presented in this report reflects VISUMO's programme activities, organisational learning, community accountability practices and financial records for 2025. The report has been reviewed and approved for sharing with partners, donors, authorities and other stakeholders.",
    ],
}

# (slug, section, heading, body)
CALLOUTS = [
    ("report-focus", None, "Report focus",
     "This report presents VISUMO as a survivor-led, locally rooted organisation working with women and girls affected by violence, displacement, disability exclusion and SRHR stigma in North Kivu. It provides annual income information for 2021-2025 in exact USD amounts and presents programme identity, accountability, learning and readiness for continued SRHR advocacy."),
    ("identity-statement", 1, "Identity statement",
     "VISUMO is positioned in this report as a local, survivor-led and community-rooted organisation. Its legitimacy comes from both legal registration and day-to-day trust with women, indigenous/autochthonous communities and survivors who are often excluded from formal systems."),
    ("evidence-note", 2, "Evidence note",
     "Audited 2024 and 2025 income figures are drawn from VISUMO UBT audited financial statements. The 2021-2023 comparative figures are drawn from internal financial records for trend context and are presented in exact USD, not rounded thousands."),
    ("image-use-note", 2, "Image-use note",
     "VISUMO applies consent, confidentiality and survivor-safety principles to all photos and visual materials used for organisational reporting, partner communication and community accountability. Images are used only when they do not expose survivors, children or people with disabilities to stigma, retaliation or other protection risks."),
    ("message-to-partners", 3, "2025 message to partners",
     "VISUMO is locally rooted, legally recognised, financially traceable, survivor-led and ready to strengthen disability-inclusive SRHR advocacy in North Kivu."),
    ("report-focus-2025", 4, "2025 report focus",
     "The report presents VISUMO's 2021-2025 income trend, bilingual beneficiary testimonies, indigenous/community framing, ethics language, donor-facing tables and graphics, and the organisation's readiness to strengthen disability-inclusive SRHR accountability in North Kivu."),
    ("guiding-principle", 6, "Guiding principle",
     "No survivor is denied dignity because she is poor, displaced, indigenous, disabled, HIV-affected, pregnant from violence or afraid to speak publicly."),
    ("dignity-messages", 9, "Community dignity messages",
     "French: «Femmes autochtones, femmes rurales, femmes en situation de handicap: vos droits, votre santé, votre dignité.»\nKiswahili: “Wanawake wa asili na wa vijijini: afya, haki na heshima.”"),
    ("communications-rule", 10, "Communications rule",
     "Every VISUMO poster answers three questions clearly: What is the service? Why does it matter? Where can a woman safely ask for guidance?"),
    ("protection-note", 12, "Protection note",
     "The testimonies below are anonymised and composite-style statements prepared for safe reporting. VISUMO uses them only in non-identifying form unless written informed consent has been provided."),
    ("financial-message", 14, "Financial message",
     "VISUMO presents financial information in exact USD amounts, not rounded thousands, to show transparency and donor-facing precision."),
    ("learning-rhythm", 15, "Learning rhythm",
     "Quarterly reflection meetings with peer advocates review what is changing, what remains unsafe and which advocacy message needs adjustment."),
    ("ethical-photography", 16, "Ethical photography rule",
     "VISUMO uses images publicly only when the people shown have consented, understand the purpose and are not placed at risk because of the topic or setting."),
    ("sustainability-statement", 18, "Sustainability statement",
     "By strengthening peer advocates, accessible tools, local commitments and financial systems, VISUMO can continue survivor-led SRHR advocacy beyond a single funding cycle."),
    ("quality-assurance", 19, "Quality assurance note",
     "This report has been checked for consistency of DRC/North Kivu positioning, financial figures, disability inclusion, indigenous/autochthonous framing, ethics language and visual presentation. VISUMO will continue validating annual M&E results through its internal monitoring and accountability system."),
    ("external-sharing", 19, "External sharing note",
     "This report may be shared with donors, partners, community stakeholders and VISUMO governance bodies together with relevant registration, programme and audited financial documents when requested."),
]

LOCATIONS = [
    ("Beni", "Town (primary operating base)"),
    ("Oicha", "Displacement-affected community"),
    ("Mavivi", "Displacement-affected community"),
    ("Mbau", "Displacement-affected community"),
    ("Eringeti", "Displacement-affected community"),
]

PROFILE = [
    ("Organisation name used in this report", "Violence Survivors Mothers (VISUMO)"),
    ("Community identity", "Survivor-led women's organisation supporting women and girls affected by violence, displacement, trauma, disability exclusion and SRHR stigma"),
    ("Country and province", "Democratic Republic of the Congo - North Kivu"),
    ("Primary operating geography", "Beni town and displacement-affected communities around Beni, including Oicha, Mavivi, Mbau and Eringeti"),
    ("Core constituencies", "GBV survivors, young mothers, women and adolescent girls with disabilities, indigenous/autochthonous women, rural women and displaced families"),
    ("Strategic focus", "Dignity, safe referral orientation, disability-led SRHR advocacy, HIV awareness, family planning information, post-rape care pathways and post-abortion care advocacy"),
]

DASHBOARD = [
    ("Survivor-led identity", "VISUMO was created by and for women affected by violence, conflict, displacement and exclusion."),
    ("Core geography", "North Kivu, with operational focus around Beni town and displacement-affected communities including Oicha, Mavivi, Mbau and Eringeti."),
    ("Core constituencies", "Women and adolescent girls affected by GBV, disabled survivors, young mothers, displaced women, indigenous/autochthonous women and rural community members."),
    ("SRHR focus", "Post-rape care, emergency contraception information, family planning, HIV awareness, safe pregnancy, lawful abortion information where permitted, post-abortion care and confidential referrals."),
    ("Advocacy model", "Peer groups, community dialogues, accessible materials, local radio, health-facility dialogues, scorecards and commitments from service actors."),
]

THEORY = [
    ("Problem", "Conflict, displacement, disability exclusion and stigma prevent survivors from claiming safe SRHR information, post-rape care, HIV services, family planning, lawful abortion information where permitted and post-abortion care."),
    ("Inputs", "Survivor trust, peer advocates, disability inclusion skills, community volunteers, referral partners, health workers, local radio and accountability tools."),
    ("Activities", "Community dialogues, peer support groups, accessible information, referral orientation, service mapping, scorecards, facility dialogues and advocacy meetings."),
    ("Outputs", "Informed women, trained advocates, documented barriers, safer referrals, service commitments and reduced silence around SRHR and GBV."),
    ("Outcome", "Disabled survivors, indigenous/autochthonous women and rural women can speak, seek help and influence local SRHR and GBV systems with dignity."),
]

ASSUMPTIONS = [
    ("Community trust", "Use peer advocates and trusted women leaders rather than one-off public meetings."),
    ("Safe access", "Bring information closer to host-family areas, informal sites, churches, markets and rural villages."),
    ("System change", "Convert repeated survivor barriers into scorecards, facility dialogue points and written commitments."),
]

MESSAGES = [
    ("Kiswahili message", "sw", "Afya ya uzazi ni haki yako. Tafuta msaada mapema."),
    ("French message", "fr", "Santé sexuelle et reproductive: information sûre, choix éclairé, accompagnement digne."),
    ("Survivor-safe message", "en", "Speak when it is safe. VISUMO can guide you confidentially toward trusted services."),
]

BARRIERS = [
    ("No sign-language support", "Build sign-language referral contacts and sensitise service actors."),
    ("Inaccessible information", "Use simple, visual, oral and community-based SRHR messages."),
    ("Stigma and judgment", "Promote provider commitments on dignity, privacy and survivor-safe care."),
    ("Late referrals", "Train peer advocates to guide women quickly toward trusted services."),
]

OUTREACH = [
    ("Rural entry points", "Markets, churches, host-family areas, women's savings groups and community football gatherings."),
    ("Trusted messengers", "Indigenous/autochthonous women leaders, peer mothers, women with disabilities and community volunteers."),
    ("Safe language", "Short French and Kiswahili phrases that speak about health, dignity, rights and confidential guidance."),
]

TERMS = [
    ("ANC", "Consultation prénatale / Uzazi salama / Safe pregnancy care"),
    ("HIV", "Dépistage VIH / Jipime / Know your status"),
    ("SRHR", "Santé sexuelle et reproductive / Afya ya uzazi na haki"),
    ("Family Planning", "Planification familiale / Uzazi wa mpango / Choose safely, plan freely"),
    ("Post-rape care", "Soins apres viol / Huduma baada ya ukatili / urgent confidential care"),
]

STAKEHOLDERS = [
    ("Health centres and Beni health zone", "Confidential care, respectful treatment, post-rape care, family planning and post-abortion care where appropriate."),
    ("Police and protection actors", "Safe reporting, survivor protection and non-discriminatory treatment."),
    ("Disability organisations", "Accessibility advice, sign-language contacts and peer leadership."),
    ("Women leaders and churches", "Trusted community entry points and support for survivors who fear stigma."),
    ("Local radio and journalists", "Stigma reduction messages without exposing survivors' identities."),
]

TESTIMONIES = [
    ("sw", "Kiswahili testimony - young mother from a rural area",
     "Nilikuwa naogopa kwenda kituo cha afya kwa sababu nilifikiri watanihukumu. Baada ya mazungumzo ya VISUMO, nilielewa kwamba nina haki ya kupata huduma kwa heshima. Sasa najua wapi ninaweza kuuliza msaada bila kufichua maisha yangu kwa watu wote."),
    ("sw", "Kiswahili testimony - woman with a disability",
     "Mimi ni mama mwenye ulemavu. Zamani nilinyamaza kwa sababu hakuna mtu aliyenisaidia kueleza shida yangu. Kupitia VISUMO, niliona kwamba sisi pia tuna sauti. Tunahitaji huduma zilizo salama, lugha tunayoelewa, na watu wanaotuheshimu."),
    ("fr", "Témoignage en français - survivante accompagnée",
     "Avant, je pensais que la honte etait plus forte que mes droits. VISUMO m'a aidée à comprendre que je pouvais demander une orientation sûre, parler sans être exposée et être traitée comme une femme digne, pas comme un problème."),
    ("fr", "Témoignage en français - femme autochtone",
     "Dans notre communauté, les femmes autochtones sont rarement invitées à parler de santé et de droits. Avec VISUMO, nous avons appris que notre corps, notre sécurité et notre avenir comptent aussi. Nous voulons participer aux décisions qui nous concernent."),
]

INCOME = [
    (2021, "304317.36", "Internal financial records, comparative trend figure", False),
    (2022, "304517.36", "Internal financial records, comparative trend figure", False),
    (2023, "304647.36", "Internal financial records, comparative trend figure", False),
    (2024, "304797.36", "Audited financial statements", True),
    (2025, "349529.25", "Audited financial statements", True),
]

SOURCES = [
    (1, "Donor grants and programme support", "276268.49", "319057.47"),
    (2, "Community and survivor-support contributions", "19668.28", "18506.35"),
    (3, "Training / partnership reimbursements", "6777.74", "10525.81"),
    (4, "Other income and exchange differences", "2082.85", "1439.62"),
]

ME = [
    ("Peer leadership", "Number of women and girls with disabilities trained as peer advocates", "Training registers, consent-safe attendance sheets"),
    ("Information and referrals", "Number of women/survivors receiving safe information or referral orientation", "Anonymous referral logs and peer reports"),
    ("Service barriers", "Types of barriers reported: fees, stigma, late referral, inaccessible communication", "Barrier forms and quarterly analysis"),
    ("Accountability", "Number of facility or authority commitments made and followed up", "Dialogue minutes and commitment tracker"),
    ("Community learning", "Changes in knowledge of post-rape care, family planning, HIV testing and survivor rights", "Pre/post forms, focus groups and learning meetings"),
]

RISKS = [
    ("Identifying survivors in reports or images", "Use anonymous or composite stories unless written informed consent exists. Avoid showing identifiable survivors in sensitive contexts."),
    ("Community backlash around abortion-related information", "Use rights-based, legally careful language and focus on safe information, referrals and post-abortion care."),
    ("Data leaks from referral records", "Limit access to staff with protection roles; use secure storage and coded referral logs."),
    ("Exclusion of Deaf, blind or intellectually disabled women", "Use accessible communication, trusted accompaniment and disability focal points."),
    ("Tokenistic participation of indigenous women", "Engage local women leaders and hold dialogues in community spaces and languages."),
]

CHALLENGES = [
    ("Insecurity and displacement disrupt participation", "Use flexible community meeting points and avoid requiring survivors to travel far.", "Bring information closer to women and adapt schedules quickly."),
    ("Stigma around SRHR, HIV and abortion care", "Frame messages around dignity, safety, rights and confidential referral rather than public exposure.", "Language matters; short French/Kiswahili messages work better than technical abbreviations."),
    ("Disability exclusion remains normalized", "Make women with disabilities peer advocates and evidence holders.", "Inclusion must be led by disabled women, not only discussed by others."),
    ("Small-team financial control pressures", "Strengthen separation of approvals, payments, recording and review.", "Donor confidence grows when systems improve alongside programmes."),
    ("Survivor stories can create risk", "Use composite testimonies and obtain consent before public images or quotes.", "Protection is part of quality reporting."),
]

PRIORITIES = [
    "Maintain and mentor Disability SRHR Advocacy Peer Groups in Beni, Oicha, Mavivi, Mbau and Eringeti.",
    "Train women and adolescent girls with disabilities as peer advocates and prepare selected advocates as trainers.",
    "Strengthen referral protocols with health centres, psychosocial workers, legal aid providers, police/protection actors and disability organisations.",
    "Develop accessible French/Kiswahili SRHR materials on post-rape care, family planning, HIV testing, safe pregnancy and post-abortion care.",
    "Use scorecards and commitment trackers to secure practical changes from service providers and authorities.",
    "Strengthen safeguarding, data protection, financial management, reporting and fundraising systems.",
]

EVIDENCE = [
    ("2024 audited income", "USD 304,797.36, from UBT audited financial statements for year ended 31 December 2024."),
    ("2025 audited income", "USD 349,529.25, from UBT audited financial statements for year ended 31 December 2025."),
    ("2023 comparative income", "USD 304,647.36, from internal financial records for trend analysis."),
    ("2022 comparative income", "USD 304,517.36, from internal financial records for trend analysis."),
    ("2021 comparative income", "USD 304,317.36, from internal financial records for trend analysis."),
    ("Project design figures", "ISACAD design: 30 months, 5 priority locations, 35 peer advocates, 10 trainers, about 700 survivors/women targeted for safe information and referrals."),
]

# (value, label, detail, approximate)
FIGURES = [
    (5, "priority locations", "Beni, Oicha, Mavivi, Mbau, Eringeti", False),
    (35, "peer advocates", "Women and girls with disabilities", False),
    (10, "trainers", "Selected advocates prepared as trainers", False),
    (700, "women / survivors", "Targeted for safe information and referrals", True),
    (30, "months", "ISACAD design period", False),
]

DOC_CONTROL = [
    ("Prepared for", "Donors, partners, community stakeholders and VISUMO governance bodies"),
    ("Reporting year", "2025"),
    ("Reporting period", "January-December 2025"),
    ("Primary location", "North Kivu, Democratic Republic of the Congo"),
    ("Report status", "Final organisational report for partner and donor due diligence"),
    ("Authorised representative", "MAOMBI Sarah"),
    ("Position", "Executive Director"),
    ("Date of approval", "14/02/2026"),
]

SETTINGS = [
    ("site_name", "VISUMO"),
    ("org_full_name", "Violence Survivors Mothers"),
    ("tagline", "Survivor-led dignity, disability inclusion and SRHR accountability in North Kivu, Democratic Republic of the Congo"),
    ("hero_headline", "From silence to dignity. From exclusion to voice."),
    ("reporting_period", "January-December 2025"),
    ("footer_note", "Violence Survivors Mothers (VISUMO) | North Kivu, DRC"),
    ("sw_motto", "Tuko pamoja, tutavunja ukimya!"),
]

# (filename, section, caption, alt)
IMAGES = [
    ("hero-community.jpg", None, "VISUMO community visual identity: SRHR information, disability inclusion, safe referrals and rural outreach.",
     "Collage of VISUMO community activities: outreach, disability-inclusive sport, prenatal care, HIV testing, family planning and a safe space for survivors"),
    ("dashboard.png", 4, "Strategic programme figures drawn from VISUMO's ISACAD scale-up design and 2025 organisational positioning.",
     "Four tiles: 5 priority locations, 35 peer advocates, 700 women and survivors, 10 local commitments"),
    ("community-solidarity.jpg", 5, "Community prayer and solidarity around a sports field: a visual reminder that local mobilisation often begins where communities gather naturally.",
     "Community members in VISUMO t-shirts gathered together"),
    ("srhr-education.jpg", 7, "Community SRHR education in a rural setting: VISUMO messaging uses simple language and local trust points.",
     "Women attending a community SRHR education session"),
    ("disability-inclusion.jpg", 8, "Inclusive training visual: disability inclusion is central to VISUMO's SRHR advocacy model.",
     "Facilitator leading a training with participants who use wheelchairs"),
    ("rural-awareness.jpg", 9, "Community health awareness visual with women and girls from rural areas of eastern DRC.",
     "Women and girls from rural eastern DRC at a health awareness session"),
    ("safe-pregnancy.jpg", 10, "Safe pregnancy and prenatal care: community materials use understandable French and Kiswahili wording rather than unexplained abbreviations.",
     "Mother holding her baby beside a poster on prenatal consultations in French and Kiswahili"),
    ("peer-leadership.jpg", 18, "Inclusive skills and peer leadership visual: VISUMO's sustainability depends on trained community advocates and practical local commitments.",
     "Peer advocates practising inclusive skills together"),
]

# ----------------------------------------------------------------------------
# SQL generation
# ----------------------------------------------------------------------------

def insert(table, cols, rows):
    if not rows:
        return ""
    head = f"INSERT INTO {table} ({', '.join(cols)}) VALUES\n"
    body = ",\n".join("  (" + ", ".join(q(v) for v in r) + ")" for r in rows)
    return head + body + ";\n\n"


def build_body():
    out = []
    out.append(insert("report_sections", ["section_number", "slug", "title", "listed_in_contents"], SECTIONS))
    rows = []
    for n in sorted(PARAGRAPHS):
        for i, p in enumerate(PARAGRAPHS[n], 1):
            rows.append((n, i, p))
    out.append(insert("section_paragraphs", ["section_number", "sort_order", "body"], rows))
    out.append(insert("callouts", ["slug", "section_number", "heading", "body", "sort_order"],
                      [(s, n, h, b, i) for i, (s, n, h, b) in enumerate(CALLOUTS, 1)]))
    out.append(insert("locations", ["name", "kind", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(LOCATIONS, 1)]))
    out.append(insert("organisation_profile", ["element", "details", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(PROFILE, 1)]))
    out.append(insert("dashboard_areas", ["area", "position_text", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(DASHBOARD, 1)]))
    out.append(insert("theory_of_change", ["logic_level", "model_text", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(THEORY, 1)]))
    out.append(insert("operational_assumptions", ["assumption", "application", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(ASSUMPTIONS, 1)]))
    out.append(insert("community_messages", ["message_type", "lang", "wording", "sort_order"], [(a, l, b, i) for i, (a, l, b) in enumerate(MESSAGES, 1)]))
    out.append(insert("disability_barriers", ["barrier", "response", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(BARRIERS, 1)]))
    out.append(insert("outreach_elements", ["element", "practical_use", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(OUTREACH, 1)]))
    out.append(insert("terminology_guide", ["technical_term", "better_wording", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(TERMS, 1)]))
    out.append(insert("stakeholders", ["stakeholder_group", "contribution", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(STAKEHOLDERS, 1)]))
    out.append(insert("testimonies", ["lang", "title", "quote", "anonymised", "sort_order"], [(l, t, qt, True, i) for i, (l, t, qt) in enumerate(TESTIMONIES, 1)]))
    out.append(insert("annual_income", ["report_year", "amount_usd", "basis", "is_audited"], INCOME))
    out.append(insert("income_sources", ["id", "name", "sort_order"], [(i, n, i) for i, n, _, _ in SOURCES]))
    amt = []
    for i, _, a24, a25 in SOURCES:
        amt.append((i, 2024, a24))
        amt.append((i, 2025, a25))
    out.append(insert("income_source_amounts", ["source_id", "report_year", "amount_usd"], amt))
    out.append(insert("me_indicators", ["area", "indicator", "data_source", "sort_order"], [(a, b, c, i) for i, (a, b, c) in enumerate(ME, 1)]))
    out.append(insert("safeguarding_risks", ["risk", "action_taken", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(RISKS, 1)]))
    out.append(insert("challenges", ["challenge", "mitigation", "lesson", "sort_order"], [(a, b, c, i) for i, (a, b, c) in enumerate(CHALLENGES, 1)]))
    out.append(insert("priorities_2026", ["sort_order", "priority"], [(i, p) for i, p in enumerate(PRIORITIES, 1)]))
    out.append(insert("evidence_sources", ["source_item", "report_use", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(EVIDENCE, 1)]))
    out.append(insert("project_design_figures", ["figure_value", "label", "detail", "is_approximate", "sort_order"], [(v, l, d, a, i) for i, (v, l, d, a) in enumerate(FIGURES, 1)]))
    out.append(insert("document_control", ["field_name", "details", "sort_order"], [(a, b, i) for i, (a, b) in enumerate(DOC_CONTROL, 1)]))
    out.append(insert("site_settings", ["setting_key", "setting_value"], SETTINGS))
    out.append(insert("site_images", ["filename", "section_number", "caption", "alt_text", "sort_order"], [(f, s, c, a, i) for i, (f, s, c, a) in enumerate(IMAGES, 1)]))
    return "".join(out)


PG_HEAD = "-- VISUMO website data - PostgreSQL\n-- Generated from the VISUMO Annual Narrative Report 2025\nSET client_encoding = 'UTF8';\nBEGIN;\n\n"
PG_TAIL = "COMMIT;\n"

MY_HEAD = "-- VISUMO website data - MySQL / MariaDB\n-- Generated from the VISUMO Annual Narrative Report 2025\nSET NAMES utf8mb4;\nSTART TRANSACTION;\n\n"
MY_TAIL = "COMMIT;\n"


def main():
    body = build_body()
    for engine, head, tail in (("postgres", PG_HEAD, PG_TAIL), ("mysql", MY_HEAD, MY_TAIL)):
        d = ROOT / engine
        seed = head + body + tail
        (d / "seed.sql").write_text(seed, encoding="utf-8")
        schema = (d / "schema.sql").read_text(encoding="utf-8")
        (d / f"visumo_{engine}_full.sql").write_text(schema.rstrip() + "\n\n" + seed, encoding="utf-8")
        print("wrote", d / "seed.sql", "and", d / f"visumo_{engine}_full.sql")


if __name__ == "__main__":
    main()
