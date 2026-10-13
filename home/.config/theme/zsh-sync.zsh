# Mantém o shell sincronizado com o tema ativo (`theme`).
# Carregado pelo ~/.zshrc depois do oh-my-zsh: aplica o tema no início e, a cada prompt,
# reaplica se `theme set/toggle/next` mudou (marcador build/.active). Sem `exec zsh`.

typeset -g _THEME_ACTIVE_FILE=~/.config/theme/build/.active
typeset -g _THEME_APPLIED=""

# valores originais (antes de qualquer tema) — o "classic" volta a eles
typeset -g _THEME_ORIG_LS_COLORS="${LS_COLORS-}"
typeset -g _THEME_ORIG_ALIASES="$(alias -L ls ll la l tree 2>/dev/null)"

# padrões do zsh-syntax-highlighting para as chaves que o tema mexe
typeset -gA _THEME_HL_DEFAULTS=(
  command fg=green builtin fg=green alias fg=green function fg=green
  precommand fg=green,underline reserved-word fg=yellow arg0 fg=green
  path underline unknown-token fg=red,bold single-hyphen-option none double-hyphen-option none
  comment fg=black,bold single-quoted-argument fg=yellow double-quoted-argument fg=yellow
  dollar-double-quoted-argument fg=cyan globbing fg=blue redirection fg=yellow
  commandseparator none history-expansion fg=blue back-quoted-argument none
)

_theme_apply_env() {
  local root=~/.config/theme/build/current
  # 1) volta ao original
  unset EZA_COLORS FZF_DEFAULT_OPTS BAT_THEME LG_CONFIG_FILE RIPGREP_CONFIG_PATH
  if [[ -n $_THEME_ORIG_LS_COLORS ]]; then export LS_COLORS=$_THEME_ORIG_LS_COLORS; else unset LS_COLORS; fi
  unalias ls ll la l tree bcat 2>/dev/null
  [[ -n $_THEME_ORIG_ALIASES ]] && eval "$_THEME_ORIG_ALIASES"
  zstyle -d ':completion:*' list-colors
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  local k; for k v in ${(kv)_THEME_HL_DEFAULTS}; do ZSH_HIGHLIGHT_STYLES[$k]=$v; done
  # 2) aplica o tema (env.zsh do classic não exporta nada)
  [[ -r $root/env.zsh ]] && source $root/env.zsh
}

_theme_apply_prompt() {
  local name; name=$(<~/.config/theme/build/current/zsh_theme) 2>/dev/null || return
  local f=$ZSH_CUSTOM/themes/$name.zsh-theme
  [[ -f $f ]] || f=$ZSH/themes/$name.zsh-theme
  [[ -f $f ]] || return
  unset RPROMPT ZSH_THEME_GIT_PROMPT_UNTRACKED ZSH_THEME_RUBY_PROMPT_PREFIX ZSH_THEME_RUBY_PROMPT_SUFFIX
  PROMPT=
  source $f
}

# retorna 0 se o tema mudou (e foi reaplicado), 1 se nada mudou
_theme_check() {
  local now; now=$(<$_THEME_ACTIVE_FILE) 2>/dev/null || return 1
  [[ $now == $_THEME_APPLIED ]] && return 1
  local first=0; [[ -z $_THEME_APPLIED ]] && first=1
  _THEME_APPLIED=$now
  _theme_apply_env
  # no início o oh-my-zsh já carregou o prompt do tema certo (ZSH_THEME); depois só se mudou
  (( first )) || _theme_apply_prompt
  return 0
}

# a cada prompt novo
_theme_precmd() { _theme_check }

# com o shell parado no prompt: confere a cada 1s (rede de segurança) e redesenha se o tema mudou
TMOUT=1
TRAPALRM() {
  _theme_check && [[ -o zle ]] && zle && zle reset-prompt
  return 0
}

# aviso imediato: o `theme` manda SIGUSR1 aos shells registrados (só estes têm o trap; os antigos não são tocados)
typeset -g _THEME_SHELL_REG=~/.config/theme/build/shells
mkdir -p $_THEME_SHELL_REG 2>/dev/null && : > $_THEME_SHELL_REG/$$
TRAPUSR1() {
  _theme_check && [[ -o zle ]] && zle && zle reset-prompt
  return 0
}
_theme_zshexit() { rm -f $_THEME_SHELL_REG/$$ 2>/dev/null }

autoload -Uz add-zsh-hook
add-zsh-hook precmd _theme_precmd
add-zsh-hook zshexit _theme_zshexit

# lazydocker reinicia sozinho quando o tema muda (ele só lê as cores ao iniciar)
lazydocker() { ~/.config/theme/bin/lazydocker-live "$@" }
