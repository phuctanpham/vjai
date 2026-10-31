# AI-005: Model ports and deterministic fakes

> **Owner:** AI Engineer (+ Backend Developer as reviewer)  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **5** (before BE-014 and BE-015, which call these ports)  
> **Blocked by:** [BE-011](BE-011-mock-platform-core.md)  
> **Source:** Flow Spec v2.8 T4 › Side effects; UC-02, UC-06 · AI-001, AI-003 (the real models that later sit behind these ports)

## Why

The side-effect workers (BE-014 Studio, BE-015 Gu Match) must not know whether a
fixture, a rule or a GPU model answers. If the ports are fixed now, with fakes that
return what the phone's Phase 2 fakes return, then P5 changes **only the adapter**,
and the mobile app sees no contract change. (P4-B05's done-when says the same:
"swapping in P5 models changes only the worker".)

## Ports (`backend/app/ai/ports.py`)

| Port | Input (no user ID, no image outside the sanitized store, TAC-02.7) | Output | Fake (`backend/app/ai/fakes.py`) | Real (later) |
|---|---|---|---|---|
| `OutfitExtractor` | `ExtractionInput(asset_id, mime_type, content: bytes \| None)` | `list[ExtractedPiece(name, type_code, color, material, style_tag, confidence)]` or `ExtractionFailed` | `FixtureOutfitExtractor`: the phone's three sample sets; set = `stable_hash(content) % 3`, or `stable_hash(asset_id.encode()) % 3` with no bytes (CHG-014 Q3); scripted outcomes for scenarios | AI-001 |
| `PersonDetector` | same input | `PersonResult(contains_person: bool)` | Always `False` (CHG-006 G-04: pose/background end `SKIPPED_NO_PERSON`) | AI-001 / AI-004 |
| `ContextSource` (one per card kind: occasion, weather, rain, commute) | `ContextRequest(city_id?, window_start?, window_end?, occasions, ambient_temp_c?)` | `ContextCard(kind, title, detail, is_missing)` | `FixtureContextSource`: the phone's fixture cards from `MockGuMatchRepository`; scenario `WEATHER_MISSING` returns `is_missing=True` | AI-003 (weather API, calendar, mobility) |
| `OutfitGenerator` | owned non-archived items with `days_unworn`, context | `≤ 8` looks of `{slot_role, item_id}` + `match_pct` + `highlight_reason?` + title | `RuleOutfitGenerator`: port of `FakeCandidateGenerator` (A-03: dormant-first; one top + one bottom + one pair of shoes; match % = 70 + round(0.3 × days unworn of the least-worn Piece), cap 95; template titles) | BE-004 rule generator (P4), AI-003 v2 (P5) |
| `LookNamer` | look attributes, occasions | title | Template titles of `FakeCandidateGenerator._title` | AI-003 LLM naming |

Rules for every port: pure and deterministic for the same input and the same
`model_version` string; no network; no clock (time comes in the input); a
`model_version` on every output so results can be traced (DB handbook §2 C11, AI provenance).

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| AI-005-S01 | `FixtureOutfitExtractor` picks the same sample set as the phone for the golden byte fixtures (CHG-006 G-01 parity) | `tests/ai/test_fakes.py` |
| AI-005-S02 | With no bytes, the set is chosen from `asset_id`, the same every time | `tests/ai/test_fakes.py` |
| AI-005-S03 | Every fake piece's `type_code` is in the item-type catalog; confidence is in 0..1 | `tests/ai/test_fakes.py` |
| AI-005-S04 | `RuleOutfitGenerator` equals the Dart `FakeCandidateGenerator` on the golden decks (items, order, match %, highlight, titles) | `tests/ai/test_rule_generator.py` |
| AI-005-S05 | Property tests: owned, non-archived only (I6); ≤ 8; same input, same deck; match % in 0..100 | `tests/ai/test_rule_generator.py` |
| AI-005-S06 | Context fakes return kinds in the fixed order; a missing source gives `is_missing=True`, never an exception (TAC-06.2) | `tests/ai/test_fakes.py` |
| AI-005-S07 | Port inputs carry no `user_id` field (a static check over the dataclasses) | `tests/ai/test_ports.py` |

Golden fixtures (sample sets, byte hashes, decks) come from
[TASK-012](../mobile/TASK-012-shared-golden-fixtures.md). Until it lands, copy the
expected values from the Dart tests and cite the test name and commit in the code.

## Allowed files

`backend/app/ai/` (`ports.py`, `fakes.py`, `rule_generator.py`, `fixtures.py`),
`backend/tests/ai/`, report `docs/reports/AI-005-ai-engineer.md`.

## Anti-scope

No model weights, no ML or numeric dependencies (numpy, torch, onnx), no LLM
calls, no embeddings. Pose/scene models, calibration and the PII scrubber are
AI-001, AI-003 and AI-006.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
