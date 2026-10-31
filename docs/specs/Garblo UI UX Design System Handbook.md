# Garblo UI/UX Design System Handbook

Oct 28, 2026 · @Gad · v0.2 draft · DS-CR-01

## 0. How to use this handbook

This handbook is the single source of truth for how Garblo looks, speaks and behaves: its words, visual tokens, components and interaction patterns. It distills eight research reports into rules; where those reports disagree, the Decision Log (Ch.1) rules.

### Who reads what

| Role | Start with | Then use |
| --- | --- | --- |
| Product owner | Ch.0, Ch.1, Ch.2 | Ch.19 (research backlog) |
| Product designer | Ch.2, Ch.3 | Ch.4–Ch.16 |
| Mobile / web engineer | Ch.4–Ch.8 | Ch.9–Ch.16, Ch.18 (tokens) |
| Content / copywriter | Ch.3 | Ch.11, Ch.14, Ch.15 (microcopy in context) |
| Pilot researcher | Ch.19 | Ch.1 (what is decided vs. open) |

### Source-of-truth order

When two sources disagree, the higher one wins:

1. **Decision Log (Ch.1)** — overrides everything, including later chapters. A rule changes only through a new decision entry.
2. **Flow Spec v2.7 › T7**: was the interim source until design system v2 shipped on 2026-10-30 (D50); it should now point to this handbook. Screen-level detail not yet absorbed (T7 › G3) still comes from it.
3. **Handbook chapters (Ch.2–Ch.19)** — the working rules.
4. **Master synthesis report** (*terminologies\_and\_design\_system\_research*, "Stage 3 Master Spec") — consulted for detail the handbook has not yet absorbed.
5. **Seven pillar reports** — background and rationale only. Anything they say that conflicts with 1–4 is void.

### Evidence tags

Every rule that rests on research carries one tag, so readers know how hard to hold it.

| Tag | Meaning | How to treat it |
| --- | --- | --- |
| `[DECIDED]` | A team decision recorded in Ch.1 | Follow. Change only via a new Ch.1 entry |
| `[SCIENCE]` | Settled baseline: colour science, WCAG, HCI explanation research | Follow |
| `[HIGH]` | 3+ independent sources in the research | Follow by default |
| `[MEDIUM]` | 1–2 sources | Follow; watch it in the pilot |
| `[HYPOTHESIS]` | Design inference with no direct evidence | Ship behind a flag or with a metric; tracked in Ch.19 |

The research tool graded itself "84.2% verified"; that figure is not an independent audit. Market statistics in the reports (e.g. "91% of archive viewers are 18–24", "70% of engagement in DMs") are context, never the sole rationale for a rule.

### Release-scope tags

| Tag | Scope |
| --- | --- |
| `[MVP]` | University pilot: iOS/Android app + desktop **web** workbench in the browser |
| `[V2]` | After pilot validation: features whose hypothesis (Ch.19) must pass first |
| `[LATER]` | Native macOS/Windows clients, OS-level trackpad/haptic APIs, advanced telemetry models |

An untagged rule is `[MVP]`.

### Writing conventions

- **MUST / SHOULD / MAY** carry their usual spec meaning: required / default unless justified / optional.
- Capitalised product terms (Archive, Piece, Fit, Lookbook, Rotation, Pass) are glossary terms defined in Ch.3.
- Tokens and keys are set in code: `--surface-canvas-default`, `E`, `⌘K`. On Windows and the web, `⌘` reads as `Ctrl`.
- Formulas and algorithm specs (spring constants, ranking maths, dwell-time models) live in engineering specs; this handbook states only the behaviour the user sees.

### Chapter map

| Ch. | Title | Micro-task | Status |
| --- | --- | --- | --- |
| 0 | How to use this handbook | MT-01 | In review |
| 1 | Decision Log | MT-01 | In review |
| 2 | Design Principles | MT-02 | In review |
| 3 | Lexicon & Content Design | MT-03 | In review |
| 4 | Color System | MT-04 | In review |
| 5 | Typography | MT-05 | In review |
| 6 | Space, Layout, Shape & Elevation | MT-06 | In review |
| 7 | Motion, Haptics & Sound | MT-07 | In review |
| 8 | Garment Imagery & Cutout Rendering | MT-08 | In review |
| 9 | Fit Card, Garment Node & Inventory | MT-09 | In review |
| 10 | Agent Surfaces | MT-10 | In review |
| 11 | Explainability & Feedback | MT-11 | In review |
| 12 | Archive & Navigation | MT-12 | In review |
| 13 | Swipe Triage | MT-13 | In review |
| 14 | Ingestion & Onboarding | MT-14 | In review |
| 15 | Co-Styling, Sharing Tiers & Provenance | MT-15 | In review |
| 16 | Platform Ergonomics | MT-16 | In review |
| 17 | Accessibility & Vietnam Localization | MT-17 | In review |
| 18 | Token Implementation | MT-18 | In review |
| 19 | Governance & Research Backlog | MT-19 | Not started |
| A | Source Reports | MT-20 | Not started |

## 1. Decision Log

53 decisions bind this handbook: D1–D7 were settled by the master report, D8–D38 were added by the PO on 2026-10-28, and D39–D53 came from change request DS-CR-01 on 2026-10-29 and 30.

To change a decision, add a new row and set the old one to Superseded; never edit an Accepted row in place.

When a new row only narrows an older one, the Replaces column names it, the older row stays Accepted, and the newer row wins where the two overlap.

