#!/usr/bin/env bash
# Copia as configs do $HOME para este repositório (home/) e atualiza as listas de pacotes.
set -euo pipefail
cd "$(dirname "$0")"

FILES=(.zshrc .tmux.conf .nanorc .tool-versions .gitconfig tmuxpconf.yaml workspace2.yaml workspace-lite.yaml)
DIRS=(.tmuxp
  .config/nvim .config/nvim.astronvim
  .config/btop .config/htop .config/lazygit .config/lazydocker .config/gitui
  .config/git .config/neofetch .config/thefuck .config/tmux .config/yay
  .config/psysh .config/systemd .config/facilita .config/cyber .config/theme)
# .config/pgcli: só o arquivo de config (history/log ficam de fora)
EXTRA=(.config/pgcli/config)

rm -rf home && mkdir -p home
for f in "${FILES[@]}" "${EXTRA[@]}"; do
  [ -e "$HOME/$f" ] && install -D "$HOME/$f" "home/$f"
done
for d in "${DIRS[@]}"; do
  [ -d "$HOME/$d" ] && mkdir -p "home/$d" && cp -a "$HOME/$d/." "home/$d/"
done
# WezTerm roda no Windows: copia a config (o tema vem do sistema `theme`) para windows/
if [ -z "${WINHOME:-}" ]; then
  if [ -z "${HUB_FORCE_NATIVE:-}" ] && { [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; }; then WINHOME=/mnt/c/Users/blubs; else WINHOME=$HOME; fi
fi
rm -rf windows && mkdir -p windows
for f in .wezterm.lua .wezterm_switcher.lua; do [ -e "$WINHOME/$f" ] && cp -a "$WINHOME/$f" "windows/$f"; done
# planos de fundo por tema (imagens prontas + a arte de origem; regeneráveis com ./gen-backgrounds.sh)
if [ -d "$WINHOME/.wezterm_bg" ]; then mkdir -p windows/.wezterm_bg && cp -a "$WINHOME/.wezterm_bg/." windows/.wezterm_bg/; fi

# exporta cada tema do nvim como pacote independente (themes/<nome>.nvim) — nunca perde o tema
for p in "$HOME"/.config/theme/palettes/*.toml; do
  n=$(basename "$p" .toml); [ "$n" = classic ] && continue
  "$HOME/.local/bin/theme" export nvim "$n" "$PWD/themes/$n.nvim" >/dev/null
done

# nunca versionar estes (build é regenerado pelo `theme`)
rm -rf home/.config/theme/build home/.config/theme/exports
find home -name __pycache__ -prune -exec rm -rf {} + 2>/dev/null || true
find home -name .git -prune -exec rm -rf {} + 2>/dev/null || true
find home -name '*.log' -delete

mkdir -p packages
{ pacman -Qqen > packages/pacman-explicit.txt; pacman -Qqem > packages/aur-explicit.txt; } 2>/dev/null || true
npm ls -g --depth=0 --parseable 2>/dev/null | tail -n +2 | xargs -n1 basename > packages/npm-global.txt 2>/dev/null || true
pip list --user --format=freeze 2>/dev/null > packages/pip-user.txt || true
asdf plugin list 2>/dev/null > packages/asdf-plugins.txt || true
echo "Backup atualizado."
