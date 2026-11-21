# Gravity usage baseline, run of 2026-11-13

- **Collected:** 2026-11-13, from Claude Code session logs dated 2026-10-03 to 2026-11-12 (the logs were on the default 30-day retention, so nothing older survived).
- **Script version:** `usage/session_usage.py` as of 2026-11-13 (the version that skips built-in commands such as `/clear` in `first_prompt`).
- **Rules in force:** Gravity's old rules, before milestone 2's freeze. Planning sessions are counted inside B until 2026-11-12.

| File | Contents |
|---|---|
| `sessions-tagged.csv` | 333 sessions, one row each, tagged by role (build, review, other), issue and PR. |
| `issues-br.csv` | B and R per issue for the 69 issues that have both a build and a review. |

Result: median B/R about 4 review rounds' worth per build (middle half 2.9-6.7); builder-side usage about two-thirds of build plus review.

## Tagging exceptions in this run

- Issue #505's build session (2026-11-13) opened with a pasted block of rules instead of `/build-issue 505`. Tagged by hand: role = build, issue = 505.
