#!/usr/bin/env python3
import json, os, subprocess, sys
from datetime import datetime, timezone
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

data = json.load(sys.stdin)

BRAILLE = ' ⣀⣄⣤⣦⣶⣷⣿'
R = '\033[0m'
DIM = '\033[2m'

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def braille_bar(pct, width=8):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ''
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar

def time_remaining(resets_at):
    if not resets_at:
        return ''
    try:
        if isinstance(resets_at, (int, float)):
            reset = datetime.fromtimestamp(resets_at, tz=timezone.utc)
        else:
            reset = datetime.fromisoformat(resets_at.replace('Z', '+00:00'))
        delta = reset - datetime.now(timezone.utc)
        secs = max(int(delta.total_seconds()), 0)
        if secs >= 3600:
            h, m = divmod(secs // 60, 60)
            return f'{h}h{m:02d}m'
        elif secs >= 60:
            return f'{secs // 60}m'
        else:
            return f'{secs}s'
    except Exception:
        return ''

def fmt(label, pct, resets_at=None):
    p = round(pct)
    tr = time_remaining(resets_at)
    reset_str = f' {DIM}⟳{tr}{R}' if tr else ''
    return f'{DIM}{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {p}%{reset_str}'

cwd = data.get('cwd', os.getcwd())
dirname = os.path.basename(cwd)

try:
    branch = subprocess.run(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        capture_output=True, text=True, cwd=cwd, timeout=2
    ).stdout.strip() or None
except Exception:
    branch = None

model = data.get('model', {}).get('display_name', 'Claude')
parts = []
if branch:
    parts.append(branch)
parts.append(dirname)
parts.append(model)

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('ctx', ctx))

five_data = data.get('rate_limits', {}).get('five_hour', {})
five = five_data.get('used_percentage')
if five is not None:
    parts.append(fmt('5h', five, five_data.get('resets_at')))

week_data = data.get('rate_limits', {}).get('seven_day', {})
week = week_data.get('used_percentage')
if week is not None:
    parts.append(fmt('7d', week, week_data.get('resets_at')))

print(f' {DIM}│{R} '.join(parts), end='')
