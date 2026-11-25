---
name: Issue
about: One problem or question, with its priority, where it was found and when it is done
---

<!--
**GEN-32 how-to-file-an-issue.** File an issue as the items below say, each of
which carries its own id. They are stated here and cited by their ids (GEN-24)
from CLAUDE.md, /build-issue and /plan-issue. This comment is guidance, not part of
the issue: the issue body starts at the "**Priority:" line below it.

1. **GEN-25 duplicate-check-first.** Search the open issues once for each path or topic
   the finding touches, before filing:
     gh issue list --state open --limit 200 --search "<path or topic>"
   If one already covers it, comment there (what you found, PR, commit) instead of
   filing. These are the only searches to run: do not open other issues or the
   label list to work out the format.

2. **GEN-26 issue-title.** Short, area first, describing the problem, not the fix.
   The areas, with an example, are in CLAUDE.md's THIS PROJECT.

3. **GEN-27 issue-labels.** Exactly one priority label, plus the urgency label and any
   topic labels that apply.
   Priority:
     high      needed before the current iteration ends
     medium    a later iteration, or when there is time
     low       hardening, small fixes and nice-to-haves
   Urgency (optional, with any priority):
     must-now  blocks the current iteration's next step
   Topic (optional, only these four):
     accessibility  a barrier affecting people with disabilities
     documentation  the fix changes only docs
     bug            something built isn't working
     enhancement    a new feature or request
   No topic is fine when none applies. A session never creates a label: if the issue
   needs one that is not on this list, file without it and ask the owner in the issue
   or the PR.

4. **GEN-28 issue-body-sections.** The sections below, in this order. Replace each [placeholder]. The skeleton
   uses square brackets because GitHub drops an unfilled <…> as an HTML tag.
   - Priority: the same label as above, and one line saying why (GEN-12).
   - Found in: the PR and head commit, or the session, and by whom
     (review round N of PR #P, or the #N build). Always link back to the PR or issue
     it came from.
   - Plan: one of research, precedent and none, by item 5's criteria, with one line
     saying why that level.
   - Precedent: the implementations the work follows (path:line), by item 5's rule.
     Drop the line unless the plan level is "precedent".
   - Problem: the concrete failure scenario (a specific input or state, and the wrong
     result), or for a design finding the named future cost (REV-4), with path:line.
   - To build: what to change. For a question the owner must rule on, replace the whole
     "To build" section with "## Options", in (GEN-17)'s form. A question is never
     decided in the issue.
   - Done when: the checks that close it, and the evidence that goes on the issue
     (BLD-5).
   - Build order (optional, last): only when it must wait for other issues or PRs.

5. **GEN-31 plan-level-and-size.** Which of the three levels the `Plan:` line gives, and
   how small an issue is filed. What
   a planning session and a builder then do with the level is (BLD-6) and (BLD-48).
   - research: the work brings in a mechanism the codebase hasn't done before — a
     feature or script with no precedent, state whose result depends on the
     order of events, or a complex bug (the cause isn't known after reading the issue
     and the code, a fix in the same area failed before, or it spans more than one
     module).
   - precedent: a new feature that follows an existing pattern, such as another
     model in model-server/ or another case in the suite. The `Precedent:` line names the implementations it
     follows. A change to CLAUDE.md, a command, a skill or a check script is at
     least precedent, and its plan lists every record the change touches before
     editing.
   - none: any other docs, copy fixes, config, and a bug with a known cause in one
     place. A check script is precedent, as above.
   - Whoever files the issue sets the level, whoever that is — the owner, the
     coordinator, a builder, a planner, a reviewer. The planning session may raise
     it; lowering it requires a stated reason during the planning session. A
     builder that disagrees with the plan — it may have new evidence — raises it
     as a question and does not change it (BLD-48).
   - Size: one issue is one piece of work. File it smaller when it would hold more
     than one independent mechanism whose result depends on the order of events, when the change would touch many files
     (more than about 25 is a useful signal, not a limit), or when it asks for
     several unrelated features at once. A mix of tiny features or fixes is fine.

6. **GEN-29 link-the-issue-from-where-it-came.** Link the new issue from where it came
   from: a reviewer in the review's summary comment, a builder in the PR body.

7. **GEN-30 file-from-mains-skeleton.** A session files with the skeleton below this
   comment, in its scratchpad. It reads the template from main, so a checkout that
   predates this file works too:
     git fetch -q origin &&
       git show origin/main:.github/ISSUE_TEMPLATE/issue.md |
       sed -n '/^[*][*]Priority: \[/,$p' > <scratchpad>/issue.md &&
       test -s <scratchpad>/issue.md
     (fill in every [placeholder]; add "## Build order" at the end if it applies)
     gh issue create --title "<Area: problem>" --label <priority> [--label <topic>] \
       --body-file <scratchpad>/issue.md
-->
**Priority: [label].** [One line: why this priority.]

**Found in:** [review round N of PR #P, head `abc1234` / the #N build session], by [reviewer / builder].

**Plan: [research / precedent / none].** [One line: why this level.]

**Precedent:** [path:line of the implementations this work follows; drop this line unless the plan is "precedent".]

## Problem

[The concrete failure scenario, or the named cost for a design finding, with path:line.]

## To build

[What to change.]

## Done when

- [ ] [Check that closes it, and the evidence that goes on this issue with its commit.]
