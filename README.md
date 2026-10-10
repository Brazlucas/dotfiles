# dotfiles (WSL)

Backup das configs do meu WSL: zsh (oh-my-zsh + plugins), tmux/tmuxp, nvim (LazyVim), btop, htop, lazygit, git, etc.

- `./backup.sh`  copia as configs atuais (WSL em `home/`, WezTerm do Windows em `windows/`) e atualiza `packages/`
- `./restore.sh` restaura tudo no `$HOME` (faz backup dos arquivos antigos) e clona os plugins do zsh/tmux

Segredos (tokens do ngrok, `.git-credentials`, `.ssh`, `.aws`, `.npmrc`, históricos) **não** são versionados.

## Visual cyberpunk
- **WezTerm** (`windows/.wezterm.lua`): tema Cyberpunk, vidro em camadas (Acrylic + gradiente + reflexo + scanlines), abas largas com ícone e X, status à direita. `Ctrl+Alt+T` cicla os temas.
- **tmux** (`home/.config/tmux/tmux.conf`): barra superior neon, bordas rosa, popup com gato ASCII ao anexar.
- **Gato ASCII** (`home/.config/cyber/`): `NEKO_OFF=1` desliga; qualquer tecla pula a animação.

## Toggle do tema cyberpunk
Um estado só (`C:\Users\<user>\.cyber_state`, `on`/`off`) controla WezTerm, tmux e nvim; desligado, tudo volta ao visual original.
- WezTerm: `Ctrl+Alt+G` · tmux: `prefixo + T` · nvim: `<leader>uz` · terminal: `~/.config/cyber/toggle.sh [on|off]`
- tmux: `cyber.conf` (neon) e `classic.conf` (original), escolhidos pelo estado.
- nvim: colorscheme `cyberpunk` (transparente, `colors/cyberpunk.lua`) ↔ `wildcharm` (original).

## Tema do nvim exportado
`themes/cyberpunk.nvim/` — colorscheme independente (instruções no README da pasta).
