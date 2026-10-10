#!/usr/bin/env bash
# Restaura as configs deste repositório no $HOME e instala plugins do zsh/tmux.
set -euo pipefail
cd "$(dirname "$0")"

stamp=$(date +%Y%m%d-%H%M%S)
(cd home && find . -type f) | while read -r f; do
  f=${f#./}
  [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && mkdir -p "$HOME/.dotfiles-backup-$stamp/$(dirname "$f")" \
    && cp -a "$HOME/$f" "$HOME/.dotfiles-backup-$stamp/$f"
done
cp -a home/. "$HOME/"

# WezTerm (Windows): copia para o home do usuário Windows
WINHOME=${WINHOME:-/mnt/c/Users/blubs}
if [ -d windows ] && [ -d "$WINHOME" ]; then
  [ -e "$WINHOME/.wezterm.lua" ] && cp -a "$WINHOME/.wezterm.lua" "$WINHOME/.wezterm.lua.bak-$stamp"
  cp -a windows/. "$WINHOME/"
fi

# estado do tema cyberpunk (on/off) — usado por WezTerm, tmux e nvim
[ -e "${WINHOME:-/mnt/c/Users/blubs}/.cyber_state" ] || printf 'on' > "${WINHOME:-/mnt/c/Users/blubs}/.cyber_state"

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

echo "tmux: abra o tmux e aperte prefixo + I (ou rode ~/.tmux/plugins/tpm/bin/install_plugins dentro do tmux)"
echo "Pacotes: veja packages/ (ex.: sudo pacman -S --needed - < packages/pacman-explicit.txt)"
echo "Pronto. Abra um novo terminal. Backup dos arquivos antigos em ~/.dotfiles-backup-$stamp"
