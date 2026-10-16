#!/usr/bin/env bash
# Restaura as configs deste repositório no $HOME e instala plugins do zsh/tmux.
set -euo pipefail
cd "$(dirname "$0")"

# Ambiente: WSL (WezTerm no Windows) ou Linux nativo (Arch). Opções: --packages instala os pacotes de packages/core.txt
IS_WSL=0
if [ -z "${HUB_FORCE_NATIVE:-}" ] && { [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; }; then IS_WSL=1; fi
INSTALL_PACKAGES=0
for a in "$@"; do
  case "$a" in
    --packages) INSTALL_PACKAGES=1 ;;
    --no-packages) INSTALL_PACKAGES=0 ;;
    *) echo "uso: $0 [--packages|--no-packages]" >&2; exit 2 ;;
  esac
done
# Onde ficam o WezTerm e o estado do tema: home do Windows no WSL, o próprio $HOME no Linux nativo
if [ -z "${WINHOME:-}" ]; then
  if [ "$IS_WSL" = 1 ]; then WINHOME=/mnt/c/Users/blubs; else WINHOME=$HOME; fi
fi
export WINHOME

if [ "$INSTALL_PACKAGES" = 1 ]; then
  if command -v pacman >/dev/null 2>&1; then
    grep -vE '^\s*(#|$)' packages/core.txt | sudo pacman -S --needed --noconfirm -
    command -v cargo >/dev/null 2>&1 || { command -v rustup >/dev/null 2>&1 && rustup default stable; }
  else
    echo "AVISO: pacman não encontrado; instale os itens de packages/core.txt à mão." >&2
  fi
fi

stamp=$(date +%Y%m%d-%H%M%S)
(cd home && find . -type f) | while read -r f; do
  f=${f#./}
  if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mkdir -p "$HOME/.dotfiles-backup-$stamp/$(dirname "$f")"
    cp -a "$HOME/$f" "$HOME/.dotfiles-backup-$stamp/$f"
  fi
done
cp -a home/. "$HOME/"

# WezTerm: no WSL copia para o home do usuário Windows; no Linux nativo ($WINHOME=$HOME) para o próprio home
if [ -d windows ] && [ -d "$WINHOME" ]; then
  [ -e "$WINHOME/.wezterm.lua" ] && cp -a "$WINHOME/.wezterm.lua" "$WINHOME/.wezterm.lua.bak-$stamp"
  cp -a windows/. "$WINHOME/"
fi

# Arch nativo: os repos do trabalho ficam em ~/repo/infocar, mas os manifestos do hub-tui usam ~/repo/work (layout do WSL).
# Um symlink resolve sem alterar os manifestos; no WSL (IS_WSL=1) nada é tocado.
if [ "$IS_WSL" = 0 ] && [ -d "$HOME/repo/infocar" ] && [ ! -e "$HOME/repo/work" ]; then
  ln -s "$HOME/repo/infocar" "$HOME/repo/work"
fi

# estado do tema cyberpunk (on/off) — usado por WezTerm, tmux e nvim
[ ! -d "$WINHOME" ] || [ -e "$WINHOME/.cyber_state" ] || printf 'on' > "$WINHOME/.cyber_state"

# oh-my-zsh + plugins
[ -d "$HOME/.oh-my-zsh" ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
cp -a home/.zshrc "$HOME/.zshrc"
C="$HOME/.oh-my-zsh/custom/plugins"
clone() { [ -d "$C/$2" ] || git clone --depth 1 "$1" "$C/$2"; }
clone https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions
clone https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
clone https://github.com/marlonrichert/zsh-autocomplete zsh-autocomplete
# dependência do zsh-autocomplete (o .zshrc já aponta o fpath para ela)
[ -d "$HOME/.cache/zsh/zasync" ] || git clone --depth 1 https://github.com/marlonrichert/zasync "$HOME/.cache/zsh/zasync"

# tmux plugins (tpm instala os demais: sensible, yank...)
[ -d "$HOME/.tmux/plugins/tpm" ] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
[ -d "$HOME/.tmux/plugins/tmux-resurrect" ] || git clone --depth 1 https://github.com/tmux-plugins/tmux-resurrect "$HOME/.tmux/plugins/tmux-resurrect"

# sistema de temas: o CLI `theme` é o binário Rust do hub-tui (crates/theme); o motor Python original
# (home/.config/theme/bin/theme) fica só como reserva, no atalho `theme-py`. Nunca desfaz uma instalação Rust existente.
mkdir -p "$HOME/.local/bin"
chmod +x "$HOME/.config/theme/bin/theme"
ln -sfn "$HOME/.config/theme/bin/theme" "$HOME/.local/bin/theme-py"
HUB_DIR="${HUB_TUI_DIR:-$HOME/repo/hub-tui}"
THEME_BIN="$HOME/.local/bin/theme"
install_rust_theme() {
  if [ -f "$HUB_DIR/Cargo.toml" ] && command -v cargo >/dev/null 2>&1; then
    (cd "$HUB_DIR" && cargo build --release -p theme-engine) || return 1
  fi
  [ -x "$HUB_DIR/target/release/theme" ] || return 1
  rm -f "$THEME_BIN" && install -m755 "$HUB_DIR/target/release/theme" "$THEME_BIN"
}
if [ -x "$THEME_BIN" ] && [ ! -L "$THEME_BIN" ] && [ -z "${THEME_REINSTALL:-}" ]; then
  echo "theme: binário Rust já instalado em $THEME_BIN (THEME_REINSTALL=1 para reinstalar)"
elif install_rust_theme; then
  echo "theme: binário Rust instalado a partir de $HUB_DIR"
else
  echo "AVISO: hub-tui não encontrado em $HUB_DIR (git clone git@github.com:Brazlucas/hub-tui.git; cargo build --release -p theme-engine)." >&2
  echo "       Usando o motor Python de reserva por enquanto." >&2
  ln -sfn "$HOME/.config/theme/bin/theme" "$THEME_BIN"
fi
"$THEME_BIN" set "$(cat "$WINHOME/.theme_state" 2>/dev/null || echo cyberpunk)"
echo "Utilitários do tema: sudo pacman -S --needed fzf eza bat git-delta   (depois: theme set <tema> para ativar as cores)"

echo "tmux: abra o tmux e aperte prefixo + I (ou rode ~/.tmux/plugins/tpm/bin/install_plugins dentro do tmux)"
echo "Pacotes: veja packages/ (ex.: sudo pacman -S --needed - < packages/pacman-explicit.txt)"
echo "Pronto. Abra um novo terminal. Backup dos arquivos antigos em ~/.dotfiles-backup-$stamp"
