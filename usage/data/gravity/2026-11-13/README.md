# Gravity usage baseline, run of 2026-11-13

- **Collected:** 2026-11-13, from Claude Code session logs dated 2026-10-03 to 2026-11-12 (the logs were on the default 30-day retention, so nothing older survived).
- **Script version:** `usage/session_usage.py` as of 2026-11-13 (the version that skips built-in commands such as `/clear` in `first_prompt`).
- **Rules in force:** Gravity's old rules, before milestone 2's freeze. Planning sessions are counted inside B until 2026-11-12.

| File | Contents |
|---|---|
| `sessions-tagged.csv` | 333 sessions, one row each, tagged by role (build, review, other), issue and PR. Two rows (`f5a64819…`, `ca59ff0a…`) hold a line break inside a quoted field, from the script version that kept them, so count rows with a CSV reader: `wc -l` gives 342. |
| `issues-br.csv` | B and R per issue: 74 rows, of which 69 have both a build and a review. The other five (280, 273, 274, 312, 504) have builds only, so their `R_weighted` is 0 and `B_over_R` is empty. |

Result: the median build costs about 4 review rounds (middle half 2.9-6.7), counting B against one review round, `B_weighted / (R_weighted / review_sessions)`. The file's `B_over_R` column is B against all of an issue's reviews together, `B_weighted / R_weighted`: median 1.71, middle half 1.17-2.22. Builder-side usage is about two-thirds of build plus review.

## Tagging exceptions in this run

36 rows have `confidence=low`: the role or issue was read from the prompt's wording, not from a command. Twelve of them are build or review sessions, so they count in B and R:

| session | date | role | issue | PR | why |
|---|---|---|---|---|---|
| `520b0813` | 2026-10-17 | review | 103 | 126 | review in prompt |
| `452b538a` | 2026-10-17 | review | 102 | 125 | review in prompt |
| `434d01c4` | 2026-10-19 | build | 218 | | build/fix/decision in prompt |
| `ad1314fa` | 2026-10-20 | build | 255 | | build/fix/decision in prompt |
| `b644b955` | 2026-10-20 | review | 201 | 284 | review in prompt |
| `24f19398` | 2026-10-20 | build | 201 | 284 | fix after review of PR 284 |
| `33e794a9` | 2026-10-23 | build | 274 | | issue #274 prompt |
| `9ed19ae3` | 2026-10-26 | build | 447 | | build/fix/decision in prompt |
| `53b6dca0` | 2026-10-27 | build | 491 | | build/fix/decision in prompt |
| `ff7e6840` | 2026-11-04 | review | 495 | 569 | review in prompt |
| `b3bcd1e3` | 2026-11-04 | review | 495 | 571 | review in prompt |
| `cc4fbfe6` | 2026-11-04 | review | 495 | 570 | review in prompt |

