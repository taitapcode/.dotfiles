#!/usr/bin/env bash

get_limit() {
  if [ -f /sys/class/power_supply/BAT1/charge_control_end_threshold ]; then
    cat /sys/class/power_supply/BAT1/charge_control_end_threshold
  else
    asusctl battery info 2>/dev/null | grep -o '[0-9]\+' || echo "60"
  fi
}

notify() {
  local icon="$1"
  local summary="$2"
  local body="$3"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Battery Health" -i "$icon" "$summary" "$body"
  fi
}

case "${1:-status}" in
  oneshot|full|100)
    asusctl battery oneshot
    notify "battery-full-charging" "Battery" "⚡ One-shot mode: Charging to 100%!"
    echo "Battery limit set to 100% (oneshot)"
    ;;

  limit)
    limit="${2:-60}"
    asusctl battery limit "$limit"
    if [ "$limit" -le 60 ]; then
      icon="battery-060"
    else
      icon="battery-good"
    fi
    notify "$icon" "Battery" "🛡️ Battery limit set to ${limit}%!"
    echo "Battery limit set to ${limit}%"
    ;;

  60|restore)
    asusctl battery limit 60
    notify "battery-060" "Battery" "🛡️ Battery limit set to 60%!"
    echo "Battery limit set to 60%"
    ;;

  toggle)
    current=$(get_limit)
    if [ "$current" -ge 100 ]; then
      asusctl battery limit 60
      notify "battery-060" "Battery" "🛡️ Battery limit set to 60%!"
      echo "Battery limit toggled: 60%"
    else
      asusctl battery oneshot
      notify "battery-full-charging" "Battery" "⚡ One-shot mode: Charging to 100%!"
      echo "Battery limit toggled: 100% (oneshot)"
    fi
    ;;

  status|info)
    current=$(get_limit)
    echo "Current battery limit: ${current}%"
    asusctl battery info 2>/dev/null || true
    ;;

  help|--help|-h)
    echo "Usage: battery [command]"
    echo ""
    echo "Commands:"
    echo "  oneshot     Set one-shot full charge to 100%"
    echo "  limit [N]   Set charge limit to N% (default: 60)"
    echo "  toggle      Toggle between 60% limit and 100% oneshot"
    echo "  status      Show current battery limit"
    ;;

  *)
    echo "Unknown command: $1"
    echo "Run 'battery help' for usage."
    exit 1
    ;;
esac
