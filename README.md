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
| Claude Code | usa `dark-ansi` (herda a paleta ANSI do WezTerm: acompanha o tema ao vivo e na prévia do seletor) |
| bat · delta · lazygit · btop · ripgrep · pgcli | tema/estilo equivalente |
| modo-tui (`mgpu`/`mqwen`) | `modo.toml` gerado por tema; o TUI recarrega ao vivo quando o tema muda |

**Temas (16 + o original):** `cyberpunk` (padrão), `tokyo-night`, `catppuccin-mocha`, `dracula`, `gruvbox-dark`, `nord`, `one-dark`, `rose-pine`, `kanagawa`, `everforest`, `solarized-dark`, `synthwave-84`, `matrix`, `ayu-mirage` e os originais `acid-jungle` (lima/amarelo/ciano) e `blade-runner` (laranja-néon/ciano). `classic` é o visual de antes de tudo isso e fica fora do ciclo `next/prev`.

```sh
theme list              # lista e marca o ativo
theme set tokyo-night   # troca tudo; WezTerm, tmux, nvim e os shells abertos (zsh) acompanham sozinhos
theme toggle            # ativa/desativa (último tema <-> classic)
theme next | prev       # cicla
theme export nvim <t>   # colorscheme do nvim autocontido (pasta themes/<t>.nvim)
theme repair            # limpa estado acumulado do tmux e redesenha os clientes (se algo ficar estranho)
```
**Atalhos:** WezTerm `Ctrl+Alt+G` (liga/desliga) · tmux `prefixo + T` · nvim `<leader>uz`.

**Seletor estilo Alt+Tab (`Ctrl+Alt+T` / `Ctrl+Alt+Shift+T`):** um toque cicla para o próximo tema; segurando `Ctrl+Alt` e batendo `T` você avança vendo a **prévia ao vivo** (o WezTerm se recolore e uma faixa mostra anterior · atual · seguinte) e ao **soltar** o tema é aplicado em tudo. `Esc` cancela, `Enter` confirma, setas navegam. Segurar só o `T` avança em ritmo controlado.
Ajustes em `windows/.wezterm_switcher.lua` (`confirm_mode = 'release'|'timeout'`, `step_min_interval`, `debug`). Os dados vêm de `theme sync` (`C:\Users\<user>\.wezterm_themes\`). Testes do motor: `nvim -l home/.config/theme/tests/switcher_test.lua`.

### Criar um tema novo
1. Copie uma paleta: `cp home/.config/theme/palettes/dracula.toml home/.config/theme/palettes/meu-tema.toml`
2. Edite as cores (`[colors]`, `[diff]`, `[tabbar]`, `[mascot]`) e as opções de `[features]` (vidro, opacidade, borda neon, estilo do tmux...).
3. `theme set meu-tema`. Pronto — nada mais precisa ser tocado.

Estado em `C:\Users\<user>\.theme_state`. Saída gerada fica em `~/.config/theme/build/<tema>/` (não versionada).
Utilitários usados pelo tema: `sudo pacman -S --needed fzf eza bat git-delta`.

## Tema do nvim exportado
`themes/<tema>.nvim/` — colorschemes independentes (sem depender do `theme`), regenerados a cada `backup.sh`. Veja `themes/cyberpunk.nvim/README.md`.
