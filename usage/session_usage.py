"""Sum Claude token usage per Claude Code session, from local session logs.

Pilot tool, not Gravity code. Reads ~/.claude/projects (mounted read-only),
writes one CSV row per session. Standard library only; meant to run in a
container with no network:

    docker run --rm --network none \
      -v "$HOME/.claude/projects:/logs:ro" \
      -v "$PWD:/work" -w /work \
      python:3.12-slim python -I session_usage.py /logs sessions.csv

What it counts:
- every assistant message whose model name starts with "claude-" (so a
  local model served behind Claude Code is left out);
- each API response once: log lines repeat the same usage for every content
  block, so lines are de-duplicated by (message id, request id);
- subagent logs (<session>/subagents/*.jsonl) are added to their parent
  session and also reported separately.

Columns:
- session_id, project (the log folder name), cwd, first_ts, last_ts
- first_prompt: the first 80 characters of the first real user message.
  Built-in commands (/clear, /model, /effort, ...) and their output are
  skipped; a custom command shows as "/build-issue 575". It stays on your Mac.
- commands: every custom slash command run in the session, in order, with
  its arguments, e.g. "/build-issue 575 | /review-pr 639"
- refs: the issue/PR numbers the session touched most (from #N, issues/N,
  pull/N and gh issue/pr commands in prompts and tool calls), top 5 as
  number:count. Numbers only, no text.
- branches: git branches the session ran on, other than main and HEAD
- models: Claude models seen
- input, cache_write, cache_read, output: raw token counts, all agents
- subagent_output: output tokens from subagents only
- weighted: an ESTIMATE of relative cost in input-token units, using the
  usual API price ratios (input 1, cache write 1.25 for 5-minute and 2 for
  1-hour cache, cache read 0.1, output 5). Plan limits are not published
  in these units, so use it only to compare sessions with each other, for
  example a build against a review (B/R).
"""
import collections
import csv
import re
import glob
import json
import os
import sys


def first_text(message):
    content = message.get("content")
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                return block.get("text", "")
    return ""


BUILTIN = {"clear", "model", "effort", "login", "logout", "compact", "resume",
           "config", "status", "cost", "usage", "help", "exit", "init",
           "permissions", "memory", "doctor", "context", "rename", "add-dir",
           "ide", "hooks", "mcp", "agents", "theme", "vim", "fast", "plugin",
           "rewind", "export", "release-notes", "terminal-setup", "upgrade"}
CMD = re.compile(r"<command-name>/?([^<\s]+)</command-name>")
ARGS = re.compile(r"<command-args>(.*?)</command-args>", re.S)
REF = re.compile(r"(?:#|issues/|pull/|\bgh (?:issue|pr) \w+ )(\d{2,4})\b")


def all_text(message):
    content = message.get("content")
    if isinstance(content, str):
        return content
    out = []
    if isinstance(content, list):
        for block in content:
            if not isinstance(block, dict):
                continue
            if block.get("type") == "text":
                out.append(block.get("text", ""))
            elif block.get("type") == "tool_use":
                out.append(json.dumps(block.get("input", {})))
    return "\n".join(out)


def scan(path, row, seen, is_sub):
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            try:
                d = json.loads(line)
            except ValueError:
                continue
            ts = d.get("timestamp")
            if ts:
                row["first_ts"] = min(row["first_ts"] or ts, ts)
                row["last_ts"] = max(row["last_ts"] or ts, ts)
            if not row["cwd"] and d.get("cwd"):
                row["cwd"] = d["cwd"]
            msg = d.get("message") or {}
            branch = d.get("gitBranch")
            if branch and branch not in ("main", "HEAD"):
                row["branches"][branch] = None
            if isinstance(msg, dict) and d.get("type") in ("user", "assistant"):
                text = first_text(msg) if d.get("type") == "user" else all_text(msg)
                if d.get("type") == "user" and not is_sub and not d.get("isMeta"):
                    m = CMD.search(text)
                    if m:
                        a = ARGS.search(text)
                        cmd = ("/" + m.group(1) + " " + (a.group(1).strip() if a else "")).strip()
                        if m.group(1) not in BUILTIN:
                            row["commands"].append(cmd[:60])
                            if not row["first_prompt"]:
                                row["first_prompt"] = cmd[:80]
                            row["refs"].update(re.findall(r"\b(\d{2,4})\b", cmd))
                    elif text.strip() and not text.startswith(("<local-command", "Caveat:")) \
                            and "tool_result" not in str(msg.get("content"))[:200]:
                        if not row["first_prompt"]:
                            row["first_prompt"] = text.strip().replace("\n", " ")[:80]
                row["refs"].update(REF.findall(text))
            if d.get("type") != "assistant" or not isinstance(msg, dict):
                continue
            model = msg.get("model") or ""
            if not model.startswith("claude-"):
                continue
            key = (msg.get("id"), d.get("requestId"))
            if key in seen:
                continue
            seen.add(key)
            u = msg.get("usage") or {}
            cc = u.get("cache_creation") or {}
            w5 = cc.get("ephemeral_5m_input_tokens")
            w1 = cc.get("ephemeral_1h_input_tokens")
            write = u.get("cache_creation_input_tokens") or 0
            if w5 is None and w1 is None:
                w5, w1 = write, 0
            row["models"].add(model)
            row["input"] += u.get("input_tokens") or 0
            row["cache_write"] += write
            row["cache_read"] += u.get("cache_read_input_tokens") or 0
            row["output"] += u.get("output_tokens") or 0
            if is_sub:
                row["subagent_output"] += u.get("output_tokens") or 0
            row["weighted"] += ((u.get("input_tokens") or 0)
                                + 1.25 * (w5 or 0) + 2 * (w1 or 0)
                                + 0.1 * (u.get("cache_read_input_tokens") or 0)
                                + 5 * (u.get("output_tokens") or 0))


def main(root, out):
    rows = []
    for path in sorted(glob.glob(os.path.join(root, "*", "*.jsonl"))):
        sid = os.path.splitext(os.path.basename(path))[0]
        row = {"session_id": sid, "project": os.path.basename(os.path.dirname(path)),
               "cwd": "", "first_ts": "", "last_ts": "", "first_prompt": "",
               "commands": [], "refs": collections.Counter(), "branches": {},
               "models": set(), "input": 0, "cache_write": 0, "cache_read": 0,
               "output": 0, "subagent_output": 0, "weighted": 0.0}
        seen = set()
        scan(path, row, seen, False)
        for sub in sorted(glob.glob(os.path.join(os.path.dirname(path), sid, "subagents", "*.jsonl"))):
            scan(sub, row, seen, True)
        if not row["models"]:
            continue
        row["models"] = " ".join(sorted(row["models"]))
        row["commands"] = " | ".join(row["commands"])
        row["refs"] = " ".join(f"{n}:{c}" for n, c in row["refs"].most_common(5))
        row["branches"] = " ".join(list(row["branches"])[:5])
        row["weighted"] = round(row["weighted"])
        rows.append(row)
    rows.sort(key=lambda r: r["first_ts"])
    fields = ["session_id", "project", "cwd", "first_ts", "last_ts", "first_prompt",
              "commands", "refs", "branches",
              "models", "input", "cache_write", "cache_read", "output",
              "subagent_output", "weighted"]
    with open(out, "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(rows)
    print(f"{len(rows)} sessions written to {out}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: session_usage.py <projects dir> <out.csv>")
    main(sys.argv[1], sys.argv[2])
