---
description: Plan one GitHub issue at its level and post the plan, without building it
argument-hint: <issue number>
---

Plan issue #$ARGUMENTS in this repository, the one this session runs in. This session plans and ends (BLD-54).

1. Read CLAUDE.md and follow it. Then read, from their ids, the rules a plan works under whose home is elsewhere because a build session works under them too (GEN-24): the pre-code doc check (BLD-7), the three levels and how small an issue is filed (GEN-31), the items an issue is filed by (GEN-32), the form of a question for the owner (GEN-17), fetching evidence a session needs (SES-24), an expected-output block's surface (BLD-52) and a procedure walk (BLD-53) — `git grep -nE '\*\*(BLD-(7|52|53)|GEN-(17|31|32)|SES-24) ' -- CLAUDE.md .claude .github`. Run checks and scripts only where CLAUDE.md's THIS PROJECT says; subagents change no git state (SES-10).
2. Read the issue in full from GitHub, including its comments (`gh issue view $ARGUMENTS --comments`, or the GitHub connector). If you cannot read it, stop and ask the owner to paste the issue. If it looks cut off, or contradicts the repo, stop and ask.
3. Read every doc the issue cites, at the cited lines (GEN-1).
4. **BLD-44 issue-with-no-plan-line.** An issue with no `Plan:` line: this session sets the level by (GEN-31)'s criteria and says on the issue which level and why. Where it sets the level to none, it also makes sure the issue is filed as (GEN-32) says. It adds the `Plan:` line the issue is missing.
5. **BLD-6 plan-at-its-level.** A plan is written at the level the issue's `Plan:` line gives, and holds what that level asks for:
   - At **research**, the design, how established libraries or systems handle the mechanism and whether the design matches them (cited at their source and version, GEN-20), and the test approach — which, when the result depends on the order of events, includes the sequence or model-based test of GEN-21. Where the work has more than one scenario, each scenario's real precondition is stated and the design measured against each of them, not only against the happy path.
   - At **precedent**, the work checked against the implementations the issue's `Precedent:` line names, with every way it differs listed. A difference with no precedent is research for that part.
   - At **none**, nothing: say on the issue that the level is none and why, and end. What the build then does at this level is (BLD-49).
6. **BLD-45 procedure-plan-from-what-was-done.** A plan for an operator procedure reconstructs its order and its steps from the issues and PRs that built the thing, says in the plan that it did, and asks the owner what they did before any step they performed is written.
7. **BLD-46 plan-names-the-captures.** A plan names which outputs only the owner can capture, and asks in the plan what they have already run and already walked.
8. **BLD-47 walk-list-names-the-path.** A plan for an operator procedure lists each resource its walk reaches, with the path to it from the dashboard's home (BLD-53).
9. Run the pre-code doc check (BLD-7). Every conflict and open question it finds goes in the plan, in (GEN-17)'s form.
10. **BLD-8 propose-a-split.** When the plan finds the issue wider than the size rule (GEN-31), stop and propose a split, which needs the owner's agreement.
11. **BLD-43 plan-in-one-comment.** The plan is one comment on the issue. Every amendment — an answer from the owner, a gap fixed, a ruling applied — edits that comment in place and adds a dated line under an "Updated" header at its top. A later comment may point at the plan; it never holds plan content.
12. **BLD-55 size-rule-after-a-plan-ruling.** When a ruling on a plan question adds a control, a command or a mechanism the issue's "To build" did not list, the size rule runs again (GEN-31): a plan that is then wider than the rule proposes a split (BLD-8).
13. **BLD-54 planning-session-plans-and-ends.** At the research and precedent levels a planning session writes the plan, posts it on the issue and ends: it commits nothing, makes no worktree and opens no PR. The build is a fresh session's (BLD-48).
14. Once the owner approves the plan, a fresh session builds the issue with `/build-issue $ARGUMENTS` (BLD-48).
