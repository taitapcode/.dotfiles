#!/usr/bin/env bash
set -euo pipefail

# niri exposes no IPC for input devices, so the touchpad is toggled through the
# `off` flag of the input.touchpad section, which config.kdl includes from here.
state_file="$HOME/.local/state/niri/touchpad.kdl"

notify() {
  notify-send -a "Touchpad" -i input-touchpad "$1" "$2" || true
}

is_disabled() {
  grep -qE '^[[:space:]]*off[[:space:]]*$' "$state_file" 2>/dev/null
}

write_state() {
  mkdir -p "$(dirname "$state_file")"
  if [ "$1" = "disabled" ]; then
    printf 'input {\n  touchpad {\n    off\n  }\n}\n' >"$state_file"
  else
    printf '// Touchpad enabled: the input.touchpad section of config.kdl applies.\n' >"$state_file"
  fi
}

reload() {
  if [ -z "${NIRI_SOCKET:-}" ]; then
    return 0
  fi
  if ! niri msg action load-config-file >/dev/null 2>&1; then
    echo "warning: niri did not acknowledge the reload (the included file is watched, so it should still apply)" >&2
  fi
}

apply() {
  local wanted="$1"
  write_state "$wanted"
  reload
  if [ "$wanted" = "disabled" ]; then
    notify "Touchpad disabled" "Press the touchpad key again to re-enable it"
    echo "Touchpad disabled"
  else
    notify "Touchpad enabled" "Tap and natural scroll are active again"
    echo "Touchpad enabled"
  fi
}

case "${1:-toggle}" in
  toggle)
    if is_disabled; then
      apply enabled
    else
      apply disabled
    fi
    ;;
  off|disable|disabled) apply disabled ;;
  on|enable|enabled) apply enabled ;;
  status)
    if is_disabled; then
      echo "Touchpad disabled"
    else
      echo "Touchpad enabled"
    fi
    ;;
  help|--help|-h)
    echo "Usage: touchpad [toggle|on|off|status]"
    ;;
  *)
    echo "Unknown command: $1" >&2
    echo "Run 'touchpad help' for usage." >&2
    exit 1
    ;;
esac
