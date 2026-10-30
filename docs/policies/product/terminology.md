# Terminology

Use the **code symbol** in new code, tests, Gherkin steps and documents. The
[TASK-001 canonical terms](../../tasks/mobile/TASK-001-product-domain-alignment.md#canonical-terms)
and Flow Spec T2/T7 define the wardrobe product vocabulary.

## Wardrobe product terms

| Term | Code symbol | Definition |
|---|---|---|
| Wardrobe item | `WardrobeItem` | A garment the user owns, saved from review or seeded |
| Item group | `ItemGroup` | `tops`, `bottoms`, `shoes`, `bags`, `hats`, `accessories` |
| Item type | `ItemType` | A type such as Shirt or Sneakers belonging to one group |
| Upload batch | `BatchStatus` | The lifecycle of one Add session |
| Photo tray | `PhotoTray` | The 1–10 staged photos of a batch, in pick order |
| Media asset | `MediaAsset` | One staged photo with its slot |
| Privacy consent | `PrivacyConsent` | Consent given before analysis |
| Analysis task | `AnalysisTask` | `outfitExtraction`, `poseEstimation` or `backgroundAnalysis` |
| Extracted item | `ExtractedItem` | An editable AI draft before it is saved |
| Last worn input | `LastWornInput` | The optional answer given during review |
| Wear event | `WearEvent` | One confirmed wear of a set of items on a date |
| Dormancy | `DormancyRules` | Days since last wear or save |
| Occasion | `Occasion` | A selectable styling occasion |
| Styling context | `StylingContext` | Occasion chips and the free-text prompt |
| Session path | `SessionPath` | `promptLed` or `zeroInput` |
| Gu Match session | `GuMatchSession` | One styling session that deals a deck |
| Context card | `ContextCard` | An occasion, weather, rain or commute card |
| Outfit candidate | `OutfitCandidate` | A look built only from owned items |
| Swipe status | `SwipeStatus` | The state of an outfit candidate |
| Card action | `CardAction` | A pass, like/save, customize or try-on action |
| Pillar | `Pillar` | `add`, `wardrobe`, `guMatch`, `impact`, `community` |

## Legacy terms

The following terms belong to the retained, unrouted dating feature tree.
They are not valid vocabulary for new wardrobe work and must not be used to
rename wardrobe concepts:

`Profile`, `Candidate`, `SwipeType`, `DiscoveryState`, `Match`,
`Conversation`, `Message`, `AuthSession`, `OnboardingDraft`, `Report`, and
`Block`.

## UI states
Every screen that loads data uses these state names: `initial`, `loading`, `loaded`, `empty`, `error`.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Moved from `docs/archive/legacy/architecture/GLOSSARY.md` (domain terms only; technical terms moved to architecture.md); added Onboarding draft, Report, Block |
| 2026-10-30 | [CHG-007](../../changes/CHG-007-documentation-authority-migration.md) | Migrated the active vocabulary to the wardrobe/outfit product and marked dating terms as legacy |
