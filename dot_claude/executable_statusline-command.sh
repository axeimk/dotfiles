#!/usr/bin/env bash
input=$(cat)

# --- jq でJSON値抽出 ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
current_dir="${project_dir##*/}"

# rate_limits（v2.1.80以降）
usage_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
resets_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
usage_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
resets_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# --- Gitブランチ名 ---
git_branch=""
if [ -n "$project_dir" ] && git -C "$project_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$project_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# --- リセット時刻ラベル（Unix秒→時刻文字列）---
reset_label() {
  local ts=$1
  [ -z "$ts" ] && return
  LC_TIME=C date -d "@$ts" '+%-l%P' 2>/dev/null | tr -d ' '
}
resets_5h_label=$(reset_label "$resets_5h")
resets_7d_label=$(reset_label "$resets_7d")

# --- プログレスバー ---
make_bar() {
  local pct=$1 width=10
  local filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  local bar="" i
  for ((i=0; i<width; i++)); do
    [ "$i" -lt "$filled" ] && bar="${bar}▓" || bar="${bar}░"
  done
  printf "%s" "$bar"
}

# --- 出力 ---
sep=' \033[2m|\033[0m '
first=1

# Gitブランチ（マゼンタ）
if [ -n "$git_branch" ]; then
  printf '\033[35m %s\033[0m' "$git_branch"
  first=0
fi

# プロジェクトディレクトリ（青）
if [ -n "$current_dir" ]; then
  [ $first -eq 0 ] && printf "$sep"
  printf '\033[34m%s\033[0m' "$current_dir"
  first=0
fi

# モデル名（シアン）
[ $first -eq 0 ] && printf "$sep"
printf '\033[36m%s\033[0m' "$model"

# 5h limit
if [ -n "$usage_5h" ]; then
  reset_str=""
  [ -n "$resets_5h_label" ] && reset_str="/$resets_5h_label"
  printf "$sep"
  printf '5h [%s] %s%%%s' "$(make_bar "$usage_5h")" "$usage_5h" "$reset_str"
fi

# weekly limit
if [ -n "$usage_7d" ]; then
  reset_str=""
  [ -n "$resets_7d_label" ] && reset_str="/$resets_7d_label"
  printf "$sep"
  printf 'week [%s] %s%%%s' "$(make_bar "$usage_7d")" "$usage_7d" "$reset_str"
fi

# 改行して2行目へ
printf '\n'

# コンテキストゲージ（使用率に応じて色分け）
if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct")
  filled=$(( pct_int / 10 ))
  empty=$(( 10 - filled ))
  bar=""
  i=0; while [ $i -lt $filled ]; do bar="${bar}▓"; i=$((i+1)); done
  i=0; while [ $i -lt $empty ];  do bar="${bar}░"; i=$((i+1)); done
  if [ "$pct_int" -ge 80 ]; then color='\033[31m'
  elif [ "$pct_int" -ge 50 ]; then color='\033[33m'
  else color='\033[32m'; fi
  printf '%bctx [%s] %s%%\033[0m' "$color" "$bar" "$pct_int"
fi