| ID | Topic | Binding decision | Replaces | Why | Status |
| --- | --- | --- | --- | --- | --- |
| D1 | Swipe-left verb | **Pass** is the only reject verb. **Benched** is the analytics label for Pieces unworn ≥ 90 days | "Brick Fit" (Lexicon report) | A punitive verb on peers' looks creates social anxiety; "brick" means dead stock | Accepted |
| D2 | AI image cleanup | **Enhance Cutout** = segmentation + lighting normalisation with the colour histogram locked. Generative redraw is off by default, opt-in for basics only. The raw Tag & Patina Proof photo is always kept | Alta-style "Prettify" by default | Patina and intact tags prove vintage authenticity | Accepted |
| D3 | AI interface | No chat thread anywhere. The AI shows itself through 6 ambient states, on-card badges and a single-line `⌘K` command bar | Chat box in the desktop Inspector | People won't type prompts while dressing and lack textile vocabulary | Accepted |
| D4 | Colour architecture | Media surfaces are neutral (`#FAFAFA` light / `#121214` dark, OKLCH chroma ≤ 0.008). Acid Lime, Cyber Violet and Electric Cobalt appear only on floating HUD chrome and status | `#F6F5F2` warm canvas; Linear indigo/emerald | Coloured surroundings shift perceived garment colour `[SCIENCE]` | Accepted |
| D5 | Monetisation UI | No AI credit or token counters, no model names, no item caps on the Archive. The control bar shows "Locked to \[N\] Archive Pieces" instead | "5/5 DAILY TOKENS · GEMINI-2.5-FLASH" | Acloset's caps and in-app currency drove churn `[HIGH]` | Accepted |
| D6 | Desktop triage keys | `E`/`→` Add to Rotation · `#`/`←` Pass, then `1`–`4` for a reason · `H`/`↑` Save to Cluster · auto-advance on | Capture One `7`/`8`/`9` | Linear/Superhuman convention; frees `1`–`4` | Accepted |
| D7 | Card geometry | Garment cell 3:4 · Lookbook card 4:5 · swipe commits at 35% of card width · positions in 0.0–1.0 fractions (×1000 integers only for vision APIs) | 50% threshold, 0–1000 integers | Less thumb over-reach on large phones | Accepted |
| D8 | Dormant label | UI says **Benched** only; "Bricks" never appears in system chrome (allowed in user tags) | "Benched (or Bricks)" in master glossary | One term per concept; "brick" also reads as reject | Accepted |
| D9 | Approve label | Button and pill copy = **Add to Rotation**; "Pull to Rotation" survives only as the event name | "Pull to Rotation" vs. "Add to Rotation" | Plainer, and translates cleanly to Vietnamese | Accepted |
| D10 | Lookbook vs. Cluster | **Lookbook** = ordered, swipeable deck of Fits. **Cluster** = unordered moodboard of saved Fits and Elements. Swipe-up = "Save to Cluster" | "Lookbook (or Cluster)" used interchangeably | Two behaviours need two names | Accepted |
| D11 | Piece vs. Element | **Piece** = a garment, owned or borrowed. **Element** = any non-garment reference (photo, swatch, note) | "Piece (or Element)" | Same as D10 | Accepted |
| D12 | Sharing control | One ordered 4-step picker per Piece and Fit: **Vault → Mutuals → Gatekept ID** (public, brand masked) **→ Open-Source** (public, full detail) | 3-state toggle vs. 4 tiers; tier names differ across reports | Removes the 3-vs-4 mismatch; one mental model, ordered by exposure | Accepted |
| D13 | Key reservations | `L` = Lock anchor. `S` stays unbound. `7`/`8`/`9` are removed everywhere; `1`–`4` are only reason chips | `S` = Lock in one report, Save in another; "9 Red Tag" left in the master parity table | No key with two meanings | Accepted |
| D14 | Desktop MVP | The desktop workbench ships as a web app in the browser; native macOS/Windows is `[LATER]` | Native AppKit/Win32 clients | Pilot scope; agreed 2026-10-28 | Superseded |
| D15 | Handbook language | English text; glossary and microcopy tables add a Vietnamese column | — | Agreed 2026-10-28 | Accepted |
| D16 | Currency | Prices and cost-per-wear follow the device locale; pilot default is VND with no decimals | "$4.20/wear" examples | Pilot runs in Vietnam | Accepted |
| D17 | No affiliate commerce | No "Shop the look", buy buttons or affiliate links on any surface; a source link appears only when the owner Open-Sources a Piece | Alta/ShopMy link culture | Product decision; also respects gatekeeping | Accepted |
| D18 | Savings-linked pricing | Subscription is capped at 10% of the money a user saves, so billing UI must show the savings basis openly | — | Product decision | Accepted |
| D19 | UI language | The pilot UI is English only. Vietnamese appears in this handbook only as a team gloss in the glossary, never as UI strings. User content (names, captions, tags) may be in any language | D15's Vietnamese microcopy column | PO choice 2026-10-28 (option 1C) | Accepted |
| D20 | AI name | The AI speaks as "Garblo": no persona name, no first-person "I". "Stylist" always means a human | "Personal Agentic Stylist", "Archivist" | PO choice 2026-10-28; keeps the AI a tool (P2) | Accepted |
| D21 | Themes | Three themes: Warm (default), Cold, Neutral, each in light and dark (6 palettes). Themes shift surface temperature only, always below OKLCH chroma 0.008 (D4 holds). Accents keep one meaning in every theme. The user picks a theme in Settings | Single neutral palette (master report) | PO choice 2026-10-28 | Accepted |
| D22 | Fonts | Newsreader (display), Inter (UI and body), JetBrains Mono (telemetry and keys), all under the SIL Open Font License 1.1, self-hosted with Vietnamese subsets | PP Editorial New, PP Neue Montreal, PP Lettra Mono (paid) | PO: open licences only, 2026-10-28 | Accepted |
| D23 | Corner style | Hybrid: media (cards, cells, frames) stays sharp at 1 px; controls (buttons, inputs) are 8 px; floating HUD 12 px; pills round | All-sharp 0–2 px (master report) | PO choice 2026-10-28 (option B): softer for thumbs, archive feel kept on media | Accepted |
| D24 | Motion and feedback | Every animation ships with a reduced-motion version (hard requirement). Haptics on, following the OS setting plus an in-app toggle. No UI sounds in the pilot | "Haptic & acoustic feedback" (research) | PO 2026-10-28 | Accepted |
| D25 | Virtual try-on | Private 2D try-on toggle in the pilot: opt-in with consent, generated in the cloud, always badged AI PREVIEW · PRIVATE, Vault-only, never shared. No 3D avatars | Try-on as a core or public feature | PO choice 2026-10-28 (option A) | Accepted |
| D26 | Icon set | Tabler Icons 3.50, outline only, MIT licence, 24 px grid, 1.5 px stroke | No icon set in research | PO choice 2026-10-28 | Accepted |
| D27 | Badge density | A Lookbook card shows 2 explanation badges (Context pill + the strongest reason); the rest open from "Why · N more" (phone) or hover / Inspector (desktop) | All 5 badges on every card (master report) | PO choice 2026-10-28 (option B); keeps P1 and P4 | Accepted |
| D28 | Agent input | Phone control bar starts collapsed (status pill + Run Shuffle). The command field takes one line; results come back as cards and toasts, never text replies. No dedicated mic: the OS keyboard dictation covers voice | Always-expanded bar; voice-prompt button (cross-platform report) | PO 2026-10-28 ("go") | Superseded |
| D29 | Pass feedback and undo | Pass-reason sheet opens only after a slow Pass (> 3.5 s on the card), at most 3 times per session; desktop keys 1–4 log a reason any time. Undo toast lasts 6 s over a stack of the last 10 swipes | Uncapped reason sheet (research) | PO 2026-10-28 ("go"); guards against survey fatigue (H2) | Accepted |
| D30 | Navigation | Phone bottom nav, 5 tabs: Today · Archive · + Index (centre) · Inbox · You. Rotation, Benched, Grails and Clusters are Archive filters; Canvas opens from a Fit's ⋯ menu | No fixed tab set in research | PO choice 2026-10-28 (option A) | Superseded |
| D31 | Two decks | Today deck (3–5 owned Fits for now) and Taste deck (open-ended, trains Style DNA), as two segments of the Today tab. In Taste, swipe right = "More like this" | One mixed deck | PO choice 2026-10-28 (option A) | Superseded |
| D32 | Ingestion channels | Pilot ships 3 ways to add Pieces: camera capture, camera-roll import (garments cut out of outfit photos), team-curated basics checklist. Receipt email (Shopee, Lazada, Tiki parsers) and browser extension / link paste are V2 and hidden in the pilot | 5 channels at launch (research) | PO choice 2026-10-28 (option A) | Accepted |
| D33 | Onboarding order | Taste first: swipe \~20 Lookbooks to seed Style DNA, then add 5 basics, then the first Today deck | Index-first onboarding | PO choice 2026-10-28 (option A) | Accepted |
| D34 | Social scope | Pilot: Co-Style from Mutuals; Catch & Release as a Mutuals-visible tag with an interest ping, no payments or deals in-app. V2: public SOS style bounties with karma (H4), IRL borrow requests | Full multiplayer scope (research) | PO 2026-10-28 ("go with your recommendation") | Accepted |
| D35 | Web-safe shortcuts | Desktop web uses single keys and G-chords; the only modifiers are ⌘K, ⌘Enter, ⌘Z. Remaps: W Log Fit, N Index Piece, I Inspector, V deck ↔ Canvas. Shortcuts match the physical key so Vietnamese input methods never swallow them | ⌘L, ⌘U, ⌘I, ⌘B (native-app keys that clash with browsers) | PO 2026-10-28 ("go"); follows from D14 | Accepted |
| D36 | Accessibility and formats | Target WCAG 2.2 AA. Dates, numbers, money, time, temperature and week start follow the device region through standard locale formatting (CLDR); nothing is hard-coded to Vietnam. System telemetry dates use the unambiguous "28 OCT" form | Vietnam-fixed formats (my proposal) | PO 2026-10-28 ("go with global format") | Accepted |
| D37 | Build stack and token output | Phone and desktop web are built in Flutter. Tokens compile to one Dart file: a GarbloColors ThemeExtension for the 6 theme-modes plus space, radius, size, type, motion and shadow constants | CSS custom properties for web plus separate native outputs (my default) | PO 2026-10-28 ("1B") | Accepted |
| D38 | Reusable design system | Tokens, fonts, 25 icons and 10 component specs are also published as a Garblo Design System artifact, so later decks, docs and mock-ups reuse the same values | Handbook and code package only | PO 2026-10-28 ("2 recommendation") | Accepted |
| D39 | Primary action colour | Forest green accent-primary (#1F5A2E light, #7BC88A dark) with on-primary and accent-primary-pressed is the one primary action per view in all six themes. Acid Lime shrinks to the 1.5 px anchor-lock ring, always paired with the lock icon. The primary may sit on controls inside the media stage, never behind a garment | Acid Lime as the primary fill; narrows D4 | Flow Spec v2.7 D1 via DS-CR-01 (DS-01–07); ≥ 7.4:1 on every ground, rechecked 2026-10-29. PO 2026-10-29 | Accepted |
| D40 | Button label type | New label-button style, Inter 15 / 1.20 / 500, for 48 pt buttons and the FAB | product-cell 13 on buttons | O-1 (DS-09): easier to read on a 48 pt button. PO 2026-10-29 | Accepted |
| D41 | Caps and counters | Principle 6 means no paid Archive caps and no AI token counters. Batch limits (UP TO 10 PER BATCH) and deck position (3/8 FITS) are allowed; the prompt counter appears only from 240 characters | Narrows D5 | O-2: limits that guide are not paywalls. PO 2026-10-29 | Accepted |
| D42 | Fit vs. Lookbook | A Fit is one outfit, and every swipe card is a Fit card. A Lookbook is a saved, ordered set of Fits. Status lines say DRAFTING FITS, never DRAFTING LOOKBOOKS | "Lookbook card" in D7 and D27; narrows D10 | O-3: matches the Flow Spec deck (3/8 FITS, FIT 03). PO 2026-10-29 | Accepted |
| D43 | Community reaction | The ♡ action is named Appreciate: heart outline icon and a count only, no word on the card. "Like" never appears | An unnamed ♡ (Flow Spec) | O-4: keeps the no-Like rule. PO 2026-10-29 | Accepted |
| D44 | Pilot platform | The pilot is phone only, portrait only. The desktop web workbench (≥ 1024) is post-pilot; its sizes and shortcuts (D35) stay in this handbook, marked post-pilot | D14 (workbench in the MVP) | O-5: Flow Spec pilot scope. PO 2026-10-29 | Accepted |
| D45 | Generated images | Generated images appear only inside a frame that carries a provenance pill (AI-GENERATED IMAGE, ILLUSTRATION or TRY-ON), never in the Archive and never as a cutout | Blanket "never redraw garment pixels"; narrows D2 and D25 | O-6: screens 3b, 4b and Community need illustrations. PO 2026-10-29 | Accepted |
| D46 | Navigation | Phone bottom nav, 5 tabs: ADD · ARCHIVE · GU MATCH · IMPACT · COMMUNITY. Gu Match, Impact and Community are feature names, written as shown. The Today and Taste decks sit inside GU MATCH until Flow Spec T7 says otherwise | D30 and D31 | DS-19. PO 2026-10-29 ("proceed") | Accepted |
| D47 | Primary agent verb | The primary agent action is Draft Fits (Draft a Fit for one). The phone control bar starts collapsed (status pill + Draft Fits); the command field takes one line; results come back as cards and toasts; no mic | "Run Shuffle"; D28 | DS-04, DS-20. PO 2026-10-29 ("proceed") | Accepted |
| D48 | Component sizes | Header 56 · bottom nav 64 · button and FAB 48 · filter chip 32 · context chip 36 · pill 24 · action rail 52 · avatar 32 · touch target 44 minimum · icons 16 / 20 / 24 | Nav 56 and 44 px buttons (Ch.6, Ch.12) | DS-12. PO 2026-10-29 ("proceed") | Accepted |
| D49 | Garment groups | Seven groups: Tops, Bottoms, Outerwear, Shoes, Bags, Hats, Accessories (ties included). Bags never use a shopping-bag icon | — | DS-22 names six; Outerwear is the PO default for the seventh, 2026-10-29 | Accepted |
| D50 | Source of truth | Until design system v2 ships, Flow Spec v2.7 › T7 wins where it differs from this handbook. When v2 ships, the design system and this handbook are the single source again, and T7 points to them | — | DS-CR-01 summary. PO 2026-10-29 | Accepted |
| D51 | Bottom-nav labels | New label-nav style, Inter 10 / 500 / 0.04em caps. Nav labels stay at 100% text size; above that a long-press shows the label large (iOS Large Content Viewer, Android tooltip). The one exception to the DS-10 text-size rule | chrome-nav 12 / 0.08em on the nav (COMMUNITY measured 86 px in a 78 px tab) | Measured 2026-10-29; PO 2026-10-30 ("follow your recommendation") | Accepted |
| D52 | Inbox and You | Triage Inbox opens from the header bell (its dot = an item needs action) and You from the header avatar initial; neither is a tab | Inbox and You as tabs (D30) | Follows D46 and DS-15; T7 ref pending. PO 2026-10-30 | Accepted |
| D53 | Garment-group icons | Tops shirt · Bottoms garblo-trousers · Outerwear jacket · Shoes shoe · Bags beach-bag · Hats garblo-hat · Accessories sunglasses (ties: tie). The two garblo- icons are drawn in house on Tabler's 24 px grid and 1.5 px stroke | shopping-bag for Bags; Tabler-only set | Tabler 3.50 has no trousers or hat icon. PO 2026-10-30 | Accepted |

### Change request DS-CR-01 (2026-10-29)

DS-CR-01 aligns this handbook with Garblo Flow Spec v2.7 › T7. Twelve decisions (D39–D50) settle its six open conflicts (O-1 to O-6, each on the request's recommendation) and record the rules it changes. Until design system v2 ships, T7 wins where it differs from a chapter (D50).

&#91;embedded content: DS-CR-01 decision map · 4 replaced, 7 narrowed, 5 added\]

Red rows are Superseded in the log above. Dashed rows keep their status, but read them through the newer decision.

| Request item | Decision | Chapters to update | Micro-task |
| --- | --- | --- | --- |
| DS-01–07 colour | D39 | Ch.4, Ch.10, Ch.17 | CR-2 |
| O-1 · DS-09 | D40 | Ch.5 | CR-3 |
| O-2 | D41 | Ch.2 (P6), Ch.3 | CR-7 |
| O-3 | D42 | Ch.3, Ch.9, Ch.10, Ch.13: "Lookbook card" becomes "Fit card" | CR-7, CR-5 |
| O-4 | D43 | Ch.3, Ch.15 | CR-7, CR-6 |
| O-5 | D44 | Ch.6, Ch.12, Ch.16: desktop marked post-pilot | CR-4 |
| O-6 | D45 | Ch.8, Ch.11 | CR-6 |
| DS-19 | D46 | Ch.3, Ch.12, Ch.13, Ch.16 | CR-7 |
| DS-04 · DS-20 | D47 | Ch.3, Ch.10, Ch.16 | CR-7 |
| DS-12 | D48 | Ch.6, Ch.12 | CR-4 |
| DS-22 | D49 | Ch.8 | CR-8 |
| Summary | D50 | Ch.0 | CR-1 |

Open: Flow Spec v2.7 is not attached to this handbook yet, so screen links (T7 › G3) and what Gu Match and Impact contain stay marked "T7 ref pending" until it is.

#### Acceptance checklist (DS-CR-01)

- [x] PO decided O-1 to O-6 (D40–D45)
- [x] DS-01 to DS-07 colour changes in tokens.json and the README; contrast rechecked (Ch.4, Ch.17)
- [x] DS-08 to DS-14 type, layout, size and motion tokens (Ch.5–Ch.7)
- [x] DS-15 and DS-16 component pages (P0), drawn in warm light and warm dark
- [x] DS-17 and DS-18 component pages (P1)
- [x] DS-19 to DS-22 glossary, status lines and icons (Ch.3, Ch.8)
- [x] DS-23 Flutter library regenerated (garblo-tokens v0.2, Ch.18)
- [x] DS-24 Design System version 2 published, with changelog
- [ ] Flow Spec T7 updated to point at design system v2 (Flow Spec owner)

## 2. Design Principles

Seven principles serve one goal: Garblo is the most trusted app in the circular fashion economy, where AI is the means of production, never the producer. Every screen is reviewed against all seven.

&#91;embedded content: principles map · 4 pillars, 7 principles\]

Each pillar groups the principles that govern one layer of the product; the footer of each pillar names the decisions that enforce it.

### The seven principles

| # | Principle | ✓ Always | ✕ Never | Decisions |
| --- | --- | --- | --- | --- |
| P1 | **Garment is the hero** · *Trang phục là nhân vật chính* | Neutral stage behind every garment; the real photo is kept; UI chrome recedes | Coloured backgrounds behind garments; AI redraw by default | D2, D4 |
| P2 | **You are the author** · *Bạn là tác giả* | AI drafts, the user decides; pin, swap or override anywhere; nothing is shared without a tap | Typed prompts as the only way in; AI posting or scheduling on its own | D3 |
| P3 | **Closet-locked truth** · *Chỉ dùng đồ thật trong tủ* | Suggest only owned or explicitly borrowed Pieces; ground each Fit in weather, occasion and fabric weight | Unowned items in a Fit; summer looks in cold rain | D5 |
| P4 | **Why, in 10 words** · *Giải thích dưới 10 chữ* | Every suggestion shows its reason as a badge of 10 words or fewer, citing a real rule or fact | Persuasive paragraphs, "AI magic", hype | D3 |
| P5 | **Private by default, credit always** · *Riêng tư mặc định, luôn ghi công* | New Pieces land in the Vault; only the owner moves them up the sharing ladder; creator credit travels with every remix | Forced brand or link exposure; stripping @credit | D12 |
| P6 | **Wear more, buy less** · *Mặc nhiều hơn, mua ít hơn* | Surface Benched Pieces, cost-per-wear, savings and Catch & Release | Buy buttons, affiliate links, item caps, credit counters, guilt copy | D5, D17, D18 |
| P7 | **Right device, right job** · *Đúng thiết bị, đúng việc* | Phone = capture and swipe; desktop = sort and curate; every gesture also has a button and a key | Stretched mobile UI on desktop; swipe-only actions | D6, D13, D14 |

### When principles collide

Priority, highest first: **P3 Truth › P5 Consent › P1 Garment › P2 Author › P4 Why › P6 Circular › P7 Device**.

| Collision | Winner | Outcome |
| --- | --- | --- |
| Enhance Cutout would make a jacket look better but shifts its colour | P3 › P1 | Histogram stays locked; the raw photo is kept beside the cutout |
| A public Lookbook would earn more Connects with brands shown | P5 › P6 | Public sharing defaults to Gatekept ID; the owner may Open-Source each Piece |
| An accurate reason needs 14 words | P3 › P4 | Cut the claim, keep the fact; full rationale moves to the Inspector |

### Design-review checklist

Tick every box before a screen moves to In review.

- [ ] **P1** Garments sit on a neutral surface; the original photo is kept
- [ ] **P2** Every AI action on this screen can be undone, pinned or overridden
- [ ] **P3** Every AI-suggested Piece is owned or explicitly borrowed
- [ ] **P4** Every suggestion shows a reason of 10 words or fewer
- [ ] **P5** Nothing becomes more visible without the owner's tap; credit is shown
- [ ] **P6** No buy link, cap, counter or guilt copy
- [ ] **P7** Every gesture has a visible button and a desktop key

## 3. Lexicon & Content Design

Garblo speaks English in the pilot, uses one word per concept, and uses studio verbs (Index, Connect, Co-Style) instead of shopping verbs (Buy, Like, Post). The AI is simply "Garblo"; "Stylist" always means a person.

&#91;embedded content: lexicon map · core nouns joined by the verbs that move between them\]

Read left to right: Garblo drafts Fits from Archive Pieces, deals them as Fit cards, and each swipe sends the Fit to Rotation, Style DNA or a Cluster. Pass writes a rule to Style DNA, which Garblo reads before its next draft.

### Language rules

1. **English UI** for the pilot (D19). The Vietnamese column below is a team gloss so everyone means the same thing; it never ships as a UI string.
2. **User content is multilingual.** Piece names, captions, handles and tags may be Vietnamese, so every font and text field must render Vietnamese diacritics (checked in Ch.5).
3. **One term per concept.** Use the glossary word exactly, capitalised as shown. No synonyms in UI, docs or code comments.
4. **Garblo has no "I".** Status lines have no subject; when one is needed, it is "Garblo" (D20).
5. **Slang lives in user tags, not in chrome.** System labels use only the terms below.

### Core terms

Risk = chance the word feels dated or cringe: ● low · ◐ medium.

| Term | Means | Never call it | VI gloss (team only) | Risk |
| --- | --- | --- | --- | --- |
| **Archive** | Everything the user has indexed: their digital wardrobe | My Closet, Inventory | Tủ đồ số | ● |
| **Piece** | One garment, owned or borrowed (D11) | Item, Product, SKU, Garm | Món đồ | ● |
| **Element** | A non-garment reference: photo, swatch, note (D11) | Pin, Asset | Tư liệu tham khảo | ● |
| **Fit** | An assembled outfit of Pieces | Outfit post, Look | Bộ phối | ● |
| **Canvas** | The freeform workspace where a Fit is built | Outfit editor | Khung phối | ● |
| **Lookbook** | An ordered, swipeable deck of Fits (D10) | Album, Feed, Recommendations | Xấp phối để lướt | ● |
| **Cluster** | An unordered moodboard of Fits and Elements (D10) | Board, Folder, Collection | Bảng cảm hứng | ● |
| **Rotation** | The Fits and Pieces in active wear this season | Favorites, Liked | Đồ đang mặc thường xuyên | ● |
| **Benched** | A Piece unworn for 90+ days (D8) | Bricks, Unused, Deadweight | Đồ đang "ngủ đông" | ● |
| **Grail** | A high-priority Piece the user wants to find | Wishlist item | Món đồ đang săn | ◐ |
| **Style DNA** | The user's editable style profile: 3 Style Words, weights, Avoids | Preferences, Algorithm | Hồ sơ phong cách | ● |
| **CPW** | Cost per wear = price ÷ wears, in VND (D16) | ROI, Value | Chi phí mỗi lần mặc | ● |
| **Vault · Mutuals · Gatekept ID · Open-Source** | The 4 steps of the sharing ladder (D12) | Private, Public | Riêng tư · Bạn chung · Ẩn nguồn · Công khai nguồn | ● |
| **Co-Style Submission** | A Fit a peer builds from your Archive for you to review | Suggestion, Recommendation | Gợi ý phối từ bạn bè | ● |
| **Triage Inbox** | Where new Pieces and Co-Style Submissions wait for review | Notifications | Hộp chờ duyệt | ● |
| **Catch & Release** | A zero-commission listing to pass a Piece on | Sell, Marketplace | Pass lại đồ | ◐ |
| **Garblo** | The AI, speaking as the product (D20) | Stylist, Assistant, Bot | (giữ nguyên) | ● |
| **Stylist** | A person who styles a Fit: you or a peer | AI stylist | Người phối đồ | ● |

### Action labels

The label is the exact UI text. Every action has a touch, a button and a key equivalent (P7).

| Label | Mobile | Desktop | Replaces | Decision |
| --- | --- | --- | --- | --- |
| **Index Piece** | + button → camera or share sheet | `N`, or drag and drop | Upload, Add item | — |
| **Enhance Cutout** | Automatic; tap to toggle | Hold `P` for the loupe | Remove background, AI magic | D2 |
| **Draft Lookbook** | Control bar | `⌘K` | Get recommendations | D3 |
| **Add to Rotation** | Swipe → | `E` or `→` | Like, Favorite | D9 |
| **Pass** | Swipe ← | `#` or `←`, then `1`–`4` for a reason | Dislike, Brick Fit | D1 |
| **Save to Cluster** | Swipe ↑ | `H` or `↑` | Save, Pin | D10 |
| **Pin & Shuffle** | Double-tap a Piece, then Shuffle | `L`, then `⌘Enter` | Regenerate | D13 |
| **Log Fit** | Card action bar | `W` | Post, Check in | — |
| **Connect** | Tap a peer's Piece | Right-click → Connect | Repost, Steal | — |
| **Co-Style** | Tap a mutual's profile | `G` then `I` to review | Suggest an outfit | — |
| **Request Garment ID** | Tap a Gatekept Piece | Click the masked label | "W2C?", "Drop the link" | D12 |
| **Undo** | Shake, or tap the toast | `Z` or `⌘Z` | — | — |
| **More like this** | Swipe → in the Taste deck | E or → in the Taste deck | Like, Heart | D31 |

### Say / don't say

| ✕ Don't say | ✓ Say instead | Why |
| --- | --- | --- |
| Buy now, Shop the look | Nothing: there is no commerce surface | D17 |
| Like, Favorite | Add to Rotation | Utility, not applause (D9) |
| Dislike, Brick Fit | Pass | No punitive verbs on peers' looks (D1) |
| Upload item | Index Piece | Building an archive, not filling a cart |
| AI magic, Smart AI | The real step: Enhance Cutout, Draft Lookbook | Gen Z distrusts black boxes `[HIGH]` |
| Recommended for you, Trending | Drafted from your Archive | Grounds the AI in owned Pieces (P3) |
| Make public, Make private | The ladder step: Vault, Mutuals, Gatekept ID, Open-Source | D12 |
| You never wear this | Benched · 120D | State, not blame (P6) |
| W2C, WDYWT, Jawn, Slay, Aura, Sicko mode | Nothing in chrome; fine in user tags | Dated or cringe in system UI `[HIGH]` |

### Voice

Calm · precise · archival · generous. The benchmark is a printed fashion archive (SSENSE, Are.na), not a lifestyle app.

- ✓ No exclamation marks, ever.
- ✓ Sentence case for content. UPPERCASE only in global navigation and mono badges (sizes in Ch.5).
- ✓ Ground every Garblo line in a real fact: an owned Piece, a fabric, the weather, a wear count.
- ✓ Numbers, units and keys in mono: `14°C` · `12 WEARS` · `45D` · `⌘K`.
- ✕ Never shame, blame or rush ("hurry", "you never…", "don't miss").
- ✕ Never expose the machinery: no "our model", "algorithm", model names or token counts (D5).

### Tone by moment

| Moment | Tone | ✓ Say | ✕ Don't say |
| --- | --- | --- | --- |
| Morning launch | Calm, telegraphic | `SYNCED · ARCHIVE & WEATHER` | Good morning! Ready to slay? |
| Empty Archive | Inviting, concrete | Archive unindexed. Forward a receipt or snap 5 basics to start. | Your closet is empty! Start shopping! |
| Benched nudge | Neutral, optional | 12 Pieces benched 90D+. Draft a Lookbook from them? | 12 pieces gathering dust. |
| No Fit possible | Plain, with a way out | Tight constraints. Relax one Avoid rule? | No outfits found. |
| System error | Cause + next step | Couldn't reach weather. Using yesterday's forecast. | Oops! Something went wrong. |
| Social credit | Generous | Styled by @mia · Worn by you | Copied from @mia |

### Garblo's status lines

Six states, UPPERCASE mono, no subject, ≤ 6 words. Visuals and colours are specified in Ch.10.

| State | Symbol | Status line |
| --- | --- | --- |
| 1 Idle | ● green, static | `SYNCED · ARCHIVE & WEATHER` |
| 2 Curating | ◉ violet, pulse | `DRAFTING FITS FROM ARCHIVE…` |
| 3 Attuning | ◎ violet, ring | `ATTUNING TO STYLE DNA…` |
| 4 Remixing | ◆ violet; the anchor keeps its lime ring | `ANCHORED 1 PIECE · SHUFFLING REST` |
| 5 Scouting | ◌ cobalt, sweep | `SCOUTING SHARED ARCHIVES…` |
| 6 Conflict | ▲ orange, ring | `TIGHT CONSTRAINTS · RELAXING FILTER` |

In full sentences (toasts, empty states) Garblo is the subject: "Garblo drafted 4 Fits for 14°C rain." Never "I drafted…".

### Explanation badges (P4)

Every badge follows one formula and stays at **10 words or fewer**:

```markdown
[real fact] + [styling verb] + [effect]
```

| Badge | Template | ✓ Example | Words |
| --- | --- | --- | --- |
| Silhouette Tether | {detail of Piece A} {verb} {detail of Piece B} | Cropped hem balances mid-rise trouser volume | 6 |
| Context Pill | {temp} {weather} · {Piece} for {occasion} | 14°C drizzle · Trench for 2PM pitch | 7 |
| Harmony Swatch | {colour/texture} {verb} {colour/texture} | Warm burgundy tweed grounds cool grey plaid | 7 |
| CPW Tag | {state} · {wear fact} | Restyles anchor blazer · 3rd wear this month | 7 |
| Provenance Chip | {match}% match · {Style Word} / {credit} | 94% match · Minimalist tailoring | 5 |

✕ "This stunning outfit perfectly captures your unique vibe" — persuasive, no fact, 8 words of nothing.

### Core string bank

| Context | String |
| --- | --- |
| Index Piece sub-label | Forward a receipt, paste a link, or snap a Piece. |
| Draft Lookbook placeholder | Draft from Rotation for 14°C rain, gallery opening… |
| Pass reason chips (`1`–`4`) | Too cold · Proportion off · Wrong occasion · Color clash |
| Pass toast | Passed · Style DNA updated · Undo |
| Rotation toast | Added to Rotation · Undo |
| Closet lock indicator | `LOCKED TO {N} ARCHIVE PIECES` |
| Gatekept Piece label | ID gatekept by @{owner} · Request Garment ID |
| ID request sent | Requested · @{owner} decides |
| Co-Style submit | Send Submission |
| Empty Triage Inbox | Inbox clear. |
| Offline | Offline · changes sync when you reconnect. |

UI strings use **US English** spelling ("Color clash"), matching token names such as `color`. Prose in this handbook may use either.

### Flow Spec strings (DS-CR-01)

The Flow Spec (T7 › G4) already writes in this voice; its feature names, verbs and status lines are now part of the glossary.

| Kind | Strings | Rule |
| --- | --- | --- |
| Feature names · nav (D46) | ADD · ARCHIVE · GU MATCH · IMPACT · COMMUNITY | Written exactly as shown; Gu Match, Impact and Community are names |
| Verbs (DS-20) | Index Pieces · Analyze with Garblo · Draft Fits · Draft a Fit · Wear today · Review Fit · Save to calendar · Share progress | Studio verbs; Draft Fits replaces Run Shuffle (D47) |
| Community action (D43) | Appreciate | Heart outline + count only on the card; never "Like" |
| Status lines (DS-21) | `DRAFTING` · `CALENDAR, WEATHER & COMMUTE` · `FROM 3 PHOTOS` · `3 PIECES` · `OFFLINE` · `3 CHANGES WAITING` | No subject; `mono-badge` caps |
| Markers | `▲ BENCHED · 41 DAYS` · `EST.` · `SELF-REPORTED` | Symbol + words; every estimate is marked |
| Provenance (D45) | `AI-GENERATED IMAGE` · `ILLUSTRATION` · `TRY-ON` | Required on every generated image |
| Guides, not caps (D41) | `UP TO 10 PER BATCH` · `3/8 FITS` · `FIT 03` · prompt counter from 240 characters | Allowed; paid Archive caps and token counters are not |

Say **Fit card**, not "Lookbook card" (D42) · **Draft Fits**, not "Run Shuffle" (D47) · **Appreciate**, not "Like" (D43).

## 4. Color System

Garblo ships 3 themes × 2 modes = 6 palettes (D21). Every surface behind a garment stays below OKLCH chroma 0.008, so clothes look the same in every theme; each accent keeps one meaning everywhere. Forest green marks the one primary action per view (D39); the other accents live on floating chrome and status marks. All contrast ratios below were recomputed by script; 4 issues in the master report were fixed.

### Two zones

| Zone | What lives there | Allowed colour | Rule |
| --- | --- | --- | --- |
| □ **Media stage** | Canvas, cards, wells, garment cutouts, Lookbook photos | Theme neutrals only, chroma ≤ 0.008 | MUST `[SCIENCE]` |
| ◆ **Floating chrome** | Control bar, status pills, anchor ring, badges, focus ring | Accents + inks | MAY use accents |
| ● **Controls on the stage** | Buttons, FAB, toggle on, nav indicator, progress ring, level bar, current-week bar | `accent-primary (forest green) only` | MAY; never behind a garment or as a plinth (D39, DS-06) |
| T **Text and rules** | Everywhere | Inks and rules of the active theme | MUST pass WCAG AA (≥ 4.5:1 text, ≥ 3:1 UI) |

### Themes

The default is **Warm** (unbleached linen / atelier charcoal); **Cold** (gallery steel / night slate) and **Neutral** (pure SSENSE grey) are user choices in Settings. Light or dark follows the phone setting.

&#91;embedded content: swatch board · 6 theme palettes + accents\]

Read across a row for one palette, down a column to compare one token across themes; the surface columns differ only in temperature, never in lightness.

| Token | Role | Warm light | Warm dark | Cold light | Cold dark | Neutral light | Neutral dark |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `--surface-canvas` | Page behind everything | `#FDFAF5` | `#14120F` | `#F7FAFF` | `#101215` | `#FAFAFA` | `#121212` |
| `--surface-card` | Plinth under a garment or Fit | `#FFFCF8` | `#1C1A17` | `#FAFDFF` | `#181B1E` | `#FFFFFF` | `#1A1A1A` |
| `--surface-well` | Chips, rails, action bars | `#F7F4EF` | `#24221F` | `#F1F4F9` | `#212326` | `#F4F4F4` | `#222222` |
| `--surface-divider` | Section bands | `#EBE8E3` | `#312E2B` | `#E5E8ED` | `#2D2F32` | `#E8E8E8` | `#2F2F2F` |
| `--ink-primary` | Titles, prices, nav | `#13110D` | `#F8F5F0` | `#0F1115` | `#F2F6FB` | `#111111` | `#F5F5F5` |
| `--ink-editorial` | Body, captions, badge copy | `#35332F` | `#D8D4CF` | `#303337` | `#D1D5DA` | `#333333` | `#D4D4D4` |
| `--ink-muted` | Telemetry: CPW, wears, fabric | `#56524E` | `#A5A19D` | `#505357` | `#9FA2A7` | `#535353` | `#A2A2A2` |
| `--rule-structural` | 1px grid hairlines | `#35332F` | `#2A2723` | `#303337` | `#25282B` | `#333333` | `#272727` |
| `--rule-product` | Active cell, focus edge | `#000000` | `#423F3B` | `#000000` | `#3D4044` | `#000000` | `#404040` |

Two overlay tokens follow the theme automatically: `--surface-hud-glass` = canvas at 86% (light) / 88% (dark) opacity with `blur(20px) saturate(140%)`; `--surface-image-scrim` = black at 10% / 24% under display type on photos.

### Accents (same in every theme)

| Token | Light | Dark | Means | Use as | Worst contrast (L / D) | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| `--accent-primary` | `#1F5A2E` | `#7BC88A` | The one primary action per view (D39): Draft Fits, Wear today | Fill with on-primary; nav indicator, toggle on, progress ring, level and current-week bars | 7.4 / 7.8 | ✓ AAA |
| `--accent-primary-pressed` | `#174424` | `#6AB57A` | Primary while pressed | Fill with on-primary | 11.1 / 8.5 with on-primary | ✓ AAA |
| `--on-primary` | `#FFFFFF` | `#000000` | Label and icon on the primary | Text, icons | 8.2 / 10.5 | ✓ AAA |
| `--accent-agentic-bg` | `#D4FF00` | `#D4FF00` | Anchor-lock ring only, always with the lock icon (D39) | 1.5 px ring; text on it uses on-agentic | 18.1 : 1 with on-agentic; ring 1.1 : 1 on light cards | ◐ ring needs the lock icon |
| `--accent-agentic-text` | `#245500` | `#D4FF00` | Inline Garblo readouts | Text | 8.0 / 13.6 | ✓ AAA |
| `--accent-synthesis-ai` | `#6D28D9` | `#C084FC` | Garblo is working (states 2–3) | Text, rings, pulses | 6.4 / 6.0 | ✓ AA |
| `--accent-social-pulse` | `#0038FF` | `#5982FF` | Co-Style, Connect, Scouting | Text, rings | 6.3 / 4.6 | ✓ AA |
| `--status-cpw-optimal` | `#15803D` | `#4ADE80` | Well-worn, target CPW reached | Text, dots | 4.6 / 9.0 | ✓ AA |
| `--status-cpw-dormant` | `#D93800` | `#FF5C26` | Benched, constraint conflict | Borders and dots (light); any (dark) | 4.2 / 5.1 | ◐ UI only in light |
| `--status-cpw-dormant-text` | `#C83200` | `#FF5C26` | Benched text | Text | 4.9 / 5.1 | ✓ AA |

Worst contrast = the lowest ratio against canvas, card and well across all three themes.

### Primary action contrast (DS-CR-01)

Forest green clears 7.4 : 1 on every ground in all six palettes, so it passes AAA as text and as a control. Rechecked by script on 2026-10-29; the change request's figures match to one decimal.

| Theme | Primary | Canvas | Card | Well | Label on primary |
| --- | --- | --- | --- | --- | --- |
| Warm light | `#1F5A2E` | 7.9 : 1 | 8.0 : 1 | 7.5 : 1 | 8.2 : 1 white |
| Cold light | `#1F5A2E` | 7.8 : 1 | 8.0 : 1 | 7.4 : 1 | 8.2 : 1 white |
| Neutral light | `#1F5A2E` | 7.9 : 1 | 8.2 : 1 | 7.5 : 1 | 8.2 : 1 white |
| Warm dark | `#7BC88A` | 9.3 : 1 | 8.7 : 1 | 7.9 : 1 | 10.5 : 1 black |
| Cold dark | `#7BC88A` | 9.4 : 1 | 8.6 : 1 | 7.9 : 1 | 10.5 : 1 black |
| Neutral dark | `#7BC88A` | 9.3 : 1 | 8.7 : 1 | 7.9 : 1 | 10.5 : 1 black |

The catch is lightness, not contrast: forest green is only 1.15–1.32 : 1 from violet and 1.15–1.64 : 1 from the well-worn green, so hue can never be the only signal (usage rules below, Ch.17).

### Ink contrast

| Ink | Worst light | Worst dark | Verdict |
| --- | --- | --- | --- |
| `--ink-primary` | 17.1 : 1 | 14.5 : 1 | ✓ AAA |
| `--ink-editorial` | 11.5 : 1 | 10.7 : 1 | ✓ AAA |
| `--ink-muted` | 7.0 : 1 | 6.2 : 1 | ✓ AA (AAA on canvas only) |

### Audit fixes to the master report

1. Master dark well `#222227` (chroma 0.009) and divider `#2E2E35` (0.013) broke its own 0.008 rule → replaced by theme neutrals.
2. Dark Electric Cobalt `#4E75FF` fell to 4.4 : 1 on dark cards → lightened to `#5982FF` (≥ 4.55 : 1).
3. Muted ink was claimed AAA everywhere; on dark wells it is 6.2 : 1 → labelled AA (still passes for 12–13 px telemetry).
4. Signal Orange `#D93800` is 4.2 : 1 on light wells → non-text only in light mode; text uses `#C83200`.

### Usage rules

- ✓ Garments sit only on canvas, card or well.
- ✕ Never put an accent behind a garment or use one as a card background.
- ✕ Acid Lime is never text on a light surface (1.1 : 1) and never a fill: it is only the 1.5 px anchor ring, always with the lock icon (D39).
- ✓ One forest-green (accent-primary) fill per view at most: the primary action, with on-primary on it.
- ✓ Ink-primary fills mean "selected", not "act": selected filter chip, checked checkbox, current sharing step, toast. Never a second primary button (DS-05).
- ✓ Forest green may mark controls and data on the media stage (buttons, FAB, toggle on, nav indicator, progress ring, level bar, current-week bar); ✕ never behind a garment or as a plinth (DS-06).
- ✕ No status dot inside a primary-filled control, and no meaning by hue alone between forest green, violet and the well-worn green (DS-07).
- ✓ Focus stays a 2 px ink-primary ring, never green, so focus can't be mistaken for the primary action.
- ✓ Colour never carries meaning alone; pair it with a symbol or label (status symbols in Ch.3, colour-blind checks in Ch.17).
- ✓ Components read semantic tokens only; a theme switch swaps surface, ink and rule values and nothing else.
- ✕ No pure `#000000` canvas (crushes dark dyes, causes halation) `[SCIENCE]`.

## 5. Typography

Garblo uses three free, open-source variable fonts under the SIL Open Font License 1.1: **Newsreader** for display, **Inter** for UI and body, **JetBrains Mono** for telemetry and keys. All three render all 146 Vietnamese letters plus đ/Đ, checked against the font files themselves.

&#91;image: Type specimen: the eleven type tokens in Warm light, including label-nav, label-button and mono-figure, plus a Vietnamese stacked-mark stress test\]

Rendered from the actual font files in the Warm light palette. Mixed English and Vietnamese samples show what pilot users will type into Piece names, captions and calendar events.

### The three faces

| Role | Font | Licence | Variable axes | Vietnamese | Missing symbols → use instead | Fallback stack |
| --- | --- | --- | --- | --- | --- | --- |
| Display | **Newsreader** · Production Type | OFL 1.1 | wght 200–800, opsz 6–72 | ✓ 146/146 + đ | Arrows, ⌘, ✓ ✕ → never set keys or arrows in display | "Iowan Old Style", Georgia, serif |
| UI and body | **Inter** · Rasmus Andersson | OFL 1.1 | wght 100–900, opsz 14–32 | ✓ 146/146 + đ | ✕ → icon | system-ui, -apple-system, "Segoe UI", Roboto, sans-serif |
| Telemetry and keys | **JetBrains Mono** · JetBrains | OFL 1.1 | wght 100–800 | ✓ 146/146 + đ | ✓, ⏎ → icon | ui-monospace, "SF Mono", Menlo, Consolas, monospace |

All three also carry ₫, ° and ·; Inter and JetBrains Mono carry ⌘ ⇧ ⌥ → ← ↑ ↓ for key hints.

### The licence in plain words

- ✓ OFL 1.1 is an OSI-approved open-source licence: free for commercial apps.
- ✓ Bundle and embed the fonts in iOS, Android and web builds.
- ✓ Ship each font's `OFL.txt` on the app's open-source credits screen.
- ✕ Don't sell the font files on their own.
- ✕ A modified font must take a new name.

### Type scale

| Token | Role | Font | Mobile | Desktop | Line height | Tracking | Rules | Change vs. master |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `--type-display-hero` | Featured Lookbook cover | Newsreader 400 | 52 px | 100 px | 1.10 | −0.0375em | Sentence case; 1 per view | lh 0.94 → 1.10 |
| `--type-display-lookbook` | Fit card title | Newsreader 400 | 32 px | 48 px | 1.15 | −0.025em | Sentence case | lh 1.02 → 1.15 |
| `--type-heading-section` | Archive category header | Inter 500 | 20 px | 24 px | 1.25 | −0.015em | Sentence case | lh 1.20 → 1.25 |
| `--type-chrome-nav` | Rail and section headers (the bottom nav uses label-nav) | Inter 400 | 12 px | 13 px | 1.00 | +0.08em | UPPERCASE, system strings only | — |
| `--type-body-editorial` | Rationale, styling notes | Inter 400 | 15 px | 16 px | 1.50 | 0 | Measure 50–60 characters | — |
| `--type-product-cell` | Brand + Piece title | Inter 500 | 13 px | 14 px | 1.35 | +0.01em | Brand shown as entered | Forced UPPERCASE brand dropped |
| `--type-mono-telemetry` | CPW, wears, °C | JetBrains Mono 500 | 12 px | 13 px | 1.30 | −0.01em | Slashed zero; system units UPPERCASE | lh 1.20 → 1.30 |
| `--type-mono-badge` | Pills, provenance, key hints | JetBrains Mono 400 | 11 px | 11 px | 1.30 | +0.04em | 11 px hard floor | lh 1.00 → 1.30 |
| `--type-mono-figure` | KPI numbers (1c, 4b, 2c poster) | JetBrains Mono 500 | 28 px | 32 px | 1.10 | −0.02em | Digits and units only; tabular, slashed zero; EST. marker | New (DS-08) |
| `--type-label-button` | 48 pt buttons, FAB | Inter 500 | 15 px | 15 px | 1.20 | 0 | System labels only; sentence case | New (D40, DS-09) |
| `--type-label-nav` | Bottom-nav labels | Inter 500 | 10 px | — | 1.00 | +0.04em | UPPERCASE; fixed 100% + long-press large label | New (D51) |

### Text size (DS-10)

Every style follows the phone's text-size setting, with a ceiling that keeps layouts whole; rows grow taller rather than truncate.

| Styles | Scale up to | When it no longer fits |
| --- | --- | --- |
| Content: display, heading, body, product-cell, label-button, mono-figure, mono-telemetry | 200% | The row, button or tile grows taller |
| Caps: chrome-nav, mono-badge | 130% | The pill or header wraps to two lines |
| Bottom-nav labels: label-nav | 100% (D51) | Long-press shows the label large (iOS Large Content Viewer, Android tooltip) |

In Flutter, wrap the nav in `MediaQuery.withNoTextScaling` and clamp caps styles with a `TextScaler` of at most 1.3.

### Vietnamese safety rules

Measured in the font files: stacked capitals (Ẫ, Ễ, Ặ) rise 0.97–1.11 em and ỵ drops 0.27 em, so one line of Vietnamese needs 1.23–1.32 em of ink.

1. **Never `text-transform` user content** (names, captions, calendar events, brands). Casing is shown exactly as entered; UPPERCASE is for system strings only.
2. **Line height ≥ 1.30** for any UI style that can hold user text; display styles stay ≥ 1.10.
3. **Size pills and chips by padding**, never by a fixed height, and never `overflow: hidden` on a single line box.
4. **Store text in Unicode NFC**; marks typed as combining characters are normalised on save.
5. **Truncate at word boundaries** with an ellipsis; never split a letter from its mark.

### Usage rules

- ✓ Tabular figures in any column of numbers: mono is tabular by design; Inter uses `font-variant-numeric: tabular-nums`.
- ✓ Slashed zero (`font-feature-settings: "zero"`) in mono telemetry, so 0 and O never mix.
- ✓ `font-optical-sizing: auto` on Newsreader and Inter.
- ✕ No serif below 24 px: its hairlines break on screen.
- ✕ No weight above 600; hierarchy comes from size and typeface.
- ✓ Self-host WOFF2 subsets (latin, latin-ext, vietnamese) in the app; no runtime calls to a font CDN, so text renders offline and leaks no user data.
- ✓ Symbols such as ✓ ✕ ⏎ come from the icon set (Ch.8), not from fonts.

## 6. Space, Layout, Shape & Elevation

Everything snaps to a 4 px grid. Media is sharp and controls are soft (D23). Depth comes from lightness steps and frosted glass, never from shadows under garments.

&#91;image: Space and shape sheet: spacing ladder, hybrid corner family with the 48 px forest-green Draft Fits button, four elevation levels, phone stack (pilot) vs. desktop workbench (post-pilot)\]

### Spacing scale

| Token | px | Typical use |
| --- | --- | --- |
| `--space-0` | 0 | Flush Archive grid cells sharing one hairline |
| `--space-1` | 4 | Icon-to-label gap, gap inside a pill |
| `--space-2` | 8 | Gap between chips and between touch targets |
| `--space-3` | 12 | Control bar inset from the screen edge, badge padding |
| `--space-4` | 16 | Phone side margin, card padding |
| `--space-5` | 24 | Between groups inside a sheet |
| `--space-6` | 32 | Between page sections |
| `--space-7` | 48 | Desktop section rhythm |
| `--space-8` | 64 | Top padding above a hero title |
| `--space-9` | 96 | Desktop editorial spreads |

### Shape (D23 hybrid)

| Token | Value | Applies to | Change vs. master |
| --- | --- | --- | --- |
| `--radius-media` | 1 px | Fit card, garment cell, photo frame, Archive grid cell | — |
| `--radius-control` | 8 px | Buttons (incl. Draft Fits), inputs, card action bar cells, segmented controls | 2 px → 8 px |
| `--radius-hud` | 12 px | Control bar, sheet top corners, popovers, toasts | — |
| `--radius-pill` | 9999 px | Status, context and filter pills; avatars | — |
| `--radius-key` | 3 px | Key-hint caps such as `⌘K` | New |

A radius never clips a garment's own silhouette: cutouts float inside the media frame.

### Borders and focus

| Token | Value | Use |
| --- | --- | --- |
| `--border-hairline` | 1 px `--rule-structural` | Grid lines, card edges, rails |
| `--border-active` | 1 px `--rule-product` | Selected cell, active card |
| `--focus-ring` | 2 px solid `--ink-primary`, 2 px offset | Keyboard focus (`:focus-visible` only); visible on all 6 palettes |
| `--ring-anchor` | 1.5 px `--accent-agentic-bg` | Locked anchor Piece (Ch.9) |

### Elevation

| Level | Name | Treatment | Examples |
| --- | --- | --- | --- |
| 0 | Canvas | Flat page | Background of every screen |
| 1 | Card | One lightness step up + hairline; no shadow | Fit card, Piece cell |
| 2 | HUD | `--surface-hud-glass` + `blur(20px) saturate(140%)` + hairline | Control bar, status pill |
| 3 | Sheet | Card surface over an overlay scrim (black 32% light / 48% dark) + one shadow `0 8px 24px rgba(0,0,0,.12)` | Bottom sheets, rejection sheet, dialogs |

- ✓ At most two floating levels on screen at once: the HUD plus one sheet.
- ✕ Never a rectangular `box-shadow` on a garment cutout; cutouts get alpha-aware shadows only (Ch.8).
- Layer order: `--z-base 0` · `--z-sticky 10` · `--z-hud 20` · `--z-sheet 30` · `--z-toast 40` · `--z-modal 50`.

### Aspect ratios

| Object | Ratio | Note |
| --- | --- | --- |
| Garment cell | 3:4 | Archive grid, slot carousels (D7) |
| Fit card | 4:5 | Swipe deck, desktop 4-up compare (D7) |
| Element in a Cluster | Native | Masonry keeps the source ratio |
| Avatar | 1:1 circle | Provenance chips, Mutuals |
| Canvas | Free | Positions stored as 0.0–1.0 fractions (D7) |

### Layout and breakpoints

| Class | Width | Columns · margin · gutter | Layout | Pilot |
| --- | --- | --- | --- | --- |
| Compact | < 600 px | 4 · 16 · 8 | Phone single stack. On the 390 frame: spans 358 full, 175 half, 114 three-up. Header 56 + top inset; bottom nav 64 + bottom inset; control bar `min(100vw − 24px, 640px)` floating above the nav | ✓ portrait only (D44) |
| Medium | 600–1023 px | 8 · 24 · 16 | Archive becomes an icon rail; centre stage; Inspector opens as a sheet | post-pilot |
| Expanded | ≥ 1024 px | 12 · 32 · 24 | Workbench, 3 panes: left 260 (240–320), centre fluid (≥ 60%), right Inspector 340 (320–420); docked from 1440, below that the Inspector overlays the centre and toggles with `I` | post-pilot (D44) |

Grid values come from Flow Spec v2.7 › T7 › G1 via DS-11 and sit on a 4 pt baseline; pane widths come from the research `[MEDIUM]`. Tokens: `layout` family in the Design System, `tokens/core/layout.json` in the token package.

### Safe areas and placement (DS-14)

Every phone screen stacks the same five bands, and floating actions keep 16 above whatever sits at the bottom.

&#91;embedded content: phone safe areas · 390 × 844 reference frame\]

The 47 and 34 insets belong to the reference frame used in mock-ups; the app always reads the real insets from the OS.

### Component sizes (D48)

| Token | Size | Used by |
| --- | --- | --- |
| `size-header` | 56 | App header, solid or HUD glass |
| `size-nav` | 64 | Bottom nav (was 56) |
| `size-button` · `size-fab` | 48 | Primary and secondary buttons, the FAB |
| `size-chip-filter` | 32 | Filter chip, single select |
| `size-chip-context` | 36 | Context chip, multi select |
| `size-pill` | 24 | Status and provenance pills |
| `size-rail` | 52 | Action rail button beside a Fit card |
| `size-avatar` | 32 | Avatar initial |
| `size-target` | 44 | Minimum touch target |
| `size-icon-sm` · `-md` · `-lg` | 16 · 20 · 24 | Icons in pills · nav and inline · header and rail |

### Touch and density

- ✓ Every interactive target is at least 44 × 44 px and buttons are 48 px tall; the hit area may extend past the visible shape.
- ✓ At least 8 px between neighbouring targets.
- ✓ Row heights: 48 px on phone; 40 px default and 32 px dense on the desktop workbench (post-pilot).

## 7. Motion, Haptics & Sound

Motion in Garblo explains cause and effect: a card follows the finger, a tick confirms the threshold, a spring lands the result. Every animation has a reduced-motion version, haptics follow the phone's setting, and the pilot plays no UI sounds (D24).

&#91;image: Motion sheet: four spring curves against a 150 ms reduced-motion fade, and the timeline of one right swipe with its two haptic ticks\]

### Motion tokens

| Token | Definition | Settles | Use |
| --- | --- | --- | --- |
| `--spring-gesture` | ζ 0.80 · k 1473 · c 61.4 · m 1 | 300 ms, ≈ 2% overshoot | Release after a touch drag: fly-out, snap-back |
| `--spring-keyboard` | ζ 1.00 · k 1753 · c 83.7 · m 1 | 220 ms, no overshoot | Keyboard triage (`J` `K` `E` `#` `H`), so fast culling never blurs |
| `--spring-node-pickup` | stiffness 300 · damping 22 · mass 0.8 (ζ 0.71) | ≈ 330 ms to 1%, ≈ 4% overshoot | Lifting a Piece on the Canvas |
| `--spring-sheet` | stiffness 300 · damping 28 · mass 1 (ζ 0.81) | ≈ 330 ms to 1% | Sheets, control bar expanding |
| `--dur-instant` | 100 ms · ease-out | — | Border flash, pressed state |
| `--dur-fast` | 150 ms · ease-out | — | Anticipation frame, hover, every reduced-motion fade |
| `--dur-base` | 220 ms · ease-in-out | — | Tab and page changes |
| `--dur-pulse` | 1200 ms loop | — | Garblo "drafting" pulse |

The same motion values in each output (DS-13). Springs have no CSS form, so the Design System stores their settle times and the Flutter library keeps the springs themselves.

| Handbook | Design System | Flutter (`GarbloMotion`) |
| --- | --- | --- |
| `--spring-gesture` | `dur-gesture` 300 ms | `gesture` |
| `--spring-keyboard` | `dur-base` 220 ms | `keyboard` |
| `--spring-node-pickup` · `--spring-sheet` | — | `nodePickup` · `sheet` |
| `--dur-instant` · `--dur-fast` · `--dur-base` | `dur-instant` 100 · `dur-fast` 150 · `dur-base` 220 ms | `instant` · `fast` · `base` |
| `--dur-pulse` | `dur-pulse` 1200 ms, static under reduced motion | `pulse` |
| Undo toast lifetime | `dur-toast` 6000 ms | `toast` |

Easing curves: `--ease-out` cubic-bezier(0.2, 0, 0, 1) · `--ease-in-out` cubic-bezier(0.4, 0, 0.2, 1) · `--ease-exit` cubic-bezier(0.4, 0, 1, 1). Spring constants follow c = −2m·ln(10⁻⁴)/T and k = c²/(4ζ²m) from the research `[MEDIUM]`.

### Gesture thresholds

- Swipe commits at **35% of card width** or a flick of **≥ 500 px/s** (D7); below that the card springs back.
- While dragging, the card tracks the finger 1:1 and tilts up to **±12°**, pivoting from the edge opposite the grab point.
- Desktop trackpad flicks and ±6° tilt need native APIs and are `[LATER]` (D14); the web workbench uses keys and click.

### Animation inventory with reduced-motion versions

| Animation | Trigger | Default | ♿ Reduced motion | Haptic |
| --- | --- | --- | --- | --- |
| Card drag | Finger on a Fit card | 1:1 tracking + tilt ≤ 12° | 1:1 tracking, no tilt | — |
| Threshold crossed | Drag passes 35% | Direction pill fades in | Pill appears instantly | Soft tick |
| Commit fly-out | Release past threshold | `--spring-gesture` off-screen | 150 ms cross-fade to next card | Crisp tick |
| Snap-back | Release below threshold | `--spring-gesture` back to centre | Instant return | — |
| Keyboard advance | `E` `#` `H` `J` `K` | `--spring-keyboard` slide | Instant swap + 150 ms fade | — |
| Undo | `Z`, shake or toast | Card flies back on inverted spring | Card reappears + 300 ms outline | Light tick |
| Pin anchor | Double-tap or `L` | Lime ring draws in 150 ms; other slots dim to 85% | Ring and dim appear instantly | Selection tick |
| Reshuffle | Shuffle or `⌘Enter` | Unlocked slots spring in, 40 ms stagger | One 150 ms cross-fade, no stagger | — |
| Garblo drafting | Agent state 2 | 1200 ms concentric pulse + skeleton shimmer | Static dot, "…" in the label, static skeleton | — |
| Garblo attuning | Agent state 3 | Ring scales with swipe speed; 100 ms border flash | Static ring, no flash | — |
| Garblo scouting | Agent state 5 | Radial sweep over avatar stack | Static avatar stack | — |
| Constraint conflict | Agent state 6 | Elastic drag resistance + orange ring | Orange ring + label only | Warning buzz |
| Sheet open/close | Rejection sheet, Inspector sheet | `--spring-sheet` | 150 ms fade | — |
| Piece pickup | Drag on Canvas | Lifted shadow + `--spring-node-pickup` | Shadow change only | Light tick |
| Page change | Bottom nav, `G` chords | 220 ms cross-slide | 150 ms cross-fade | — |

Reduced motion turns on with iOS Reduce Motion, Android Remove animations, or `prefers-reduced-motion: reduce` on the web. Nothing ever loops while it is on.

### Haptic map

| Event | iOS | Android | Note |
| --- | --- | --- | --- |
| Swipe crosses 35% | Impact `.soft` | `CLOCK_TICK` | Once per crossing |
| Add to Rotation / Save to Cluster commit | Impact `.rigid` | `CONFIRM` | Positive outcome |
| Pass commit | Impact `.light` | `CLOCK_TICK` | Deliberately quieter than approve |
| Pin anchor, slot scrub step | Selection changed | `CLOCK_TICK` | One per step |
| Constraint conflict | Notification `.warning` | `REJECT` | Paired with the orange ring |
| Error | Notification `.error` | `REJECT` | Paired with an error message |

- ✓ Haptics follow the system setting and an in-app toggle (Settings › Haptics).
- ✓ At most one haptic per 100 ms; none while scrolling.
- ✓ Every haptic pairs with a visible change, so nothing relies on touch alone.

### Sound

No UI sounds in the pilot (D24). Revisit only with pilot evidence that a sound helps; any future sound must be off by default.

## 8. Garment Imagery, Cutouts & Icons

Garblo cleans the background around a garment but never redraws the garment itself: colour data comes from the raw pixels, the original photo is kept forever, and anything AI-generated says so on its face. Icons come from Tabler (D26).

&#91;image: Imagery sheet: five-step Enhance Cutout pipeline with the lime anchor ring plus lock badge, Tag & Patina Proof slot, private 2D try-on preview, and the Tabler icon map\]

### Enhance Cutout pipeline

| Step | What happens | Where | Rule |
| --- | --- | --- | --- |
| 1 Capture | Camera, camera roll, receipt email, pasted link or basics checklist (Ch.14) | Phone | New Pieces land in the Vault (P5) |
| 2 Segment | Alpha mask around the garment, target < 500 ms | On-device | Matches the team's hybrid architecture: preprocessing on device |
| 3 Extract colour | K-means on the **raw** garment pixels → dominant and secondary hex, lightness, undertone | On-device | Runs before any correction, so data is never skewed `[MEDIUM]` |
| 4 Display copy | White-balance toward D65 for display only; crop to the mask; colour histogram locked | On-device | Garment pixels are never synthesised (D2) |
| 5 Keep proof | Untouched original stored in the **Tag & Patina Proof** slot | Vault | Never edited, deletable only by the owner |

Generative redraw stays off. A user may opt in for generic basics only; that image carries an `AI-ENHANCED` badge and the original is one tap away (D2).

### Render modes

| Mode | Look | Where | Token |
| --- | --- | --- | --- |
| **Archival** (default) | Cutout on the card with an alpha-aware contact shadow | Archive grid, Inspector | `--shadow-cutout-resting`: `drop-shadow(0 2px 3px rgba(0,0,0,.18)) drop-shadow(0 8px 16px rgba(0,0,0,.08))`; dark mode alphas .65 / .45 |
| **Sticker** | 3 px off-white `#FAF9F6` contour around the silhouette (SVG dilate) | Canvas collage, Fit cards | `--cutout-contour` |
| **Locked anchor** | Sticker + 1.5 px Acid Lime outer ring | Pinned Piece | `--ring-anchor` (Ch.6) |
| **Lifted** | Single deeper shadow while dragging | Canvas | `--shadow-cutout-lifted`: `drop-shadow(0 12px 24px rgba(0,0,0,.22))` + `--spring-node-pickup` |

The sticker contour stays the same off-white in every theme: it hides rough mask edges and separates dark garments from dark canvases. Shadow blur stays under 30 px to hold 60 fps on phones.

### Photo rules

- ✓ The original photo is always kept and reachable from the Piece drawer.
- ✕ No filters, beautify, colour grading or retouching on garment pixels.
- ✕ No rectangular `box-shadow` on cutouts; alpha-aware `drop-shadow` only.
- ✓ Loading state: a flat `--surface-well` block, never a coloured blur placeholder (it would preview a wrong colour).
- ✓ At most 20 Pieces on one Fit card `[MEDIUM]`.
- ✓ Generated images (illustration, try-on, AI image) appear only in a frame that carries a provenance pill; ✕ never in the Archive and never as a cutout (D45).
- ✕ No 3D avatars (D25).

### Virtual try-on (D25)

| Aspect | Rule |
| --- | --- |
| Entry | Long-press a Fit card (phone) or **Try on (private)** in the Inspector (desktop) |
| First use | Consent screen explains what the reference photo is used for and how to delete it; nothing runs until the user agrees |
| Reference photo | The user's own photo only; stored in the Vault; deleting it also deletes every preview made from it |
| Generation | Cloud, on demand (hybrid architecture); a status line shows while it renders |
| Label | Every preview carries the badge `AI PREVIEW · PRIVATE`; it cannot be removed in the app |
| Sharing | Previews stay in the Vault and cannot move up the sharing ladder |
| Body | No body reshaping, slimming or beautify controls |

### Icons (D26)

- ✓ **Tabler Icons 3.50**, outline style, MIT licence; 24 px grid with stroke set to **1.5 px** to match the hairlines.
- ✓ Sizes 16 / 20 / 24 px; colour follows the text (`currentColor` = an ink token); accents only inside the HUD.
- ✓ Active states use `--ink-primary` plus an underline or ring, never a filled icon.
- ✓ An icon-only button always has an accessible label (Ch.17).
- ✓ Credit the MIT licence on the open-source credits screen next to the fonts.

| Concept | Tabler icon | Concept | Tabler icon |
| --- | --- | --- | --- |
| Archive | `hanger` | Index Piece | `camera` |
| Piece | `shirt` | Receipt import | `receipt` |
| Footwear slot | `shoe` | Paste link | `link` |
| Lookbook | `cards` | Anchor locked | `lock` |
| Cluster | `layout-grid` | Shuffle | `arrows-shuffle` |
| Rotation | `repeat` | Add to Rotation | `check` |
| Benched | `hourglass` | Pass | `x` |
| Catch & Release | `recycle` | Undo | `arrow-back-up` |
| Triage Inbox | `inbox` | Vault | `lock-square` |
| Mutuals | `users` | Gatekept ID | `eye-off` |
| Open-Source | `world` | Weather | `cloud-rain` and siblings |
| Try-on preview | `camera-ai` | ⌘ key hint | `command` |

All 24 names were checked against the Tabler repository. Use `corner-down-left` for the Enter key hint (the ⏎ glyph is missing from our fonts).

### Garment groups and app actions (D49, D53)

| Concept | Icon | Source |
| --- | --- | --- |
| Tops | `shirt` | Tabler |
| Bottoms | `garblo-trousers` | Garblo's own (Tabler has none) |
| Outerwear | `jacket` | Tabler |
| Shoes | `shoe` | Tabler |
| Bags | `beach-bag` | Tabler; never `shopping-bag` (P6) |
| Hats | `garblo-hat` | Garblo's own (Tabler has none) |
| Accessories | `sunglasses`; ties `tie` | Tabler |
| App actions | `sparkles` · `bell` · `leaf` · `calendar-plus` · `x` · `chevron-left` · `dots` · `lock` · `heart` | Tabler |

Garblo's own icons use Tabler's 24 px grid, 1.5 px stroke and round joins, so they sit in a row without standing out. All 41 icons are in the Design System's Icons group.

## 9. Components — Fit Card, Garment Node & Inventory

The Fit card is Garblo's core surface: one Fit, two reasons, three swipes, each with a button twin. The Cutout Garment Node is the atom inside every card, grid and Canvas. Neither component ever changes a garment's pixels to show state.

### Component inventory (Flow Spec T7 › G2)

The Flow Spec's 25 components are all in the Design System, each with a live preview in every theme, its sizes, tokens and states (DS-15 to DS-18). Screen links stay "T7 ref pending" until the Flow Spec is attached.

| # | Component | Size | Key tokens | States | Prio | Design System page |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Header, solid or HUD glass | 56 + top inset | `surface-canvas` / `surface-hud-glass` | solid, glass | P0 | Header |
| 2 | Avatar initial | 32 | `surface-well` | — | P0 | Header |
| 3 | Weather chip | pill 24 | `mono-badge` | idle, pressed | P0 | Header |
| 4 | Bell | 24 in a 44 target | `accent-social-pulse` dot | quiet, needs action | P0 | Header |
| 5 | Bottom nav, 5 tabs | 64 + bottom inset | `label-nav`, `accent-primary` indicator | active, inactive | P0 | BottomNav |
| 6 | Primary button | 48 | `accent-primary`, `label-button` | idle, pressed, focus, disabled, loading | P0 | Button |
| 7 | Secondary button | 48 | `surface-well` | idle, pressed, disabled | P0 | Button |
| 8 | FAB | 48 | `accent-primary` | idle, pressed, focus | P0 | FAB |
| 9 | Filter chip | 32 | `ink-primary` when selected | selected, unselected | P0 | FilterChip |
| 10 | Context chip | 36 | `accent-synthesis-ai` edge + check | on, off | P0 | ContextChip |
| 11 | Checkbox | 20 in a 44 row | `ink-primary` | checked, unchecked, focus, disabled | P0 | Checkbox |
| 12 | Toggle | 52 × 32 | `accent-primary` track | on, off | P0 | Toggle |
| 13 | Action rail button | 52 | `surface-hud-glass` | idle, pressed | P0 | ActionRail |
| 14 | Archive cell | 114, 3:4 | `surface-card`, shared hairline | default, Benched | P1 | ArchiveCell |
| 15 | Photo tile | 175 | `surface-well` | loading, selected | P1 | PhotoTile |
| 16 | Dropzone | 358 × 150 | dashed `rule-structural` | idle, drag-over | P1 | Dropzone |
| 17 | Consent card | 358 | `surface-card` | — | P1 | ConsentCard |
| 18 | Option row | 56 | `ink-primary` radio | selected, unselected | P1 | OptionRow |
| 19 | Attribute row | 56 | `mono-badge` name | plain, with marker | P1 | AttributeRow |
| 20 | Context card | 358 | `surface-card` | — | P1 | ContextCard |
| 21 | KPI tile | 175 | `mono-figure`, `accent-primary` level bar | exact, EST., self-reported | P1 | KpiTile |
| 22 | Post card | 358 | provenance pill, heart outline | — | P1 | PostCard |
| 23 | Bottom sheet | full width | `surface-card`, `surface-overlay-scrim`, `shadow-sheet` | open | P1 | BottomSheet |
| 24 | Toast with Undo | — | `ink-primary` ground | counting, paused | P1 | UndoToast |
| 25 | Status and provenance pill | 24 | `surface-hud-glass`, `mono-badge` | 6 agent states, 7 labels | P1 | StatusPill, ProvenancePill |

Garblo's own components stay alongside them: Fit card, Garment Node, Explanation Badge, Control Bar, Sharing Ladder and the Pass-reason sheet.

&#91;image: Component sheet: annotated Fit card anatomy, eight card states, and eight Garment Node states with forest-green selection badges\]

### Fit card — parts

| # | Part | Spec | Tokens |
| --- | --- | --- | --- |
| 1 | Container | 4:5; phone width `min(100vw − 32px, 420px)`; desktop 4-up compare | `--surface-card` · `--border-hairline` · `--radius-media` |
| 2 | Title + provenance | Lookbook or occasion name, ≤ 28 characters; credit line "@you × drafted by Garblo" or "Styled by @mia" | `--type-display-lookbook` · `--type-mono-badge` · `--ink-muted` |
| 3 | Stage | Up to 20 Pieces at 0.0–1.0 positions; sticker or archival mode (Ch.8) | `--shadow-cutout-resting` |
| 4 | Primary reason | The highest-scoring badge among Silhouette Tether, Harmony Swatch and CPW Tag, ≤ 10 words (Ch.3); 1 px dashed tether at 40% to its Pieces | `--type-mono-badge` · `--radius-pill` |
| 5 | Context pill | Always shown: weather + occasion; tap to swap occasion or add a layer | `--type-mono-badge` · `--radius-pill` |
| 6 | Why · N more | Opens the Why sheet with the remaining badges, including the Provenance chip (D27) | Sheet, elevation 3 |
| 7 | Slot dots | Only on slots with 2–5 alternatives; sideways scrub swaps the Piece and updates the reason live | `--ink-muted` |
| 8 | Action bar | Button twins of the three swipes: ✕ Pass · ↑ Save · ✓ Rotation (primary, filled ink) | 44 px · `--surface-well` · `--radius-control` |
| 9 | ⋯ menu | Log Fit · Connect · Try on (private) | `--radius-hud` popover |

A photo backdrop (street-style Element) adds `--surface-image-scrim` under the title band; a plain card does not.

### Card variants

| Variant | Values | Difference |
| --- | --- | --- |
| Mode | **Triage** (swipe deck) · **Browse** (saved Lookbook, Cluster) | Browse swaps the action bar for Log Fit · Rotation · Connect and disables swipe |
| Source | Garblo · Self · Peer | Peer cards get a 1.5 px `--accent-social-pulse` frame and a "STYLED BY @handle" pill |
| Size | Phone · Desktop 4-up | Desktop shows all badges on hover after 800 ms; Why sheet becomes the Inspector |

### Card states

| State | Trigger | What changes | Ch. |
| --- | --- | --- | --- |
| Rest | Card on top of deck | — | — |
| Drag → | Finger moves right | Tilt ≤ 12°; `→ ADD TO ROTATION` pill in `--status-cpw-optimal` | 7 |
| Drag ← | Finger moves left | `← PASS` pill in ink | 7 |
| Drag ↑ | Finger moves up | `↑ SAVE TO CLUSTER` pill | 7 |
| Anchored · shuffling | Pin + Shuffle | Anchor gets the lime ring; other slots show skeletons, then spring in | 7, 10 |
| Loading | Garblo drafting | Flat `--surface-well` skeleton; no garment colour preview | 8 |
| Conflict | No Fit satisfies anchors + Avoids | 2 px `--status-cpw-dormant` frame + "▲ Relax one Avoid?" pill | 10 |
| From a peer | Co-Style Submission | Cobalt frame + credit pill | 15 |

### Card accessibility

- Role `group`, label "Fit card 3 of 12: Gallery Friday".
- Screen-reader custom actions: Add to Rotation, Pass, Save to Cluster, Why, Log Fit, Connect.
- Focus order: title → primary reason → context pill → Why → action bar → ⋯.
- Keys on desktop: `E` / `→`, `#` / `←`, `H` / `↑`, `Space` to peek a Piece (Ch.16).
- Swipe is never the only path: the action bar always mirrors it (P7).

### Cutout Garment Node — parts

| Part | Spec | Tokens |
| --- | --- | --- |
| Cell | 3:4 in the Archive grid; free-floating on Canvas and cards | `--surface-card` · `--border-hairline` · `--radius-media` |
| Cutout | Archival mode in grids, sticker mode on Canvas (Ch.8) | `--shadow-cutout-resting` |
| Brand + title | Brand exactly as entered; Piece title in sentence case | `--type-product-cell` |
| Telemetry | Wears · CPW in VND, or a status word | `--type-mono-telemetry` · `--ink-muted` |
| Corner marker | One of: status dot, visibility icon, selection check | 16 px Tabler icon or 7 px dot |

### Garment Node states

| State | Visual | Rule |
| --- | --- | --- |
| Default | As above | — |
| Hover / focus | `--border-active` + `--focus-ring` | Focus ring on keyboard focus only |
| Selected (batch) | Scale 0.97 + forest-green check badge (accent-primary) | Turns the `⌘K` bar into batch actions (Ch.10) |
| Locked anchor | Lime ring around the silhouette + `lock` icon | Max 2 anchors per Fit |
| Borrowed reference | 1 px dashed `--accent-social-pulse` frame; owner handle replaces brand; "BORROWED · NOT IN CPW" | Never counted in the wearer's CPW (Ch.15) |
| Benched | `--status-cpw-dormant` dot + "BENCHED 120D" | Analytics label only (D8) |
| Gatekept (public view) | Brand masked as ████; era and silhouette shown; `eye-off` icon; "REQUEST GARMENT ID" | D12 |
| Unavailable | "IN LAUNDRY" or "AWAY" pill; telemetry says UNAVAILABLE | Excluded from Garblo drafts |

- ✕ Never desaturate, fade or blur a cutout to show a state; change the frame, label or icon instead (P1).
- Screen-reader label: "LEMAIRE Twisted shirt, 12 wears, cost per wear 45,000 dong, shared with Mutuals".

### Data contract

| Prop | Values |
| --- | --- |
| `ownership_state` | Owned · Grail\_Target · Borrowed\_Reference · Benched |
| `visibility_scope` | Vault · Mutuals · Gatekept\_ID · Open\_Source (D12) |
| `availability` | Available · In\_Laundry · Away · Catch\_And\_Release |
| `is_anchor_locked` | true · false |
| `render_mode` | archival · sticker · lifted |

## 10. Components — Agent Surfaces

Garblo has no chat. It shows itself through three surfaces: the **Status Pill** says what it is doing, the **Control Bar** shows what it may use and holds one trigger, and the **Command Bar** takes one line in and gives cards back (D3, D28).

&#91;image: Agent surfaces sheet: six status pill states (Remixing now violet), phone control bar collapsed and expanded with the forest-green Draft Fits button, desktop control bar, and the command bar\]

### Agent state machine

&#91;embedded content: agent state machine · 6 states\]

Green is the resting state and red the only one that waits for the user; Attuning (dashed) briefly overlays whichever state is active.

| From | To | Trigger |
| --- | --- | --- |
| 1 Idle | 2 Curating | Weather or calendar changes, deck drops below 3 cards, or the user taps Draft Fits / sends a command |
| 2 Curating | 1 Idle | New cards are ready |
| Any | 3 Attuning | A run of swipes updates Style DNA; lasts ≤ 1.5 s, then returns to the previous state |
| 1 Idle, 2 Curating | 4 Remixing | User pins an anchor and shuffles |
| 4 Remixing | 5 Scouting | No owned Piece fits a slot, or Wildcard is on (Mutuals' Archives allowed) |
| 5 Scouting | 4 Remixing | A candidate is found, or scouting times out |
| 2 Curating, 4 Remixing | 6 Conflict | Anchors + Avoids leave no valid Fit |
| 6 Conflict | 2 Curating | User accepts "Relax one Avoid?" |
| 6 Conflict | 1 Idle | User dismisses |

### Status Pill

| State | Symbol | Colour | Motion | ♿ Reduced motion |
| --- | --- | --- | --- | --- |
| 1 Idle | ● | `--status-cpw-optimal` | None | Same |
| 2 Curating | ◉ | `--accent-synthesis-ai` | 1200 ms pulse + card skeletons | Static dot, "…" label |
| 3 Attuning | ◎ | `--accent-synthesis-ai` | Ring scales with swipe speed | Static ring |
| 4 Remixing | ◆ | `--accent-agentic-bg` | Lime ring on the anchor | Same, no draw-in |
| 5 Scouting | ◌ | `--accent-social-pulse` | Radial sweep over avatars | Static avatars |
| 6 Conflict | ▲ | `--status-cpw-dormant` | Ring + warning haptic | Ring, haptic kept |

- Anatomy: 6 px symbol + status line (Ch.3) in `--type-mono-badge`; `--surface-hud-glass`, hairline, `--radius-pill`; height set by 4 × 10 px padding.
- Placement: top of the screen under the system status bar (phone); top-left of the centre stage (desktop).
- Tap or click opens **Garblo activity**: the weather, calendar event, Archive count and Avoids rules it used for the current deck. This is the transparency path behind P4.
- Screen readers: polite live region, at most one announcement per 5 s; Conflict is announced at once.

### Control Bar

| Part | Spec |
| --- | --- |
| Shell | `min(100vw − 24px, 640px)` wide, `--surface-hud-glass` + blur, hairline, `--radius-hud`, elevation 2; floats 12 px above the bottom nav (phone) or docks at the bottom of the centre stage (desktop) |
| Collapsed (phone default) | Status Pill + Draft Fits; tap the pill area to expand, swipe down or `Esc` to collapse |
| Context chips | Weather · occasion · styling mode (Wrong Shoe Theory, Sandwich Rule, Seesaw Proportion) `[MEDIUM]`; scroll sideways; the active chip gets a 1 px `--accent-synthesis-ai` hairline; tap to swap in a popover |
| Closet lock | "LOCKED TO 142 ARCHIVE PIECES" (phone: "142"); lock icon; tap to exclude laundry or away Pieces; turns cobalt "+ MUTUALS" when Wildcard is on |
| Command field | One line, ≤ 120 characters, placeholder from Ch.3; opens the Command Bar |
| Draft Fits | The view's single forest-green (accent-primary) fill, on-primary label, `--radius-control`, 48 px tall (D48); re-drafts unlocked slots or the next batch |

- ✕ No token counts, model names or quota meters (D5).
- ✓ Desktop shows the bar fully expanded at all times.

### Command Bar (⌘K)

| Aspect | Rule |
| --- | --- |
| Open | `⌘K` on desktop; tapping the command field on phone (sheet above the keyboard) |
| Input | One line of plain language or a command; `Enter` runs, `Esc` closes |
| Groups | **Draft** (parsed intents) · **Go to** (with `G`-chord hints) · **Pieces** (search) · **On N selected** (batch actions appear only with a selection) |
| Output | The deck refreshes, the view changes or the batch applies, then a toast confirms. Never a text reply |
| Can't parse | Inline hint with a working example: "Try: rain, office, no heels"; no apology |
| Recent | Last 5 commands as chips, stored on the device, clearable; not a conversation log |
| Accessibility | Combobox pattern: arrow keys move, `Enter` runs; result count announced |

## 11. Components — Explainability & Feedback

These components close the loop between Garblo and the user: badges explain a Fit in 10 words or fewer, the Why sheet shows every reason, the Pass-reason sheet turns a rejection into an editable rule, the slot carousel fixes one Piece without rejecting the whole Fit, and Undo makes every swipe safe (D29).

&#91;image: Explainability sheet: five badges plus the counterfactual pill, Why sheet, Pass-reason sheet, footwear slot carousel and the Undo toast with an underlined Undo\]

### Explanation badges

Copy templates live in Ch.3; this table covers placement and behaviour.

| Badge | Anchored to | Built from | Interaction |
| --- | --- | --- | --- |
| 1 Silhouette Tether | The garment landmark it describes (hem, waist, vamp), via a 1 px dashed line at 40% | Proportion heuristics: Seesaw, Sandwich Rule `[MEDIUM]` | Expands after 800 ms dwell or a tap; the line is static, so it stays under reduced motion |
| 2 Context Pill | Bottom-left of the card, always shown | Weather + calendar + fabric weight (1–5) | Tap: swap occasion or add a layer |
| 3 Harmony Swatch | Where two garments meet | Colour pulled from raw pixels (Ch.8) + fabric texture | Long-press shows the colour pair larger |
| 4 CPW Tag | Top corner of the Piece it describes; 4 px radius | Wear count, last worn, CPW change | Tap opens the Piece in the Inspector |
| 5 Provenance Chip | Why sheet (phone) or card footer (desktop) | Style DNA match + credit line | Tap opens the archetype comparison |
| Counterfactual pill | Card, Conflict state only | The single Avoid rule blocking every Fit | "Relax" lifts that rule for this deck only |

- ✓ Every badge cites a real fact: an owned Piece, a measurement, the weather, a wear count.
- ✕ No confidence scores below 50% are shown; Garblo drops that badge instead.
- ✓ Badges are buttons with full-sentence screen-reader labels.

### Why sheet

| Aspect | Rule |
| --- | --- |
| Opens from | "Why · N more" on the card; on desktop the Inspector shows the same list |
| Content | All badges for the Fit, one per row with its icon, in the order of the badges table |
| Footer | "Garblo activity" link (Ch.10) |
| Height | Fits content up to 60% of the screen; elevation 3 |

### Pass-reason sheet

| Aspect | Rule |
| --- | --- |
| Trigger | A Pass after more than 3.5 s on the card (a "near miss"); fast Passes stay silent |
| Cap | At most 3 sheets per session (D29) |
| Chips | `1` Too cold · `2` Proportion off · `3` Wrong occasion · `4` Color clash; 44 px tall, 2 × 2 grid |
| Result | One tap saves a readable rule to Style DNA › Avoids and closes the sheet |
| Skip | Always visible; skipping is not penalised and is not counted as a reason |
| Desktop | Keys `1`–`4` log a reason right after `#`, sheet or not |
| Learning | A near-miss Pass weakens only the pairing between garments, never each garment's own score `[HYPOTHESIS]` H2 |

### Slot carousel

| Aspect | Rule |
| --- | --- |
| Appears | On any slot with 2–5 alternatives (most often footwear or outer layer) |
| Gesture | Sideways scrub inside the slot (phone); `Tab` to the slot, then `[` / `]` (desktop) |
| Feedback | Selection haptic per step; the Silhouette Tether badge rewrites itself |
| Rule | Swapping a slot is not a Pass: the Fit stays on the deck |

### Undo toast

| Aspect | Rule |
| --- | --- |
| Copy | Action · consequence · Undo, e.g. "Passed · Style DNA updated · Undo" (Ch.3) |
| Look | Inverted surface (`--ink-primary` background, canvas text), Undo underlined in canvas colour at weight 600 (lime failed contrast on the light toast of dark themes); `--radius-hud`; 2 px countdown line in canvas colour at 60% |
| Life | 6 s, then fades; hovering or focusing it pauses the timer |
| Depth | Stack of the last 10 actions across devices; `Z` / `⌘Z`, a shake or the toast restores the newest |
| Screen readers | Polite announcement; Undo is focusable without stealing focus |

## 12. Components — Archive & Navigation

The phone has five tabs (D46: ADD · ARCHIVE · GU MATCH · IMPACT · COMMUNITY); the header bell and avatar open Triage Inbox and You (D52), and the post-pilot desktop mirrors them in its left pane. The Archive is a flush hairline grid of Garment Nodes; every Piece opens one drawer (phone) or the Inspector (desktop), where the 4-step sharing ladder lives.

&#91;image: Archive sheet: phone Archive with the new ADD, ARCHIVE, GU MATCH, IMPACT, COMMUNITY nav, Piece drawer with sharing ladder, You opened from the header avatar, and the post-pilot desktop workbench\]

### Bottom navigation (phone)

| Tab | Icon | Holds | Desktop key (post-pilot) |
| --- | --- | --- | --- |
| **ADD** | `plus` | Index Pieces: camera, photos (dropzone, up to 10 per batch), basics (Ch.14) | `G` `A` or `N` |
| **ARCHIVE** | `hanger` | All Pieces; filters for Rotation, Benched, Grails, Catch & Release; Clusters | `G` `X` |
| **GU MATCH** | `cards` | Today deck and Taste deck + Control Bar (D46; T7 ref pending) | `G` `M` |
| **IMPACT** | `leaf` | KPI tiles: wears, cost per wear, savings (T7 ref pending) | `G` `P` |
| **COMMUNITY** | `users` | Location-based posts (city, national, global), Co-Style; Appreciate ♡ | `G` `O` |
| Header bell | `bell` + dot | Triage Inbox: new Pieces, Co-Style Submissions, Garment ID requests (D52) | `G` `I` |
| Header avatar | initial | You: Style DNA, savings, Rotation stats, settings (D52) | `G` `Y` |

- Height 64 px + bottom inset (D48); `--surface-well` background; top hairline.
- Labels in `--type-label-nav` (Inter 10/500, 0.04em, UPPERCASE), fixed at 100% with a long-press large label (D51); the active tab gets `--ink-primary` and a 2 × 24 px `--accent-primary` indicator above its icon.
- The nav has no filled button: its only forest-green mark is the 2 × 24 px active-tab indicator, so each screen's one primary action stays unique (D39, D46).
- `G` `C` (Rotation) and `G` `W` (Grails) jump straight to Archive filters (full key list in Ch.16).

### Archive screen

| Part | Spec |
| --- | --- |
| Header | "Archive" in `--type-display-lookbook`; telemetry line "142 PIECES · 38 IN ROTATION · 12 BENCHED" |
| Filter chips | All · Rotation · Benched · Grails · Catch & Release · `adjustments-horizontal` for more (category, colour, fabric weight 1–5, season, sharing level) |
| Grid | Flush 3:4 cells sharing 1 px hairlines (`--space-0`); 2 columns on phone, auto-fill ≥ 180 px on desktop |
| Sort | Recently indexed · Most worn · Least worn · Colour |
| Batch | Long-press (phone) or `X` / Shift-click (desktop) selects; the `⌘K` bar switches to batch actions (Ch.10) |
| Desktop filter syntax | `F` opens a filter field: `status:benched`, `cat:outerwear`, `share:vault` |

### Piece drawer / Inspector

The same content in two shells: a bottom sheet on phone, the 340 px right pane on desktop (`I`).

| Section | Content |
| --- | --- |
| Images | Cutout + the Tag & Patina Proof thumbnail beside it (Ch.8) |
| Identity | Brand as entered · Piece title · season, fabric, weight 1–5 |
| Stats | Wears · CPW in VND · last worn, as three `--surface-well` tiles in mono |
| Sharing | The 4-step ladder (below) |
| Provenance | Brand and season, flat measurements in cm, source link (Open-Source only), credit to the first person who indexed it |
| Worn in | Count of Fits and Lookbooks using this Piece; tap to list them |
| Actions | Log wear · Add to Cluster · Catch & Release · ⋯ (edit, delete) |

### Sharing ladder (D12)

| Step | Icon | Who sees what |
| --- | --- | --- |
| **Vault** | `lock-square` | Only you; receipts, price and CPW live here. Default for every new Piece |
| **Mutuals** | `users` | Mutual followers and invited groups see brand, size and availability; prices stay hidden |
| **Gatekept ID** | `eye-off` | Public sees silhouette, fabric and era; brand and source stay masked until you approve a Garment ID request |
| **Open-Source** | `world` | Public sees everything except price, and may Connect the Piece |

- A 4-segment control, 44 px tall, `--radius-control`; the current step is filled ink.
- Moving **up** (more exposure) shows a one-time confirmation listing exactly what becomes visible; moving **down** is instant.
- Batch changes go through `⌘K` with the same confirmation.

### You tab

| Row | Shows |
| --- | --- |
| Style DNA | 3 Style Words, attribute weights, editable Avoids list |
| Savings | Money saved this season and the fee cap at 10% of it (D18), with a "How this is calculated" link |
| Rotation | Pieces in Rotation, average CPW |
| Settings | Theme (Warm · Cold · Neutral), haptics, try-on reference photo, open-source credits |

Open item: the method for calculating "money saved" is not yet defined; the Savings row is specified, its formula is not.

## 13. Pattern — Swipe Triage

Garblo has two decks (D31): **Today** decides what to wear now, **Taste** teaches Garblo what you like. Both use the same three swipes, buttons and keys; only the meaning of a right swipe changes.

&#91;image: Deck screens: Today deck card, Taste deck card mid-swipe, Today end-of-deck state, and the Taste batch summary\]

### Two decks

|  | **Today** | **Taste** |
| --- | --- | --- |
| Job | Pick what to wear now | Train Style DNA |
| Cards | 3–5 Fits from owned Pieces only (P3) | Open-ended, in batches of 20 |
| Source | Garblo drafts from the Archive, weather and calendar | Open-Source community Lookbooks and Garblo archetype samples; pilot cold start uses team-shot reference Lookbooks (own photos, never scraped) |
| Swipe → | **Add to Rotation** | **More like this** |
| Swipe ← | Pass | Pass |
| Swipe ↑ | Save to Cluster | Save to Cluster |
| End | "That's today's 5." + Draft more · Open Taste deck | Batch summary: Style Word changes and new Avoids, with Edit Style DNA |
| Where | GU MATCH tab, first segment (default) | GU MATCH tab, second segment |
| Credit | "@you × drafted by Garblo" | Creator credit on every card; Gatekept Pieces stay masked |

### Deck lifecycle

&#91;embedded content: Today deck lifecycle · 3 outcomes, 1 feedback loop\]

Save to Cluster and Pass also update Style DNA implicitly; only the reason sheet writes an explicit, editable rule. After each decision the next card slides in; after the last, the end state appears.

### What each gesture teaches

These readings come from the research and are pilot hypotheses `[HYPOTHESIS]` H2, H6 (Ch.19).

| Signal | Read as | Effect on Style DNA |
| --- | --- | --- |
| Fast Pass (< 0.8 s, quick flick) | Whole-look dislike | Lowers the card's palette and silhouette |
| Slow Pass (> 3.5 s, or a slot was inspected) | Near miss | Lowers only that garment pairing; may open the reason sheet (D29) |
| Approve after reading a badge | Strong like | Raises both garments and the styling rule cited |
| Slot swap, then approve | Fix, not reject | Raises the new pairing |
| Undo | Mistake | Removes the event entirely |

Phone and desktop timings are normalised per device before use, so fast keyboard sessions don't outweigh phone swipes (H6).

### Desktop flow

- `J` / `K` move · `E` / `#` / `H` decide with auto-advance · `1`–`4` add a reason · `Space` peeks a Piece · `Z` undoes.
- Keyboard advance uses `--spring-keyboard` (220 ms, no overshoot), so 4 cards a second stay readable.
- 4-up compare (`⌥→`) is `[V2]`.

### Sync and offline

- Every decision is an event in an append-only log; phone and desktop show the same deck position within about a second.
- Offline swipes queue on the device under the line "Offline · changes sync when you reconnect."; nothing is lost.
- If two devices decide the same card differently, the later decision wins and the earlier one goes to a "Needs review" Cluster, never silently dropped.
- Stop at card 3 on the phone and the desktop opens at card 3.

### Pilot metrics

| Metric | Definition |
| --- | --- |
| Acceptance rate | Add to Rotation ÷ Today cards shown |
| Time to decide | Median ms per card, per device |
| Near-miss share | Slow Passes ÷ all Passes |
| Reason mix | Share of each reason chip |
| Undo rate | Undos ÷ decisions |
| Taste depth | Taste cards swiped per active user per week |

## 14. Pattern — Ingestion & Onboarding

A new user sees value before doing any closet work: 20 Taste swipes seed Style DNA, 5 basics unlock the first Today deck (D33). Pieces arrive through 3 channels in the pilot (D32), land privately in the Vault, and wait in the Triage Inbox until the user confirms Garblo's tag guesses.

&#91;image: Onboarding sheet: welcome, Taste warm-up, Style DNA reveal, basics picker, Index sheet over Gu Match, and Triage Inbox confirming tags\]

### Onboarding steps

1. **Welcome.** One promise ("Wear more of what you own.") and one privacy line ("Everything you add stays in your Vault until you share it."). CTA: Start with your taste.
2. **Taste warm-up.** 20 Taste cards with a progress bar; Skip appears after 10. Same three swipes; no reason sheet during onboarding.
3. **Style DNA reveal.** 3 Style Words as editable chips; "Edit any time in You › Style DNA."
4. **Pick 5 basics.** Team-curated basics grid; tap to claim, or Snap instead. Each claimed basic becomes a Piece marked `BASIC` with a generic cutout the user can replace later.
5. **Just-in-time permissions.** Coarse location for weather when the first Today deck loads; calendar only when the user taps an occasion chip; camera and photos only when a channel needs them. Each request carries a one-line reason.
6. **First Today deck.** Drafted from the 5+ Pieces. Target: under 3 minutes from install `[HYPOTHESIS]`.

### Index Piece channels (D32)

| Channel | Pilot | How it works | Lands as |
| --- | --- | --- | --- |
| Snap a Piece | ✓ MVP | One garment per photo; framing guide; on-device cutout (Ch.8) | Vault + Triage Inbox |
| From camera roll | ✓ MVP | Multi-select outfit photos; each garment is cut out as its own Piece | Vault + Triage Inbox, one row per garment |
| Pick basics | ✓ MVP | \~30 generic basics with neutral cutouts, curated by the team | Vault, marked `BASIC` |
| Forward a receipt | V2 | Personal forwarding address; parsers for Shopee, Lazada, Tiki | Hidden in pilot |
| Browser extension / paste link | V2 | Capture from shop pages on desktop | Hidden in pilot |

V2 channels are hidden, not shown disabled: no "coming soon" rows.

### Triage Inbox

| Aspect | Rule |
| --- | --- |
| Sections | New Pieces · Co-Style Submissions (Ch.15) · Garment ID requests |
| Garblo's guesses | Auto-tags show with a dotted `--accent-synthesis-ai` underline until confirmed; low-confidence fields end in "?" |
| Actions | Confirm (→ / `E`) · Discard (← / `#`) · Edit (tap); Confirm all for a batch |
| Draftable | A Piece enters Garblo's drafts once its category and fabric weight are confirmed |
| Desktop | `G` `I` opens it; `J` / `K` move, `X` selects, `E` confirms |
| Never blocks | Cut-out and tagging run in the background; the user can keep swiping |

### Minimum metadata

| Tier | Fields | Typing needed |
| --- | --- | --- |
| Auto (Tier 1) | Category, colour profile, silhouette and length, fabric and weight 1–5 | None: confirm or fix |
| Optional (Tier 2) | Brand, price, purchase date, size | Optional; CPW shows "—" until a price exists |

### Empty states

| Where | Copy | Actions |
| --- | --- | --- |
| Archive, no Pieces | Archive unindexed. Snap a Piece or pick basics to start. | Snap a Piece · Pick basics |
| Today, fewer than 5 Pieces | Index 5 Pieces to unlock Today. `2 / 5` | Index Piece · Open Taste deck |
| Inbox empty | Inbox clear. | — |

### Rules

- ✓ Every new Piece starts in the Vault (P5).
- ✕ Brand and price are never required.
- ✓ Permissions are asked at the moment of use, never all up front.
- ✓ Processing never blocks the user; progress shows in the Inbox count.

## 15. Pattern — Co-Styling, Sharing & Provenance

In the pilot, friends style each other only among Mutuals; credit always travels with a Fit, borrowed Pieces never distort the wearer's CPW, and the owner decides every reveal (D34). Passing a friend's suggestion is silent, so styling stays low-stakes.

### Pilot scope (D34)

| Feature | Pilot | Note |
| --- | --- | --- |
| Co-Style from Mutuals | ✓ MVP | A Mutual styles a Fit from your Archive and sends it to your Inbox |
| Connect a Piece | ✓ MVP | Pull an Open-Source or Mutuals-level Piece into your Cluster or Canvas as a reference |
| Request Garment ID | ✓ MVP | Ask the owner to reveal a Gatekept brand and source |
| Catch & Release | ◐ Tag only | Mutuals see the tag and can send an interest ping; no payments or deals in the app |
| SOS style bounty (public) | V2 | Depends on karma hypothesis H4 |
| IRL borrow requests | V2 | Needs lending rules, trust and dispute handling |

### Co-Style flow

&#91;embedded content: Co-Style flow · 2 people, 6 steps\]

The owner's lane (tinted) holds every decision; the stylist only builds and sends. A Pass never reaches the stylist, and wear counts change only on the owner's own Pieces.

### Co-Style rules

| Rule | Spec |
| --- | --- |
| Who | Mutuals only (both follow each other); the owner can switch Co-Style off in You › Settings |
| What the stylist sees | Your Pieces at Mutuals level or above. Never Vault Pieces, prices, receipts or CPW; In laundry and Away Pieces are hidden |
| Wildcards | Up to 2 Pieces from the stylist's own Archive, shown as Borrowed references |
| Note | Optional, ≤ 140 characters |
| Arrives | Inbox › Co-Style Submissions, as a card with a cobalt frame and "STYLED BY @mia" |
| Your choices | Add to Rotation · Save to Cluster · Pass, with the usual swipes, buttons and keys |
| Stylist is told | Only "Added to Rotation" and "Worn". Passes are never reported |
| Credit | Card: "Styled by @mia"; after Log Fit: "Worn by @you · Styled by @mia". Credit cannot be removed |
| CPW | Wears and CPW change only on your owned Pieces; a wildcard adds +1 to its owner's "added to wardrobes" count and offers you "Save as Grail" |

### Who sees what

| Piece level | You | Mutuals | Public |
| --- | --- | --- | --- |
| **Vault** | ✓ Everything | ✕ Nothing | ✕ Nothing |
| **Mutuals** | ✓ Everything | ◐ Brand, size, availability; no price | ✕ Nothing |
| **Gatekept ID** | ✓ Everything | ◐ Same as Mutuals | ◐ Silhouette, fabric, era; brand and source masked |
| **Open-Source** | ✓ Everything | ✓ All but price | ✓ All but price; may Connect |

### Connect a Piece

- Available on Open-Source Pieces (anyone) and Mutuals-level Pieces (Mutuals only).
- Creates a Borrowed reference: dashed cobalt frame and owner handle (Ch.9).
- Borrowed references appear in Garblo's Today drafts only when Wildcard is on, and are always marked (P3).
- The first indexer's credit travels through every Clone & Remix.

### Request Garment ID

1. A viewer taps a masked brand: "Ask @owner to reveal brand and source?" with an optional note.
2. The owner sees it in Inbox › Garment ID requests: **Reveal to @viewer** or **Decline**.
3. Reveal shows brand and source to that viewer only. Decline is silent; unanswered requests expire after 14 days.
4. One open request per viewer per Piece.

### Catch & Release (tag only)

- The owner flags a Piece; Mutuals see the `recycle` icon and "Catch & Release".
- "I'm interested" sends an interest ping to the owner's Inbox. No contact details are shared automatically; any deal happens outside Garblo.
- Garblo may suggest the tag inside the Benched filter, but never flags a Piece by itself.

### Safety

- ✓ Block and Report on every profile, Submission and ping.
- ✓ Blocking removes Mutual status and withdraws Archive access at once.

## 16. Platform Ergonomics

The phone is for capture and quick decisions with one thumb; the desktop web workbench is for sorting, batch work and planning with two hands (P7). Every action exists on both, with a gesture or button on the phone and a browser-safe key on desktop (D35); one event log keeps them in step.

### Who does which job

| Job | Primary | Secondary | Why |
| --- | --- | --- | --- |
| Daily Today deck | Phone | Desktop | 1–5 minute sessions, one hand, in front of a mirror |
| Capture Pieces | Phone | Desktop (file drop) | The camera is in the pocket |
| Taste deck | Phone | Desktop | Swiping suits the thumb |
| Triage Inbox and batch tagging | Desktop | Phone (single items) | Keyboard and multi-select are much faster |
| Archive organising and sharing changes | Desktop | Phone (single Piece) | Needs the 3-pane view and `X` selection |
| Canvas and Clusters | Desktop | Phone (light edits) | Large screen for layering and comparing |
| Co-Style building | Either | — | Canvas on desktop, quick picks on phone |

### Action parity

| Action | Phone | Desktop web | Event |
| --- | --- | --- | --- |
| Add to Rotation / More like this | Swipe → or ✓ button | `E` or `→` | `decision.rotation` |
| Pass | Swipe ← or ✕ button | `#` or `←`, then `1`–`4` | `decision.pass` |
| Save to Cluster | Swipe ↑ or Save button | `H` or `↑` | `decision.cluster` |
| Pin anchor + shuffle | Double-tap, then Shuffle | `L`, then `⌘Enter` | `fit.anchor` |
| Swap a slot | Sideways scrub | `Tab` to slot, then `[` / `]` | `fit.slot_swap` |
| Peek a Piece | Tap | `Space` | — |
| Log Fit | ⋯ › Log Fit | `W` | `fit.worn` |
| Index Piece | ADD tab | `N` or drop a file | `piece.created` |
| Batch select | Long-press + drag | `X`, Shift-click, `⌘A` | local only |
| Undo | Shake or toast | `Z` or `⌘Z` | `event.revert` |

Native trackpad flicks and Force Touch feedback are `[LATER]` (D14).

### Shortcut registry

&#91;image: Desktop web shortcut map (post-pilot): keyboard with keys colour-coded by group: triage, go-to chords, Pieces and views, Garblo anchor and Draft Fits, global\]

| Group | Keys |
| --- | --- |
| Global | `⌘K` command bar · `?` shortcut list · `Esc` close or clear · `Z` / `⌘Z` undo |
| Go to (`G`, then within 1 s) | `A` Add · `X` Archive · `M` Gu Match · `P` Impact · `O` Community · `I` Inbox (bell) · `Y` You (avatar) · `C` Rotation · `W` Grails — post-pilot (D44, D46) |
| Triage | `J` / `K` next / previous · `E` / `→` Rotation · `#` / `←` Pass · `H` / `↑` Cluster · `1`–`4` reason · `Space` peek · `Tab` slot · `[` / `]` alternative |
| Garblo | `L` lock anchor · `⌘Enter` reshuffle unlocked slots |
| Pieces and views | `N` Index · `W` Log Fit · `I` Inspector · `V` deck ↔ Canvas · `F` filter · `X` select · `⇧J` / `⇧K` extend · `⌘A` all · hold `P` fabric loupe |

### Shortcut rules

- ✓ Match on the **physical key** (`KeyboardEvent.code`) and ignore events while an input method is composing, so Vietnamese Telex or VNI typing never triggers or blocks a shortcut.
- ✓ Single-key shortcuts pause while a text field has focus; only `Esc`, `⌘K` and `⌘Enter` still work there. After typing, letters stay suppressed for 1 s.
- ✕ Never bind keys the browser owns (`⌘L`, `⌘T`, `⌘W`, `⌘R`, `⌘D`, `⌘U`, `⌘B`, `⌘I`).
- ✓ Every key hint is shown in the UI as a `--radius-key` cap, and `?` lists all of them.
- ✓ On Windows and Linux, `⌘` reads as `Ctrl`.

### Focus management

- `Space` opens a preview without moving focus from the list; `Esc` closes it and focus stays put.
- Opening the Inspector (`I`) keeps focus in the centre pane until the user tabs into it.
- Every focusable element shows `--focus-ring` on keyboard focus (Ch.6).
- The Command Bar returns focus to where it was opened.

### Sync and continuity

- Every change is an event in an append-only log; target cross-device update ≤ 1 s in the pilot.
- Deck position, active filters, the open Piece and Canvas drafts follow the user to the other device.
- Same card decided differently on two devices: the later decision wins, the earlier goes to "Needs review" (Ch.13).
- Phone: offline queue with the "Offline" line. Desktop web: a read-only cache plus an offline banner; edits wait until the connection returns.

## 17. Accessibility & Localization

Garblo targets **WCAG 2.2 AA** on phone and desktop web, and every format follows the user's device region rather than a fixed country (D36). Colour never works alone: the colour-blind check below shows why every status keeps its symbol and label.

### Accessibility requirements

| Area | Requirement | Specified in |
| --- | --- | --- |
| Contrast | Text ≥ 4.5 : 1, UI parts ≥ 3 : 1 in all 6 palettes | Ch.4 |
| Colour independence | Every colour-coded state also has a symbol and a word | Ch.3, Ch.10 |
| Target size | ≥ 44 × 44 px, ≥ 8 px apart | Ch.6 |
| Motion | A reduced-motion version of every animation | Ch.7 |
| Gestures | Every swipe has a button twin; no path-shaped gesture is required (WCAG 2.5.1) | Ch.9 |
| Dragging | Canvas moves also work by select + arrow keys or a Move menu (WCAG 2.5.7) | Ch.16 |
| Keyboard | Everything works by keyboard; no focus traps | Ch.16 |
| Focus not hidden | The floating Control Bar never covers the focused element: lists get bottom padding equal to the bar's height (WCAG 2.4.11) | Ch.10 |
| Screen readers | Labels for cards, Pieces and badges; polite live regions for Garblo's status and toasts | Ch.9–Ch.11 |
| Text size | Works at 200% text (Dynamic Type, Android font scale, browser zoom); at large sizes the card's badges move below the card instead of overlapping it | Ch.5, Ch.9 |
| Timing | Undo toast pauses on hover or focus; no other time limits | Ch.11 |
| Haptics | Never the only signal | Ch.7 |
| Image text | Every Piece gets generated alt text ("Burgundy cotton T-shirt, short sleeves") that the owner can edit; try-on previews are announced as AI-generated | Ch.8 |
| Language | The UI is marked as English; user text detected as Vietnamese is marked `lang="vi"` so screen readers pronounce it correctly | Ch.3 |

Text-size exception (D51): bottom-nav labels stay at 100% so all five fit; every tab keeps its accessible name and the long-press large label. Every other style passes the 200% check (Ch.5 › Text size).

### Colour-blind check

&#91;image: Colour-blind simulation: forest-green primary plus five status colours under typical vision, protanopia, deuteranopia and tritanopia, with three flagged pairs\]

| Pair | Weakest vision type | Difference (ΔE) | What carries the meaning |
| --- | --- | --- | --- |
| ● CPW optimal vs ▲ Benched | Protanopia | 15 | Shape (● vs ▲) and the label |
| ◉ Garblo AI vs ◌ Social | Protanopia | 12 | Shape and the status line |
| ■ Primary (forest) vs ● CPW optimal | Deuteranopia | 15 | Form: a filled button vs a dot with a word; never a status dot inside a primary control (DS-07) |
| ◯ Anchor ring on a light card (1.1 : 1 even in typical vision) | Tritanopia | Lime turns near-white | The `lock` icon on the Piece |

Result: no meaning is lost, provided the symbol rules in Ch.3, Ch.9 and Ch.10 hold and forest green stays the only filled control colour (D39). Rechecked with forest green on 2026-10-29 (CIE76 ΔE, Machado 2009). A ΔE above about 20 reads as clearly different colours.

### Testing

- ✓ Automated checks (axe-core on web, platform accessibility scanners on iOS and Android) run on every build.
- ✓ A manual pass with VoiceOver, TalkBack and NVDA before each pilot release.
- ✓ At least two pilot participants who use assistive technology are invited to sessions (Ch.19).

### Formats (D36)

| Item | Rule | Device region Vietnam | Device region US |
| --- | --- | --- | --- |
| Currency | The user's wallet currency (pilot default VND, D16), formatted by locale; no decimals for VND | 45.000 ₫ | ₫45,000 |
| Numbers | Locale grouping | 1.240.000 | 1,240,000 |
| Dates in UI | Locale medium date | 28 Oct 2026 | Oct 28, 2026 |
| Dates in telemetry | Fixed, unambiguous | 28 OCT | 28 OCT |
| Time | Locale clock | 14:00 | 2:00 PM |
| Temperature | Locale unit | 14°C | 57°F |
| Week starts | Locale | Monday | Sunday |
| Measurements | Locale system | cm | in |

- ✓ Use the platform formatters (`Intl`, iOS and Android locale APIs); never format numbers or dates by hand.
- ✓ Strings use ICU plural and select rules; never build sentences by concatenation.
- ✓ Layouts allow 40% longer strings, ready for future languages.
- Left-to-right only in the pilot; right-to-left support is `[LATER]`.

### Consent and privacy screens

- Plain-language consent for the try-on reference photo, location and calendar, each asked at first use (Ch.8, Ch.14).
- Every consent can be withdrawn in You › Settings, and withdrawal deletes the related data.
- ⚠ The team should review these screens against Vietnam's personal data protection rules (Decree 13/2023/NĐ-CP) before the pilot; this handbook is not legal advice.

### Open-source credits screen

| Item | Licence | Shown as |
| --- | --- | --- |
| Newsreader, Inter, JetBrains Mono | SIL Open Font License 1.1 | Name, copyright line, full `OFL.txt` |
| Tabler Icons | MIT | Name, copyright line, full licence text |

Location: You › Settings › Open-source credits.

## 18. Token Implementation

One source, two outputs: the W3C DTCG JSON in `garblo-tokens/tokens/` is the only place a value changes; scripts turn it into one Flutter Dart file for the app (D37) and into the Garblo Design System artifact for design work (D38). `[DECIDED]`

&#91;embedded content: token pipeline · 1 source, 3 build scripts, 2 outputs\]

Solid arrows run today; the dashed path is the Style Dictionary build, kept ready but not yet run.

### Package layout (garblo-tokens v0.2)

```text
garblo-tokens/  (v0.2)
├─ tokens/
│  ├─ core/            color · space · radius · size · layout · typography · motion · shadow  (primitives)
│  └─ themes/          warm|cold|neutral × light|dark  (semantic, alias the core ladders)
├─ scripts/gen_dart.py  regenerates the Dart file from tokens/
├─ style-dictionary.config.mjs   optional Style Dictionary v5 build (flutter transform group)
├─ build/flutter/lib/garblo_tokens.dart   the file the app imports
├─ pubspec.fonts.yaml   Newsreader · Inter · JetBrains Mono asset block
└─ README.md            usage + changelog
```

### Three layers, one name

Components read semantic tokens only; a hex value in component code fails review.

| Layer | Lives in | Pattern | Example |
| --- | --- | --- | --- |
| Core (primitive) | `tokens/core/*.json` | `color.{theme}.{mode}.{step}` | `color.warm.light.canvas` = #FDFAF5 |
| Semantic | `tokens/themes/{theme}-{mode}.json` | `{role}.{name}` → alias of a core step | `surface.canvas` → `{color.warm.light.canvas}` |
| Flutter | `garblo_tokens.dart` | camelCase field on a class | `GarbloColors.surfaceCanvas` |
| Design System artifact | `project/tokens.json` | kebab-case, one value per theme | `surface-canvas` |

Alpha surfaces keep their base colour and carry the opacity in `$extensions.garblo.alpha`: HUD glass 0.86 light / 0.88 dark, image scrim 0.10, overlay scrim 0.32.

### What the Dart file exposes

| Class | Holds | Use |
| --- | --- | --- |
| `GarbloColors` | 22 colours × 6 palettes incl. `accentPrimary`, `accentPrimaryPressed`, `onPrimary`; a `ThemeExtension` with `lerp` | `Theme.of(context).extension<GarbloColors>()!` |
| `GarbloSpace` | `s0`–`s9` (0–96) | padding and gaps |
| `GarbloRadius` | `media` 1 · `key` 3 · `control` 8 · `hud` 12 · `pill` 9999 | corners (D23) |
| `GarbloSize` | header 56, nav 64, button 48, fab 48, chips 32 and 36, pill 24, rail 52, avatar 32, target 44, icons 16/20/24; workbench 340 and 260 | component sizes (D48) |
| `GarbloLayout` + `GarbloGrid` | breakpoints 600 and 1024, 3 grids, spans 358/175/114, reference frame and insets, `offsetFloating` 16, `gridFor(width)` | layout (Ch.6) |
| `GarbloType` | 11 text styles incl. `monoFigure`, `labelButton`, `labelNav` | every text widget |
| `GarbloMotion` | 4 springs, 6 durations incl. `gestureSettle`, 3 curves, swipe thresholds | animations (Ch.7) |
| `GarbloShadow` | 3 garment drop-shadows + the sheet shadow | cutouts and sheets |

```dart
MaterialApp(
  theme: ThemeData(extensions: [GarbloColors.of(GarbloTheme.warm, Brightness.light)]),
  darkTheme: ThemeData(extensions: [GarbloColors.of(GarbloTheme.warm, Brightness.dark)]),
);
final c = Theme.of(context).extension<GarbloColors>()!;
Container(color: c.surfaceCard, padding: const EdgeInsets.all(GarbloSpace.s4));
```

Theme switching (D21) swaps the extension; `lerp` gives a cross-fade, cut to 150 ms under reduced motion.

### Change a token

1. Edit the value in `tokens/core/` (or the alias in `tokens/themes/`); never edit the Dart file.
2. Run `python3 scripts/gen_dart.py` and check the diff touches only the token you meant.
3. Re-run the contrast check (Ch.4) for every theme-mode the change reaches.
4. Update the Design System artifact's `tokens.json` with the same value.
5. Bump the package version and log it (Ch.19).

### Known limits

- Style Dictionary was not run: the npm registry was unreachable while the package was built, so `gen_dart.py` produced the Dart file. The config uses Style Dictionary v5's built-in `flutter` transform group and `flutter/class.dart` format and should be tried before the pilot build. `[MEDIUM]`
- The Design System artifact's `tokens.json` is written by a separate script from the same values; until one pipeline writes both, step 4 is manual.
- Motion has no family in the Design System artifact; springs and durations live only in the Dart file and Ch.7.

v0.2 (2026-10-30, DS-CR-01) added the forest-green primary, `GarbloLayout`, the new sizes (nav 56 → 64; `navHeight` and `touchMin` stay as deprecated aliases) and three type styles. Sizes, layout and colours now come straight from the JSON; the type styles in `gen_dart.py` are still written by hand and are the next thing to generate.
