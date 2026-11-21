# Run ledger

One row per build, for both arms (Opus control and local builder). Set up before the first Stage 2 build (Stage 0 item).

Planned columns (from the iteration 1 plan): Perplexity's 11 dimensions, plus the setup the build ran on (model file, quantization, template, runtime version and flags, launcher commit, Claude Code version) and the date of the suite run that cleared that setup. Finding categories: correctness, domain-spec/D-row conflict, test/evidence gap, process bookkeeping, scope, security.

Not built yet. Where it lives (a CSV here, or a db-backed page like the minutes log) is decided when it is set up.
