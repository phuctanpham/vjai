# AI-006: PII scrubber v0 and offline evaluation harness

> **Owner:** AI Engineer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **11** (can run in parallel with BE-014…BE-018 once AI-005 lands)  
> **Blocked by:** [AI-005](AI-005-model-ports-and-fakes.md)  
> **Source:** UC-05 TAC-05.3, 05.4 · UC-06 TAC-06.4 · UC-02 TAC-02.1, 02.4 · UC-07 AC-07.3 · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §2 C05-06, C05-07, C11 · spec P5-A03, P5-A04 (this card prepares them)

## Why

Two AI deliverables need no model, no provider and no database, and both gate P5:

1. **PII scrubber.** No prompt may reach an LLM with emails, phone numbers or
   names (TAC-05.4). A deterministic rule-based v0 can be built and red-teamed now.
   AI-003 then only adds name detection behind the same interface.
2. **Evaluation harness.** AI-001 must show calibrated confidence and AI-003 must
   beat the rule-based generator's **Add to Rotation rate** (Fits kept with
   `LIKE_SAVE`; a decision on an outfit, not a person). Both need a fixed
   evaluation set and metrics. Building the harness against the AI-005 fakes gives
   the baseline numbers before any model exists.

## Scope

| Part | Content |
|---|---|
| `backend/app/ai/scrubber.py` | `scrub(text) -> ScrubResult(text, redactions: list[kind])`: emails, phone numbers (VN `+84`/`0` mobile formats and E.164), URLs with query strings, street numbers with a street word (EN/VI); replaced by `[EMAIL]`, `[PHONE]`, … Idempotent: `scrub(scrub(x).text) == scrub(x)`. Never logs the input |
| Red-team fixtures | `backend/tests/ai/fixtures/pii_redteam.jsonl`: ≥ 60 cases in English and Vietnamese, each with the expected output, including false-positive guards (sizes "38", times "9:30", prices) |
| Name detection | Interface only: `NameDetector` port with a `NoopNameDetector`; a real one needs SP-7 and a decisions.md entry |
| `backend/app/ai/eval/` | `extraction_eval(extractor, dataset)`: type-code accuracy per group, attribute accuracy, expected calibration error (10 bins), p95 latency. `deck_eval(generator, sessions, judgments)`: Add to Rotation rate@8, owned-only violations (must be 0), determinism check |
| Datasets | Small synthetic JSON datasets in `backend/tests/ai/fixtures/eval/` (no real photos, no personal data); real sets are AI-001 and AI-003 work |
| Command | `uv run python -m app.ai.eval --suite extraction|decks --report out.json`: deterministic JSON report; the fakes' report is committed as the baseline |

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| AI-006-S01 | Every red-team case gives its expected output; recall on PII kinds = 100 % on the fixture set | `tests/ai/test_scrubber.py` |
| AI-006-S02 | False-positive guards (sizes, times, prices, item type labels) are left unchanged | `tests/ai/test_scrubber.py` |
| AI-006-S03 | Idempotent; output never contains the original PII substring | `tests/ai/test_scrubber.py` |
| AI-006-S04 | Gu Match side effects (BE-015) pass `raw_prompt` through `scrub` before any `LookNamer` or `ContextSource` call (spy port) | `tests/ai/test_scrubber_wiring.py` |
| AI-006-S05 | `extraction_eval` on the fake extractor gives the committed baseline exactly; ECE is computed correctly on a hand-made dataset | `tests/ai/test_eval.py` |
| AI-006-S06 | `deck_eval` reports 0 owned-only violations for the rule generator, and flags a deliberately bad generator | `tests/ai/test_eval.py` |

## Allowed files

`backend/app/ai/scrubber.py`, `backend/app/ai/eval/`, `backend/tests/ai/`,
`backend/app/workers/gu_match.py` (scrubber call only, after BE-015), report.

## Anti-scope

No LLM or NER model, no numpy/scikit-learn (metrics in plain Python), no real user
data in fixtures.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
