# Gato ASCII rosa animado. É mostrado num popup do tmux ao anexar (veja o hook no tmux.conf).
# Qualquer tecla pula a animação. Para desligar: export NEKO_OFF=1

neko() {
  [[ -t 1 && -z $NEKO_OFF ]] || return 0

  local pink=$'\e[38;2;255;110;199m' cyan=$'\e[38;2;5;242;255m' dim=$'\e[38;2;107;95;168m' off=$'\e[0m'

  # cada frame tem 6 linhas: olhos abertos/fechados + cauda balançando
  local -a f
  f[1]=$'    /\\_/\\\n   ( o.o )\n    > ^ <\n   /|   |\\\n  (_|   |_)  ~\n       \\___/'
  f[2]=$'    /\\_/\\\n   ( o.o )\n    > ^ <\n   /|   |\\\n  (_|   |_) ~\n       \\___/'
  f[3]=$'    /\\_/\\\n   ( -.- )\n    > ^ <\n   /|   |\\\n  (_|   |_)   ~\n       \\___/'
  f[4]=$'    /\\_/\\\n   ( ^.^ )  meow~\n    > ^ <\n   /|   |\\\n  (_|   |_) ~\n       \\___/'

  local order=(1 2 1 3 1 2 1 3 4 4 4) i k line drawn=0 skipped=0
  for i in $order; do
    (( drawn )) && printf '\e[6A'
    for line in "${(@f)f[$i]}"; do printf '\e[2K\r%s%s%s\n' $pink "$line" $off; done
    drawn=1
    read -rs -k1 -t 0.16 k && { skipped=1; break }
  done
  printf '\e[2K\r%s  ◢ neko@wsl%s %s// system online ◣%s\n' $cyan $off $dim $off
  (( skipped )) && return 0

  # fade-out: mistura as cores com o fundo do popup (#080b10) em 8 passos
  sleep 0.9
  local -i step r g b cr cg cb dr dg db
  local pr=255 pg=110 pb=199 cyr=5 cyg=242 cyb=255 dmr=107 dmg=95 dmb=168 bgr=8 bgg=11 bgb=16
  for (( step = 1; step <= 8; step++ )); do
    printf '\e[7A'
    r=$(( pr + (bgr - pr) * step / 8 ));   g=$(( pg + (bgg - pg) * step / 8 ));   b=$(( pb + (bgb - pb) * step / 8 ))
    cr=$(( cyr + (bgr - cyr) * step / 8 )); cg=$(( cyg + (bgg - cyg) * step / 8 )); cb=$(( cyb + (bgb - cyb) * step / 8 ))
    dr=$(( dmr + (bgr - dmr) * step / 8 )); dg=$(( dmg + (bgg - dmg) * step / 8 )); db=$(( dmb + (bgb - dmb) * step / 8 ))
    for line in "${(@f)f[4]}"; do printf '\e[2K\r\e[38;2;%d;%d;%dm%s\e[0m\n' $r $g $b "$line"; done
    printf '\e[2K\r\e[38;2;%d;%d;%dm  ◢ neko@wsl\e[0m \e[38;2;%d;%d;%dm// system online ◣\e[0m\n' $cr $cg $cb $dr $dg $db
    sleep 0.07
  done
}
