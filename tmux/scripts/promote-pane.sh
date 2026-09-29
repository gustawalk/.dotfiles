#!/usr/bin/env bash
set -euo pipefail

pane_id=${1:-}
if [[ ! $pane_id =~ ^%[0-9]+$ ]]; then
  exit 1
fi

window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')
others=()
while IFS= read -r other; do
  others+=("$other")
done < <(
  tmux list-panes -t "$window_id" -F '#{pane_top} #{pane_left} #{pane_id}' |
    sort -n -k1,1 -k2,2 |
    awk -v main="$pane_id" '$3 != main { print $3 }'
)
if ((${#others[@]} == 0)); then
  tmux display-message -t "$pane_id" 'Promote pane needs at least two panes'
  exit 0
fi

pane_left=$(tmux display-message -p -t "$pane_id" '#{pane_left}')
pane_top=$(tmux display-message -p -t "$pane_id" '#{pane_top}')
pane_height=$(tmux display-message -p -t "$pane_id" '#{pane_height}')
window_height=$(tmux display-message -p -t "$pane_id" '#{window_height}')
if ((pane_left == 0 && pane_top == 0 && pane_height == window_height)); then
  right_count=$(
    tmux list-panes -t "$window_id" -F '#{pane_id} #{pane_left}' |
      awk -v main="$pane_id" '$1 != main && $2 > 0 { count++ } END { print count + 0 }'
  )
  if ((right_count == ${#others[@]})); then
    exit 0
  fi
fi

pane_width=$(tmux display-message -p -t "$pane_id" '#{pane_width}')
window_width=$(tmux display-message -p -t "$pane_id" '#{window_width}')
main_width=$((pane_width * 100 / window_width))
if ((main_width < 30 || main_width > 70)); then
  main_width=60
fi
tmux set-window-option -t "$window_id" main-pane-width "${main_width}%"
tmux select-layout -t "$window_id" main-vertical

desired=("$pane_id" "${others[@]}")
for ((i = 0; i < ${#desired[@]}; i++)); do
  current=()
  while IFS= read -r slot; do
    current+=("$slot")
  done < <(
    tmux list-panes -t "$window_id" -F '#{pane_left} #{pane_top} #{pane_id}' |
      sort -n -k1,1 -k2,2 |
      awk '{ print $3 }'
  )
  if [[ ${current[i]} != "${desired[i]}" ]]; then
    tmux swap-pane -d -s "${desired[i]}" -t "${current[i]}"
  fi
done
tmux select-pane -t "$pane_id"
