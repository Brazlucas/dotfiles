#!/usr/bin/env bash
# Liga/desliga o tema cyberpunk em tudo (WezTerm, tmux, nvim).
# Uso: toggle.sh [on|off|toggle]   (padrão: toggle)
# Estado em C:\Users\<user>\.cyber_state — o WezTerm recarrega sozinho ao mudar,
# o nvim observa o arquivo e o tmux é recarregado aqui.
STATE=${CYBER_STATE:-/mnt/c/Users/blubs/.cyber_state}
cur=$(cat "$STATE" 2>/dev/null || echo on)
case "${1:-toggle}" in
  on)  new=on ;;
  off) new=off ;;
  *)   [ "$cur" = on ] && new=off || new=on ;;
esac
printf '%s' "$new" > "$STATE"
# recarrega o tmux (servidor padrão), se estiver rodando
if tmux has-session 2>/dev/null; then
  env -u TMUX tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null
  env -u TMUX tmux refresh-client -S 2>/dev/null
  env -u TMUX tmux display-message "cyberpunk: $new" 2>/dev/null
fi
echo "$new"
