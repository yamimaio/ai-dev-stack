#!/bin/bash
# Gravity: makes the Stage 1 scratch worktree gravity-i1900, commits the fixtures locally, and starts its stack.
# Run from your main Gravity checkout:  <ai-dev-stack>/suite/projects/gravity/setup-worktree.sh <main-commit>
# Uses git and docker compose only (the stack's own commands, from local-environment.md section 13).
set -euo pipefail
ai="$(cd "$(dirname "$0")/../../.." && pwd)"
pin="${1:?usage: setup-worktree.sh <commit on main to pin, e.g. the output of git rev-parse origin/main>}"
main_top="$(git rev-parse --show-toplevel)"
wt="$(dirname "$main_top")/gravity-i1900"
[ -e "$wt" ] && { echo "$wt already exists. Remove it first (see suite/projects/gravity.md, Teardown)." >&2; exit 1; }

# extensions.worktreeConfig (below) needs core.worktree, and core.bare if true, out of the shared config.
if [ -n "$(git config --file "$(git rev-parse --git-common-dir)/config" --get core.worktree || true)" ] ||
   [ "$(git config --file "$(git rev-parse --git-common-dir)/config" --get core.bare || true)" = true ]; then
  echo "Your Gravity clone's .git/config sets core.worktree or core.bare=true. Move it to config.worktree first (git help config, extensions.worktreeConfig). Nothing changed." >&2
  exit 1
fi

git worktree add -b pilot/conformance "$wt" "$pin"
cp -R "$ai/suite/fixtures/pilot-fixtures" "$wt/"
cp "$ai/suite/projects/gravity/fixtures/src/"*.ts "$wt/src/"
cd "$wt"
git add pilot-fixtures src/pilot-fixture-type-error.ts src/pilot-fixture-logging.ts
git commit -q -m "Pilot conformance fixtures (local only, never pushed)"
git tag -f pilot-fixtures-base

# Pushes from this worktree only go nowhere: a per-worktree push URL that cannot resolve.
# Your main checkout and other worktrees keep pushing normally (git-config "extensions.worktreeConfig").
# worktreeConfig is repo-wide and is left on at teardown: with it on, git also reads each worktree's
# config.worktree (git v2.50.1 config.c:2070-2073). Git requires core.worktree, and core.bare if true,
# to be out of the shared config first (Documentation/config/extensions.adoc:82-89 at v2.50.1), which
# the check above makes sure of: otherwise every linked worktree is re-pointed at core.worktree.
git config extensions.worktreeConfig true
git config --worktree remote.origin.pushurl "no-push://pilot-scratch-worktree"

# Section 13 stack, N=1900 (ports 49000-49003).
N=1900; P=gravity-i$N; B=$((30000 + 10 * N))
cat > .env <<ENV
COMPOSE_PROJECT_NAME=$P
GRAVITY_APP_PORT=$B
GRAVITY_NEXT_START_PORT=$((B + 1))
GRAVITY_PROD_PORT=$((B + 2))
GRAVITY_DB_PORT=$((B + 3))
ENV
docker compose up -d --build
docker compose exec -T app npx prisma migrate deploy
docker compose ps
# Tells suite/run-next.sh which project and worktree to use.
mkdir -p "$HOME/ai-dev-stack-runs"
printf 'PROJECT=gravity\nWORKTREE=%s\n' "$wt" > "$HOME/ai-dev-stack-runs/project.env"
echo
echo "Worktree ready: $wt  branch pilot/conformance  fixtures at $(git rev-parse --short HEAD) (tag pilot-fixtures-base), pinned on $pin"
