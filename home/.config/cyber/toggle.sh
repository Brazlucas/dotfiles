#!/usr/bin/env bash
# Mantido por compatibilidade: delega ao sistema de temas (`theme`).
# Uso: toggle.sh [on|off|toggle]  (on = último tema, off = clássico)
case "${1:-toggle}" in
  on)  exec ~/.local/bin/theme set "$(cat ~/.config/theme/build/.last_theme 2>/dev/null || echo cyberpunk)" ;;
  off) exec ~/.local/bin/theme set classic ;;
  *)   exec ~/.local/bin/theme toggle ;;
esac
