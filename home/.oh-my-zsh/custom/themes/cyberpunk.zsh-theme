# Cyberpunk — prompt em duas linhas, paleta neon (rosa/ciano/azul/violeta/menta)
# Liga/desliga junto com o resto do tema (~/.config/cyber/toggle.sh); desligado volta o "suvash".

function _cyber_prompt_char {
  git branch >/dev/null 2>&1 && echo '±' && return
  echo '❯'
}

function _cyber_venv {
  [[ -n "$VIRTUAL_ENV" ]] && echo " %F{#5c6b80}(%f%F{#00ffa3}${VIRTUAL_ENV:t}%f%F{#5c6b80})%f"
}

PROMPT='%F{#ff2a6d}╭─%f %B%F{#ff2a6d}%n%f%b%F{#5c6b80}@%f%F{#05f2ff}%m%f %F{#5c6b80}in%f %B%F{#3d8bff}%~%f%b$(git_prompt_info)$(_cyber_venv)
%F{#ff2a6d}╰─%f%(?.%F{#05f2ff}.%F{#ff2a6d})$(_cyber_prompt_char)%f '

# exit code (se falhou) + hora, à direita
RPROMPT='%(?..%F{#ff2a6d}✘ %?%f  )%F{#5c6b80}%D{%H:%M}%f'

ZSH_THEME_GIT_PROMPT_PREFIX=" %F{#5c6b80}on%f %F{#b45cff} "
ZSH_THEME_GIT_PROMPT_SUFFIX='%f'
ZSH_THEME_GIT_PROMPT_DIRTY=' %F{#ff2a6d}✗'
ZSH_THEME_GIT_PROMPT_CLEAN=' %F{#00ffa3}✓'
