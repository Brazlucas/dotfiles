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

# tmux plugins
[ -d "$HOME/.tmux/plugins/tmux-resurrect" ] || git clone --depth 1 https://github.com/tmux-plugins/tmux-resurrect "$HOME/.tmux/plugins/tmux-resurrect"

echo "Pacotes: veja packages/ (ex.: sudo pacman -S --needed - < packages/pacman-explicit.txt)"
echo "Pronto. Abra um novo terminal. Backup dos arquivos antigos em ~/.dotfiles-backup-$stamp"
