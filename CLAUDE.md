# ai-dev-stack — repository guide

The infrastructure for building software with AI: launcher, model-server commands, conformance suite, git guards, usage script, run ledger, and the research behind each iteration. See `README.md` for the layout.

Every session starts from this file, the GitHub issue it was given, and the docs that issue cites. Nothing depends on chat history.

## THIS PROJECT

The values the rules below leave to each project.

- **Big files (GEN-1):** none today. Any file over 60 KB counts as one.
- **Where the owner's rulings are recorded:** the current iteration's plan doc, linked from the Iterations table in `README.md`. A ruling on how this repo builds, reviews or records changes the rule's own text in this file or a command, and the PR body quotes the owner's words. There is no decision log or ADR folder here.
- **Where checks run (the README's host rule):** on the Mac host only the model server, Docker, git and Claude Code itself run. A session runs linters, tests and scripts under test in a Docker container, never on the host, unless the script's own README says it runs on the host; then the session runs it only against a scratch directory and a scratch config, never the owner's real Claude config, repos or model files.
- **The project checks (BLD-19):** `shellcheck` on every shell script the PR adds or changes (`docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:stable --severity=warning <files>`), `python3 -m py_compile` on every Python file it adds or changes (`docker run --rm -v "$PWD:/mnt" -w /mnt python:3 python3 -m py_compile <files>`), and CI (`.github/workflows/checks.yml`), which runs both on every PR.
- **Worktree paths:** a builder works in `../ai-dev-stack-i<N>` (it builds issue N), a reviewer in `../ai-dev-stack-pr<N>` (it reviews PR N). The commands call these `<wt>` and `<dir>`.
- **Issue areas (GEN-26):** `Launcher`, `Suite`, `Usage`, `Hooks`, `CI`, `Docs`. For example "Launcher: claude-pilot starts with the everyday config dir when HOME has a space", not "Launcher: quote CLAUDE_CONFIG_DIR".
- **Modules switched on:** operator runbooks (GEN-33, GEN-34, BLD-45, BLD-47, BLD-52, BLD-53, REV-21, REV-23) and security review (REV-11's `/security-review`). Off: the decision log, the rule-id check script, container-only execution with Docker stacks, UI review, privacy.

## READ DISCIPLINE — enforced

**GEN-1 read-discipline.** Never read a big file whole, and never draw a conclusion from a partial read:

- Never call Read on a file over 60 KB. Use head / tail / sed -n / grep -n / wc.
- Stamps and titles are at the TOP of files. Closure state and open-item lists are at the BOTTOM. Always check both ends.
- If any read returns truncated output, say TRUNCATED explicitly and re-read the missing byte range with `sed -n 'START,ENDp'`. Never draw a conclusion from a partial read without labelling it.

## EDIT DISCIPLINE

- **GEN-2 edit-only-what-you-were-told.** Never modify an existing file unless told which file and which section. The issue you were given counts as being told.
- **GEN-3 flag-dont-force.** A wrong instruction is FLAGGED AND LEFT UNDONE, not forced through. If the repo contradicts your brief, believe the repo and report the conflict.
- **GEN-4 no-invented-records.** Never invent a decision, a ruling or a status. Log the question.
- **GEN-5 claims-cite-path-line.** Every factual claim carries path:line.
- **GEN-33 runbook-holds-steps-only.** Every runbook (a file an operator follows step by step, such as `suite/RUNBOOK-stage1.md`) holds what to click, what to type and what the operator should see. It does not hold why the procedure works, what the mechanism is, or where the record lives: no decision reference and no pointer to another document, with the one exception in (GEN-34). Reasons go to the plan doc or the script's README, provenance to an issue comment. A consequence that drives the next action stays, because it is part of the instruction — "it bills while it runs: do not leave this step for later". A step may still say what is on the screen in front of the operator; a claim about what a provider's screen does — what it prompts for, which services it reaches, what it requires first — is quoted from the provider's page or walked, and where neither holds the step points at that page and says what to achieve, not what will appear.
- **GEN-34 runbook-scenario-self-contained.** A scenario — one of the alternative paths the operator chooses between for the same job — holds its whole resolution path, numbered from its own step 1 and followed end to end; a step two scenarios both need is written out in both, with the values that scenario needs. What two or more scenarios need in the same exact way is stated once and pointed at, never jumped into: the point may be a shared section in the same file or the provider's own page, and it gives the operator something to read and return from, never another scenario's numbered steps. Every section numbers its own steps from 1, and no two sections share a number. A sequential section, whose parts run one after another rather than instead of one another, is not a scenario, and its pointer to a numbered step of another runbook stands.

## WHEN THE DOCS ARE SILENT

Two cases, decided by what the choice affects:

- **BLD-1 silent-implementation-default.** An implementation detail gets a default, picked without asking. An implementation detail stays inside the code this PR adds, and can be undone by editing only that code. Examples: a variable or helper name, splitting a function, the test file layout, which existing utility to reuse. List it in the PR body, under "Defaults picked".
- **BLD-2 silent-design-flagged.** A design or architecture decision is flagged and left undone. These belong to the owner even when no user sees them. A choice is one if it changes any of:
  - a command's interface: its name, arguments, flags, exit codes or output another script reads;
  - a file format another tool reads, such as a ledger row, a CSV or a settings file;
  - a dependency: adding, removing or a major upgrade, a pinned version included;
  - folder or module boundaries, or a pattern other code will copy;
  - a guard: a deny rule, a hook, a sandbox or anything else security-related;
  - what runs on the owner's machine, what it installs, where it writes, and what it costs;
  - anything the operator sees or does: a runbook's steps, a prompt, output they read;
  - or it is a point where two docs contradict each other.

  Put the question in the PR body, in (GEN-17)'s form. The owner's ruling is recorded as THIS PROJECT says.

When unsure, ask: would undoing it later touch code outside this PR, or would the owner reasonably want a say? If so, treat it as the second case (BLD-2).

**Screening before a push.** (BLD-10), and after each review round (BLD-29).

## RULE IDS

- **GEN-24 process-rule-ids.** Every process rule has a stable id, and the line that states the rule carries it: `**<GROUP>-<n> <slug>.** <the rule>`, in one of four subject groups — `BLD` building an issue into a PR, `REV` reviewing one, `SES` the session and its environment, `GEN` repo-wide conduct and records. The group is the rule's subject, not the file its text sits in, so moving the text never changes the id; ids are never reused and never renumbered, and a new rule takes the next id after the highest one used in its group, here or in any repo these rules are shared with. Everywhere else the rule is cited by its id alone, `(BLD-7)`, with no file, section or step. To read a rule from its id, `git grep -nE '\*\*(BLD|REV|SES|GEN)-[0-9]+ '`.

- **GEN-36 clause-or-id.** When a PR adds a rule to a line that already states one, the addition takes its own id when it says what to do in a situation that line's trigger does not already cover, and stays a clause on that line when it only qualifies how the line's existing act is performed, or narrows the trigger already there. The PR body says which of the two each addition is, and why.

## RULES

1. **BLD-3 one-issue-per-pr.** One GitHub issue per PR: a PR is built for one issue and its body starts with `Closes #N`. If the change that issue needs also fully resolves another open issue, the PR closes that one too: add `Closes #M` with one sentence naming the change that resolves it, and include evidence for #M (a test or a walk step) in the PR's evidence. Work added only to close another issue is still scope creep: that issue gets its own PR. If #M is only partly resolved, write `Refs #M` and say what is left. (BLD-60) and (BLD-61) are the exceptions to `Closes #N`. Work found along the way gets its own issue; it never widens the PR.
   - **BLD-59 read-the-issue-you-close.** Before this PR carries a closing line for an issue other than its own, the builder reads that issue in full, its comments included, as it does for its own issue.
   - **BLD-60 refs-while-an-owner-only-check-is-live.** Where an issue's "Done when" holds a check only the owner can run, this PR says `Refs #N` while that check is live, and the owner closes the issue when the evidence lands.
   - **BLD-61 code-plus-a-procedure-is-two-prs.** An issue that ships both code and an operator procedure is built in two PRs: the code, its check and any record corrections first, which the owner merges; then the procedure, written from a real run of the merged code on the owner's machine, which the owner walks before it is reviewed and merged. The issue's "Done when" spans both — the first PR says `Refs #N`, and the issue closes on the second plus the owner's evidence. A change the run forces on the code is a third PR. An issue that ships only a runbook is one artifact and is not split.
2. **GEN-12 every-issue-has-a-priority.** Every issue states its priority, with a one-line reason. Every issue is filed as the issue template says: the duplicate check, title, labels, body sections, the plan level and links (GEN-32). Something only to watch gets no issue until it is reproduced.
3. **BLD-4 tests-use-fakes.** Tests never call an external service (a model provider, GitHub, Hugging Face, a package registry). They use a fake.
   - **BLD-56 fake-pinned-to-the-real-tool.** A fake that a test, or a documented expected output a PR or a plan writes, relies on is pinned to the real tool's behaviour for the inputs it is used with — by a citation of the tool's source at its version (GEN-20) or by a recorded real response — and the PR or the plan names any output that came only from a fake.
4. **GEN-13 secrets-only-in-env.** Secrets live only in `.env` (local) or the host's secret store. Never committed, logged, or sent to a page.
5. **GEN-15 must-always-rules-live-in-code.** A must-always rule lives in code: a deny rule, a hook, a server check or a lint rule, not only a comment or a prompt.
6. **GEN-16 a-doc-command-has-been-run.** A command a doc tells someone to run has been run in a fresh checkout before the doc says so. A pattern it documents uses only plain POSIX ERE — no `\b`, `\d`, `\w`, `\s` or `(?…)` — because `git grep -E` compiles the platform's `regcomp(3)`, which strips an escape it does not know instead of refusing it: `\bX\b` matches the literal `bXb` and finds nothing.
7. **BLD-5 evidence-before-close.** Evidence goes on the issue before it closes: test output, a screenshot, or a run log, each with the commit it ran on.
   - **BLD-63 one-copy-linked.** Where the same measurement has to appear on several issues or comments, it lives in one comment and the others link it. When it moves, the old record gets a forward banner naming its successor and the figures that changed, rather than repointing every link that already exists.
   - **BLD-64 the-link-carries-the-record.** A claim that something is recorded on an issue links the comment that carries the record, not the issue, and before writing it the builder checks that the comment says the thing claimed — a link that resolves is not a link that carries the record. A substitution applied over several such claims is checked at each one.
8. **SES-1 commits-branches-merges.** Commits use the checkout's own git identity; a session never changes it. Branch from `main` and open a PR; never push to `main`. Only the owner merges.

## SESSION WORKFLOW

1. **SES-3 one-issue-per-session.** A builder session builds one issue on its own branch (one git worktree per parallel session) and opens the PR. Before building, re-read the prompt against the issue; if it looks cut off, ask.
   - **Who plans, who builds, and whether the owner approves the plan first.** (BLD-54, BLD-48).
2. **SES-4 a-fresh-session-reviews.** A different, fresh session reviews the PR head under the review policy below, and a session never reviews its own PR.
3. **SES-5 builder-fixes-findings.** The builder fixes findings under the review policy.
   - **A runbook proved only on the owner's machine, and the correcting round after the merge.** (REV-21).
4. **SES-6 new-session-per-issue.** After the merge, start a new session for the next issue.
5. **SES-10 subagent-no-git-state.** A subagent never changes git state, in any worktree, branch or remote: no `git worktree add`, `remove` or `prune`, no branch create or delete, and no checkout, reset, commit or push. It may read git state. The one exception is a subagent started with `isolation: "worktree"`, which may commit inside its own worktree.

## REVIEW POLICY

A review session follows this whatever the command arguments. The goal is a clear stop, not zero findings.

- **REV-3 review-the-head-on-github.** Review the PR head on GitHub, not a local branch, and say which commit was reviewed.
- **REV-4 a-finding-needs-a-scenario-or-a-cost.** Report only findings with a concrete failure scenario: a specific input or state, and the wrong result. A design or code-quality finding instead names a concrete future cost: the code (path:line) and what it will cost, such as two copies that will diverge or an upcoming issue that must undo it. Drop anything that cannot be verified, matters only to taste, the linter already accepts, or assumes scale the iteration does not have.
- **REV-22 a-prescribed-fix-says-whether-it-ran.** A finding that prescribes a fix says whether the reviewer ran it, and with what output, or marks it `not run`.
- **REV-5 severity-tags.** Start each finding with its tag:
  - `[HIGH]`: breaks a rule or invariant this repo states in practice (a guard that lets through what it exists to block, a script that writes outside its scratch area), leaks a secret, or is a correctness bug on the main path. Also design that contradicts a ruling recorded in the plan doc or a pattern this file fixes. Blocks the merge.
  - `[MEDIUM]`: a real bug reachable with realistic inputs. A failure that the next ordinary use of this code, a command or the repo's own instructions will hit is at least MEDIUM, even when CI or another check would catch it. A CI safety net limits the damage; it does not lower the severity. Also complexity or debt this PR adds with a named cost: duplicated logic that must stay in sync, a hand-rolled copy of an existing utility, a pattern a named upcoming issue must undo, or a hard-to-undo choice (an interface, a file format, a module boundary) made in passing. Blocks the merge.
  - `[LOW]`: hardening, contrived edge cases (ones that need an unusual input or sequence; a check that would catch the failure does not make it contrived), and code-quality improvements with no named cost (readability, naming, small reuse).
- **REV-6 finding-scope.** Design and code-quality findings cover only code this PR adds or changes; a pre-existing problem becomes an issue. A finding the builder has answered is not raised again without new facts.
- **REV-7 round-1-approves-on-nothing.** Round 1 is `APPROVED` only when it finds nothing at all. Any finding, a Low included, makes the verdict `CHANGES REQUESTED`. The builder fixes every finding, or answers in the PR why it is wrong.
- **REV-8 later-rounds-are-complete.** Each later round confirms the previous High and Medium fixes and, in round 2, that each round-1 finding was fixed, answered or filed; reviews the change since the last round; and checks every claim that change makes, plus everything it falsifies elsewhere in the repo. It is not a diff-only round: a defect the change's claims reach is in scope however old the code is. A finding that names several locations is confirmed at every one of them, or stays unresolved. The builder fixes High and Medium; the reviewer, not the builder, files each new Low as one `low` issue linked from the PR, as the issue template says (GEN-32).
- **REV-2 pr-body-low-folded.** A Low whose whole content is a correction to the PR's own body is never filed as an issue: an issue for text that stops existing at the merge would have nothing to build. In round 1 it is fixed like every other round-1 finding (REV-7). From round 2 on, the reviewer's `APPROVED` verdict marks it "fold before merge", the builder folds it into the PR before the owner merges, and no new round starts. A Low in code, or in a record that outlives the merge, follows the round's own rule (REV-7, REV-8).
- **The rulings the build was made from.** (REV-25).
- **REV-12 bookkeeping-is-low.** In `CLAUDE.md`, `.claude/` and `.github/`, a stale step number, cross-reference, header comment or rule-id mismatch is `[LOW]`, unless it makes a rule wrong, unfollowable or silently skipped. A commit name, head label or line number that is stale while the value it labels is correct on the head is `[LOW]` wherever it appears, a PR's own body and its evidence comments included, and it is never filed as an issue: in the body it is folded (REV-2), and in an evidence comment it is corrected on the issue it belongs to. A quoted rule line or a claim whose text differs from the head is not bookkeeping: it changes what the owner approves before merging. Both `[LOW]`s override REV-5's "at least MEDIUM" sentence, the first for those files only.
- **REV-9 stop-rule.** Stop when a round from round 2 on finds no new High or Medium, or when round 1 finds nothing. No cap on rounds. Reset the round count on purpose after a redesign.
- **REV-21 runbook-proved-in-production.** When a procedure can only be verified by merging it and running it for real on the owner's machine — an install, a bench run, a one-time setup — the review is not over when the PR merges. The owner runs it, and whatever the run contradicts is corrected in the runbook before the issue closes, as the next round of that issue's review rather than as `low` work filed for later. An approval of such a PR approves the text so far, not the procedure; the issue's own "Done when" is what closes it. It widens the review in no other way: the corrections are only what the run contradicted, anything else found along the way still gets its own issue (BLD-3), and a runbook whose steps a session can walk is unaffected. It binds the builder as much as the reviewer.
- **REV-13 round-3-ship-cut-redesign.** When round 3 or any later round still has a High or Medium, the round ends with a question to the owner instead of a plain `CHANGES REQUESTED`: **cut** (drop the part that keeps failing), **redesign** (a new issue, with GEN-22's root cause), or **ship** (a regression-only round, then merge, with the rest filed). The owner's call, not the reviewer's.
- **REV-10 verdict-line.** One line in the summary comment, `APPROVED` or `CHANGES REQUESTED` with what must be handled.
- **REV-11 extra-checks.** A PR that changes a guard (a deny rule, a hook, the launcher's settings), anything that installs software or runs on the owner's machine, or anything that handles a secret also runs `/security-review`.
- **REV-23 the-owner-reads-a-procedure-pr-after-round-1.** For a PR that ships a runbook or another operator procedure, the owner reads it right after review round 1, before any further round: after round 1's fixes the builder asks for the owner's read and lists which findings need a screen or a memory only the owner has. From then on, a round whose remaining findings need one of those hands over to the owner's read or walk instead of starting another round.
- **REV-24 operator-walk.** For a PR that adds or changes steps the owner runs, the reviewer follows them in order from the PR head: runs every step it is permitted to run and that needs no provider account (THIS PROJECT's host rule); checks each unrunnable step's stated output against the source that step cites; checks that no step needs what a later step creates; and checks that no step puts a credential on a command line or into output pasted on a public issue.
- AI review is necessary, not sufficient: the owner still runs the real thing.

## WORKING WITH THE OWNER

- **GEN-17 ask-dont-assume.** Ask rather than assume about goals or context. A question put to the owner — from a plan, a build, a review finding, a fix round or a relay — has three parts, in this order: the problem in plain words, what happens and to whom, which command, file or step is involved and what triggers it, why it cannot be decided without the owner (which rule or doc is silent, or which two contradict each other) and what happens if nothing is decided, so that the owner can answer it without opening a file, any path:line coming after that explanation and never in place of it; then the options, each saying what the owner would see or get, with its pros and cons; then the recommendation and its reason. A question about an element also names each ruling the plan doc already records on it, and says which option keeps it and which reverses it. A question that is only a list of options is incomplete, and a reviewer may raise it.
- **GEN-18 do-exactly-what-was-asked.** Do exactly what was asked, and don't widen or cut scope on your own.
- **GEN-19 say-what-you-checked.** Say what you checked (path:line, output, a link), or say that a claim is inferred. "Covered" means each case was traced.
- **GEN-20 outside-tool-source.** A claim that an outside tool or library does something, when a default, a question, a finding or a ruling rests on it, cites the tool's source at a version (file:line, e.g. from `npm pack` or the tool's tagged release), not its docs or memory. The source is the copy that runs: when a tool bundles its own copy of another, cite that copy. When the copy that runs is a compiled binary, the claim cites its source at the commit the binary reports, for example the build tag that `llama-server --version` prints. This applies to builders and reviewers alike.
- **SES-24 fetch-the-evidence-yourself.** Evidence a session needs reaches that session: a GitHub user-attachment is fetched by the session itself, `curl -sSL -o <file> -H "Authorization: token $(gh auth token)" <url>`, and the owner is asked to paste it in only when that fetch fails or the evidence was never posted.
- **GEN-21 order-dependent-fix-needs-a-sequence-test.** When a repeated finding's area is state whose result depends on the order of events (concurrent runs, retries, a resumed run, a log read while it is written), the fix comes with a sequence or model-based test: it drives the real logic through every order of its events up to a bound, and asserts the invariants after every event, not only once things settle.
- **GEN-22 repeated-finding-root-cause.** If the same kind of bug or design finding comes back twice in one area, stop and propose a simpler design. This applies to builders and reviewers alike. The proposal, in a question to the owner or a review's summary:
  - names the root cause in one sentence: why the findings keep happening, not where they are;
  - includes at least one option that removes that cause, not only one that consolidates the code;
  - checks every earlier finding or reproduction against that option, plus what happens after it (a retry, a rollback, a re-run), and says which the option would have prevented and which have a separate cause;
  - checks every candidate dropped in this or an earlier round against the root cause. A dropped candidate that is the root cause is folded into the finding, not dropped again as "no new facts";
  - checks how established libraries or systems handle the same problem, cited at their source and version as (GEN-20) asks, and says whether the chosen option matches them;
  - runs the option against the earlier reproductions, through the sequence or model-based test above or a throwaway commit, and quotes the result, before the owner rules on it.
- **GEN-23 smallest-scope-for-goal.** Prefer the smallest scope that meets the established goals — the issue's, and the iteration's.
