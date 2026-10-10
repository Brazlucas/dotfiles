# dotfiles (WSL)

Backup das configs do meu WSL: zsh (oh-my-zsh + plugins), tmux/tmuxp, nvim (LazyVim), btop, htop, lazygit, git, etc.

- `./backup.sh`  copia as configs atuais do `$HOME` para `home/` e atualiza `packages/`
- `./restore.sh` restaura tudo no `$HOME` (faz backup dos arquivos antigos) e clona os plugins do zsh/tmux

Segredos (tokens do ngrok, `.git-credentials`, `.ssh`, `.aws`, `.npmrc`, históricos) **não** são versionados.
