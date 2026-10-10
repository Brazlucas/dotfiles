#!/usr/bin/env bash
# Copia as configs do $HOME para este repositório (home/) e atualiza as listas de pacotes.
set -euo pipefail
cd "$(dirname "$0")"

FILES=(.zshrc .tmux.conf .nanorc .tool-versions .gitconfig tmuxpconf.yaml)
DIRS=(.tmuxp
  .config/nvim .config/nvim.astronvim
  .config/btop .config/htop .config/lazygit .config/lazydocker .config/gitui
  .config/git .config/neofetch .config/thefuck .config/tmux .config/yay
  .config/psysh .config/systemd .config/facilita)
# .config/pgcli: só o arquivo de config (history/log ficam de fora)
EXTRA=(.config/pgcli/config)

rm -rf home && mkdir -p home
for f in "${FILES[@]}" "${EXTRA[@]}"; do
  [ -e "$HOME/$f" ] && install -D "$HOME/$f" "home/$f"
done
for d in "${DIRS[@]}"; do
  [ -d "$HOME/$d" ] && mkdir -p "home/$d" && cp -a "$HOME/$d/." "home/$d/"
done
# nunca versionar estes
find home -name .git -prune -exec rm -rf {} + 2>/dev/null || true
find home -name '*.log' -delete

mkdir -p packages
apt-mark showmanual 2>/dev/null | sort > packages/apt-manual.txt || true
npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | xargs -n1 basename > packages/npm-global.txt 2>/dev/null || true
pip list --user --format=freeze 2>/dev/null > packages/pip-user.txt || true
asdf plugin list 2>/dev/null > packages/asdf-plugins.txt || true
echo "Backup atualizado."
