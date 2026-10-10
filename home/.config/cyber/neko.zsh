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

  local order=(1 2 1 3 1 2 1 3 4 4 4) i k line drawn=0
  for i in $order; do
    (( drawn )) && printf '\e[6A'
    for line in "${(@f)f[$i]}"; do printf '\e[2K\r%s%s%s\n' $pink "$line" $off; done
    drawn=1
    read -rs -k1 -t 0.16 k && break
  done
  printf '\e[2K\r%s  ◢ neko@wsl%s %s// system online ◣%s\n' $cyan $off $dim $off
}
