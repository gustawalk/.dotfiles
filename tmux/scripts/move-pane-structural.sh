#!/usr/bin/env bash
set -euo pipefail

direction=${1:-}
pane_id=${2:-}
case "$direction" in
  left | down | up | right) ;;
  *) exit 1 ;;
esac
[[ $pane_id =~ ^%[0-9]+$ ]] || exit 1

window_id=$(tmux display-message -p -t "$pane_id" '#{window_id}')
read -r source_x source_y source_w source_h < <(
  tmux display-message -p -t "$pane_id" '#{pane_left} #{pane_top} #{pane_width} #{pane_height}'
)

best_id=
best_overlap=0
best_distance=0
target_x=0
target_y=0
target_w=0
target_h=0
while read -r candidate_id x y w h; do
  [[ $candidate_id == "$pane_id" ]] && continue
  overlap=0
  distance=0
  case "$direction" in
    left | right)
      if [[ $direction == left ]] && ((x + w + 1 != source_x)); then continue; fi
      if [[ $direction == right ]] && ((source_x + source_w + 1 != x)); then continue; fi
      start=$((source_y > y ? source_y : y))
      end=$((source_y + source_h < y + h ? source_y + source_h : y + h))
      overlap=$((end - start))
      distance=$((source_y * 2 + source_h - y * 2 - h))
      ;;
    up | down)
      if [[ $direction == up ]] && ((y + h + 1 != source_y)); then continue; fi
      if [[ $direction == down ]] && ((source_y + source_h + 1 != y)); then continue; fi
      start=$((source_x > x ? source_x : x))
      end=$((source_x + source_w < x + w ? source_x + source_w : x + w))
      overlap=$((end - start))
      distance=$((source_x * 2 + source_w - x * 2 - w))
      ;;
  esac
  ((overlap > 0)) || continue
  ((distance < 0)) && distance=$((-distance))
  if ((overlap > best_overlap)) || { ((overlap == best_overlap)) && ((distance < best_distance)); }; then
    best_id=$candidate_id
    best_overlap=$overlap
    best_distance=$distance
    target_x=$x
    target_y=$y
    target_w=$w
    target_h=$h
  fi
done < <(tmux list-panes -t "$window_id" -F '#{pane_id} #{pane_left} #{pane_top} #{pane_width} #{pane_height}')

if [[ -z $best_id ]]; then
  tmux display-message -t "$pane_id" "No pane to the $direction"
  exit 0
fi

flags=()
case "$direction" in
  left | right)
    if ((target_h > source_h)); then
      flags=(-v)
      ((source_y * 2 + source_h < target_y * 2 + target_h)) && flags+=(-b)
    else
      flags=(-h)
      [[ $direction == left ]] && flags+=(-b)
    fi
    ;;
  up | down)
    if ((target_w > source_w)); then
      flags=(-h)
      ((source_x * 2 + source_w < target_x * 2 + target_w)) && flags+=(-b)
    else
      flags=(-v)
      [[ $direction == up ]] && flags+=(-b)
    fi
    ;;
esac

tmux move-pane "${flags[@]}" -d -s "$pane_id" -t "$best_id"
tmux select-pane -t "$pane_id"
