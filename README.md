# dotfiles (WSL + WezTerm)

Backup das configs do meu ambiente: zsh (oh-my-zsh + plugins), tmux/tmuxp, nvim (LazyVim), WezTerm (Windows), btop, htop, lazygit, git, etc.

- `./backup.sh`  copia as configs atuais (WSL em `home/`, WezTerm do Windows em `windows/`), exporta os temas do nvim e atualiza `packages/`
- `./restore.sh` restaura tudo (faz backup dos arquivos antigos), clona os plugins e ativa o tema salvo

Segredos (tokens do ngrok, `.git-credentials`, `.ssh`, `.aws`, `.npmrc`, históricos) **não** são versionados.

## Sistema de temas (`theme`)
Um tema é **só um arquivo de paleta** (`home/.config/theme/palettes/<nome>.toml`). O CLI `theme` gera a config de todas as ferramentas a partir dela:

| ferramenta | o que é gerado |
|---|---|
| WezTerm | esquema de cores, moldura/abas, vidro, fonte (`C:\Users\<user>\.wezterm_theme.lua`) |
| tmux | barra, bordas, mensagens, popup do gato |
| nvim | colorscheme `theme` (transparente, derivado da paleta) |
| zsh | prompt de duas linhas, `LS_COLORS`/`eza`, `fzf`, cores do autosuggestions e syntax-highlighting |
| Claude Code | `~/.claude/themes/<tema>.json` + `theme` no `settings.json` |
| bat · delta · lazygit · btop · ripgrep · pgcli | tema/estilo equivalente |

**Temas:** `cyberpunk` (padrão), `tokyo-night`, `catppuccin-mocha`, `dracula`, `acid-jungle` (original: lima/amarelo/ciano) e `classic` (o visual original antes de tudo isso).

```sh
theme list              # lista e marca o ativo
theme set tokyo-night   # troca tudo (WezTerm, tmux e nvim recarregam sozinhos; zsh: exec zsh)
theme toggle            # ativa/desativa (último tema <-> classic)
theme next | prev       # cicla
theme export nvim <t>   # colorscheme do nvim autocontido (pasta themes/<t>.nvim)
```
**Atalhos:** WezTerm `Ctrl+Alt+G` (liga/desliga) · `Ctrl+Alt+T` / `Ctrl+Alt+Shift+T` (próximo/anterior) · tmux `prefixo + T` · nvim `<leader>uz`.

### Criar um tema novo
1. Copie uma paleta: `cp home/.config/theme/palettes/dracula.toml home/.config/theme/palettes/meu-tema.toml`
2. Edite as cores (`[colors]`, `[diff]`, `[tabbar]`, `[mascot]`) e as opções de `[features]` (vidro, opacidade, borda neon, estilo do tmux...).
3. `theme set meu-tema`. Pronto — nada mais precisa ser tocado.

Estado em `C:\Users\<user>\.theme_state`. Saída gerada fica em `~/.config/theme/build/<tema>/` (não versionada).
Utilitários usados pelo tema: `sudo pacman -S --needed fzf eza bat git-delta`.

## Tema do nvim exportado
`themes/<tema>.nvim/` — colorschemes independentes (sem depender do `theme`), regenerados a cada `backup.sh`. Veja `themes/cyberpunk.nvim/README.md`.
