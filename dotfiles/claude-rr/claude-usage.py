#!/usr/bin/env python3
import json
import os
import re
import sys
import time
import subprocess
import pty
import select
from concurrent.futures import ThreadPoolExecutor, as_completed

MAX_PARALLEL_CHECKS = 8

BASE_DIR = os.path.expanduser("~/.claude-accounts")
HOME_DIR = os.path.expanduser("~")

ANSI_ESCAPE = re.compile(r"\x1B(?:\[[0-?]*[ -/]*[@-~]|\][^\x07\x1b]*(?:\x07|\x1b\\))")


def ensure_trust(config_dir):
    path = os.path.join(config_dir, ".claude.json")
    if not os.path.isfile(path):
        return
    try:
        with open(path) as f:
            data = json.load(f)
    except (OSError, json.JSONDecodeError):
        return

    projects = data.setdefault("projects", {})
    entry = projects.get(HOME_DIR, {})
    if entry.get("hasTrustDialogAccepted"):
        return

    projects[HOME_DIR] = {
        "allowedTools": [],
        "mcpContextUris": [],
        "mcpServers": {},
        "enabledMcpjsonServers": [],
        "disabledMcpjsonServers": [],
        "hasClaudeMdExternalIncludesApproved": False,
        "hasClaudeMdExternalIncludesWarningShown": False,
        **entry,
        "hasTrustDialogAccepted": True,
    }
    try:
        with open(path, "w") as f:
            json.dump(data, f, indent=2)
    except OSError:
        pass


def get_usage(config_dir):
    ensure_trust(config_dir)

    master_fd, slave_fd = pty.openpty()
    env = os.environ.copy()
    env["TERM"] = "xterm-256color"
    env["CLAUDE_CONFIG_DIR"] = config_dir

    process = subprocess.Popen(
        ["claude", "/usage"],
        stdin=slave_fd,
        stdout=slave_fd,
        stderr=slave_fd,
        env=env,
        cwd=HOME_DIR,
        close_fds=True,
    )
    os.close(slave_fd)

    buffer = []
    os.set_blocking(master_fd, False)

    try:
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            if process.poll() is not None:
                break
            ready, _, _ = select.select([master_fd], [], [], 0.1)
            if master_fd in ready:
                try:
                    chunk = os.read(master_fd, 4096)
                    if chunk:
                        buffer.append(chunk)
                        decoded = chunk.decode("utf-8", errors="ignore")
                        if "Resets" in decoded or "% used" in decoded:
                            time.sleep(0.5)
                            break
                except OSError:
                    break

        try:
            os.write(master_fd, b"\x1b")
        except OSError:
            pass

    finally:
        process.terminate()
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            process.kill()
        os.close(master_fd)

    output = b"".join(buffer).decode("utf-8", errors="ignore")
    return parse_usage(output)


def parse_usage(output):
    text = ANSI_ESCAPE.sub("", output)

    result = {"session": None, "week": None}

    session_match = re.search(r"Current session.*?(\d+)%\s*used.*?Resets\s+(.+?\([^)]+\))", text, re.DOTALL)
    if session_match:
        result["session"] = f"{session_match.group(1)}% - Resets {session_match.group(2).strip()}"

    week_match = re.search(r"Current week.*?(\d+)%\s*used.*?Resets\s+(.+?\([^)]+\))", text, re.DOTALL)
    if week_match:
        result["week"] = f"{week_match.group(1)}% - Resets {week_match.group(2).strip()}"

    if not result["week"]:
        fallback = re.search(
            r"(\d+)%\s+of\s+your\s+weekly\s+limit\s*[·•]\s*resets\s+([^\\r\\n\x00-\x1f]+)",
            text,
            re.IGNORECASE,
        )
        if fallback:
            reset_time = fallback.group(2).strip()
            if "Asia/Saigo" in reset_time and ")" not in reset_time:
                reset_time = reset_time.replace("Asia/Saigo", "Asia/Saigon)")
            result["week"] = f"{fallback.group(1)}% - Resets {reset_time}"

    return result


def session_percent(usage):
    if not usage or not usage.get("session"):
        return None
    match = re.match(r"(\d+)%", usage["session"])
    return int(match.group(1)) if match else None


def list_accounts():
    if not os.path.isdir(BASE_DIR):
        return []
    return sorted(
        name for name in os.listdir(BASE_DIR)
        if name != "_shared" and os.path.isdir(os.path.join(BASE_DIR, name))
    )


def check_all(accounts):
    results = {}
    workers = min(len(accounts), MAX_PARALLEL_CHECKS)
    with ThreadPoolExecutor(max_workers=workers) as pool:
        futures = {
            pool.submit(get_usage, os.path.join(BASE_DIR, name)): name
            for name in accounts
        }
        for future in as_completed(futures):
            name = futures[future]
            try:
                results[name] = (future.result(), None)
            except Exception as e:
                results[name] = (None, e)
    return results


def main():
    accounts = list_accounts()

    if not accounts:
        print("[ERROR] No accounts found. Run: claude-rr add <name>")
        return

    results = check_all(accounts)

    for name in accounts:
        print(f"--- {name} ---")
        usage, error = results[name]
        if error:
            print(f"  Error: {error}")
        elif usage["session"] or usage["week"]:
            if usage["session"]:
                print(f"  Session: {usage['session']}")
            if usage["week"]:
                print(f"  Week:    {usage['week']}")
        else:
            print("  No usage data (not logged in yet?)")
        print()


def pick_least_used():
    accounts = list_accounts()
    if not accounts:
        print("[ERROR] No accounts found. Run: claude-rr add <name>", file=sys.stderr)
        sys.exit(1)

    print(f"Checking {len(accounts)} account(s)", file=sys.stderr)
    results = check_all(accounts)

    best_name, best_percent = None, None
    for name in accounts:
        usage, error = results[name]
        if error:
            print(f"  {name}: error ({error})", file=sys.stderr)
            continue

        percent = session_percent(usage)
        if percent is None:
            print(f"  {name}: no session usage data (not logged in?)", file=sys.stderr)
            continue

        print(f"  {name}: {percent}% used", file=sys.stderr)
        if best_percent is None or percent < best_percent:
            best_name, best_percent = name, percent

    if best_name is None:
        print("[ERROR] No account has usable session data.", file=sys.stderr)
        sys.exit(1)

    print(f"[OK] Picked '{best_name}' ({best_percent}% session used)", file=sys.stderr)
    print(best_name)


if __name__ == "__main__":
    if "--pick" in sys.argv[1:]:
        pick_least_used()
    else:
        main()
