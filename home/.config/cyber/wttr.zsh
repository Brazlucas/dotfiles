# Previsão do tempo (wttr.in) ao abrir um terminal. Para desligar: export WTTR_OFF=1
# Mostra o cache na hora e atualiza em segundo plano (a cada 30 min); sem cache, busca com timeout de 3s.
# Aparece em todo shell novo (inclusive painéis do tmux).

# mostra o cache com as cores do tema ativo (o cache guarda o texto original; sem tema = cores do wttr.in)
_wttr_show() {
  local sedf=~/.config/theme/build/current/wttr.sed
  if [[ -s $sedf ]] && (( $+commands[sed] )); then sed -f $sedf $cache; else cat $cache; fi
}

wttr() {
  [[ -t 1 && -o interactive && -z $WTTR_OFF ]] || return 0
  (( $+commands[curl] )) || return 0

  local cache=~/.cache/wttr/forecast url='https://wttr.in/?0&lang=pt'
  mkdir -p ${cache:h} 2>/dev/null

  local -a fresh; fresh=($cache(N.mm-30))
  if [[ -s $cache ]]; then
    _wttr_show
    # cache velho: renova sem travar o shell (sem job de aviso no prompt)
    (( $#fresh )) || { { curl -fsS -m 5 $url -o $cache.tmp 2>/dev/null && [[ -s $cache.tmp ]] && mv -f $cache.tmp $cache; rm -f $cache.tmp } >/dev/null 2>&1 &! }
  else
    curl -fsS -m 3 $url -o $cache.tmp 2>/dev/null && [[ -s $cache.tmp ]] && mv -f $cache.tmp $cache && _wttr_show
    rm -f $cache.tmp
  fi
  return 0
}
