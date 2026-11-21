# Stage 1 runbook

Copy each grey block into Terminal and press Enter. Where it says **Send to Claude**, paste the block it gives into the Stage 1 thread. Nothing here touches your everyday `claude`, `~/.claude`, or any branch of the project under test.

Each step says what you should see. If you see something else, stop and send it to Claude.

## Part A: install (once)

### 1. Tell Claude you are starting

In the Stage 1 thread, write: **starting Stage 1, my claude is** followed by the output of:

```
claude --version
```

Wait for Claude's reply "pin updated". Claude sets the builder's Claude Code to that version.

### 2. Get the repo

```
mkdir -p ~/Repos && git clone https://github.com/yamimaio/ai-dev-stack ~/Repos/ai-dev-stack
```

If it says the folder already exists:

```
git -C ~/Repos/ai-dev-stack switch main && git -C ~/Repos/ai-dev-stack pull
```

You should see: `Cloning into…` or `Already up to date` / a list of changed files.

### 3. Install llama.cpp

```
~/Repos/ai-dev-stack/model-server/install-llama-cpp.sh 2>&1 | tee ~/ai-dev-stack-step3.txt
```

You should see: download progress, then `Installed to …`. Then:

```
pbcopy < ~/ai-dev-stack-step3.txt
```

**Send to Claude** (it is on your clipboard).

### 4. Download both models (about 21 GB each)

```
~/Repos/ai-dev-stack/model-server/download-model.sh kat-coder-v2.5-dev 2>&1 | tee ~/ai-dev-stack-step4.txt
~/Repos/ai-dev-stack/model-server/download-model.sh qwen3.6-35b-a3b 2>&1 | tee -a ~/ai-dev-stack-step4.txt
~/Repos/ai-dev-stack/model-server/show-sampling.sh 2>&1 | tee -a ~/ai-dev-stack-step4.txt
pbcopy < ~/ai-dev-stack-step4.txt
```

You should see: `Verified.` twice, then the model cards' sampling lines. If a download stops, paste the same line again; it resumes. **Send to Claude.**

### 5. Install the builder Claude Code

```
~/Repos/ai-dev-stack/launcher/install-claude-code.sh 2>&1 | tee ~/ai-dev-stack-step5.txt; pbcopy < ~/ai-dev-stack-step5.txt
```

You should see: a version line and `Installed …`. **Send to Claude.**

### 6. Make the scratch worktree

Gravity: paste the block in [projects/gravity.md, "Stage 1 setup"](projects/gravity.md#stage-1-setup-runbook-step-6). Another project: its file under `projects/`.

## Part B: one model (do it for `kat-coder-v2.5-dev`, then again for `qwen3.6-35b-a3b`)

The blocks below use KAT. For the second model, replace `kat-coder-v2.5-dev` with `qwen3.6-35b-a3b` everywhere.

### 7. Terminal window 1: start the model server

Open a new Terminal window (Cmd+N) and paste:

```
~/Repos/ai-dev-stack/model-server/serve.sh kat-coder-v2.5-dev
```

You should see: `Model: …` and `Alias: …`, then nothing more in the window (it writes to a log). Leave this window open for the whole model.

### 8. Terminal window 2: check the server

Open a new Terminal window (Cmd+N). Wait one minute after step 7 (the model loads), then paste:

```
{ curl -s http://127.0.0.1:8080/health; echo
  curl -s http://127.0.0.1:8080/v1/models | head -c 400; echo
  curl -s http://127.0.0.1:8080/v1/messages -H 'content-type: application/json' \
    -d '{"model":"x","max_tokens":32,"messages":[{"role":"user","content":"Reply with the word OK."}]}'; echo
  grep -i -E 'buffer size|n_ctx|KV' "$(ls -t ~/ai-dev-stack-runs/llama-server/*.log | head -1)" | head -20
} 2>&1 | tee ~/ai-dev-stack-step8.txt; pbcopy < ~/ai-dev-stack-step8.txt
```

You should see: `{"status":"ok"}`, a line with the model's alias, and a reply containing `OK`. If `health` says loading, wait a minute and paste again. **Send to Claude.**

### 9. Window 2: cache check (not scored)

```
cd "$(grep WORKTREE ~/ai-dev-stack-runs/project.env | cut -d= -f2)" && ~/Repos/ai-dev-stack/launcher/claude-pilot "Say hello in five words."
```

The first time only, Claude Code shows set-up screens (theme, trust this folder): press Enter on each. If it asks you to log in, press Ctrl-C and **send Claude** a screenshot: the builder should never need a login. When it has answered, type `What did you just say?` and press Enter. When that is answered, type `/exit`. Then:

```
~/Repos/ai-dev-stack/suite/check-run.sh CACHE kat-coder-v2.5-dev 0 > /dev/null; tail -12 ~/ai-dev-stack-runs/suite-kat-coder-v2.5-dev.log | pbcopy
```

**Send to Claude.**

### 10. Terminal window 3: network monitor

Open a new Terminal window (Cmd+N) and paste:

```
nettop -L 0 -s 5 -p claude-pilot > ~/ai-dev-stack-runs/nettop-kat-coder-v2.5-dev.csv
```

You should see: nothing (it writes to the file). Leave it open until step 12. If it prints an error, **send the error to Claude**.

### 11. Window 2: the suite (54 sessions)

Paste this, as many times as it takes:

```
~/Repos/ai-dev-stack/suite/run-next.sh kat-coder-v2.5-dev
```

Each time it shows the case, one line saying what to answer when Claude Code asks permission, and (once per run) extra lines to paste. Press Enter, let it work, answer prompts as the line says, type `/exit` when it has finished. It then says `Recorded … Run the same command again`. You can stop after any session and continue another day; it remembers where you were.

If something goes badly wrong in a session (a command you said No to runs anyway, or it loops for more than 15 minutes), press Ctrl-C twice, then **send Claude** what happened.

After each sitting:

```
pbcopy < ~/ai-dev-stack-runs/suite-kat-coder-v2.5-dev.log
```

**Send to Claude** (if it is too long to paste, attach the file `~/ai-dev-stack-runs/suite-kat-coder-v2.5-dev.log`).

When it says `All 54 sessions … are done`, go to step 12.

### 12. Finish the model

In window 3, press Ctrl-C. In window 1, press Ctrl-C. Then in window 2:

```
grep -vE '127\.0\.0\.1|localhost|::1' ~/ai-dev-stack-runs/nettop-kat-coder-v2.5-dev.csv | head -40 | pbcopy
```

**Send to Claude** (empty is fine; say "empty").

Then do Part B again for `qwen3.6-35b-a3b`, starting at step 7.

## Part C: clean up (after both models)

Gravity: paste the block in [projects/gravity.md, "Teardown"](projects/gravity.md#teardown-runbook-part-c). The models and tools stay for Stage 2.
