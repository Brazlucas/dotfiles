# dotfiles (WSL + WezTerm)

Backup das configs do meu ambiente: zsh (oh-my-zsh + plugins), tmux/tmuxp, nvim (LazyVim), WezTerm (Windows), btop, htop, lazygit, git, etc.

- `./backup.sh`  copia as configs atuais (WSL em `home/`, WezTerm do Windows em `windows/`), exporta os temas do nvim e atualiza `packages/`
- `./restore.sh` restaura tudo (faz backup dos arquivos antigos), clona os plugins, instala o CLI `theme` (binário Rust do [hub-tui](https://github.com/Brazlucas/hub-tui)) e ativa o tema salvo

Segredos (tokens do ngrok, `.git-credentials`, `.ssh`, `.aws`, `.npmrc`, históricos) **não** são versionados.

## Sistema de temas (`theme`)
Um tema é **só um arquivo de paleta** (`home/.config/theme/palettes/<nome>.toml`). O CLI `theme` gera a config de todas as ferramentas a partir dela.

> **O motor é um binário Rust**, o crate `crates/theme` do repo [hub-tui](https://github.com/Brazlucas/hub-tui) (instalado em `~/.local/bin/theme`). O motor Python original continua em `home/.config/theme/bin/theme` só como **reserva**: `theme-py` roda ele, e `ln -sf ~/.config/theme/bin/theme ~/.local/bin/theme` volta a usá-lo. Paletas e templates (aqui) são os mesmos para os dois. A saída do Rust é idêntica à do Python (`scripts/theme-golden.sh` no hub-tui).

O que é gerado:

| ferramenta | o que é gerado |
|---|---|
| WezTerm | esquema de cores, moldura/abas, vidro, fonte (`C:\Users\<user>\.wezterm_theme.lua`) |
| tmux | barra, bordas, mensagens, popup do gato |
| nvim | colorscheme `theme` (transparente, derivado da paleta) |
| zsh | prompt de duas linhas, `LS_COLORS`/`eza`, `fzf`, cores do autosuggestions e syntax-highlighting |
| Claude Code | usa `dark-ansi` (herda a paleta ANSI do WezTerm: acompanha o tema ao vivo e na prévia do seletor) |
| bat · delta · lazygit · btop · ripgrep · pgcli | tema/estilo equivalente |
| hub-tui (`hub`, `mgpu`/`mqwen`) | `modo.toml` gerado por tema; o TUI recarrega ao vivo quando o tema muda |

**Temas (25 + o original):** `cyberpunk` (padrão), `tokyo-night`, `catppuccin-mocha`, `dracula`, `gruvbox-dark`, `nord`, `one-dark`, `rose-pine`, `kanagawa`, `everforest`, `solarized-dark`, `synthwave-84`, `matrix`, `ayu-mirage`, `github-dark`, `night-owl`, `palenight`, `oxocarbon`, `nightfox`, `monokai-pro`, `horizon`, `poimandres`, `everblush` e os originais `acid-jungle` (lima/amarelo/ciano) e `blade-runner` (laranja-néon/ciano). `classic` é o visual de antes de tudo isso: fica **fora** do ciclo `next/prev` e do seletor `Ctrl+Alt+T`, e é separado também na aba TEMAS do hub (tecla `o`); `theme toggle` / `theme set classic` levam até ele.

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
Ajustes em `windows/.wezterm_switcher.lua` (`confirm_mode = 'release'|'timeout'`, `step_min_interval`, `debug`). Os dados vêm de `theme sync` (`C:\Users\<user>\.wezterm_themes\`). Testes: `nvim -l home/.config/theme/tests/switcher_test.lua` (seletor) e, no hub-tui, `cargo test` + `scripts/theme-golden.sh` (motor).

**Plano de fundo (vidro fosco):** cada tema tem a sua imagem pronta em `windows/.wezterm_bg/<tema>.jpg` (a arte `macchiato.png` em duotone com as cores do tema, desfocada). O WezTerm só escolhe o arquivo do tema ativo e põe um véu da cor do tema por cima (letras legíveis), então trocar de tema não gera nada na hora e **o Windows/WSL não precisa de ImageMagick**. Ao criar ou editar uma paleta: `theme sync && ./gen-backgrounds.sh` (precisa de `imagemagick`) e commite os `.jpg`. Ajustes de intensidade em `.wezterm.lua` (`BG_OPACITY`, `BG_VEIL`) e do desfoque em `gen-backgrounds.sh` (`BLUR`).
- **Arch nativo:** a janela fica opaca (o picom do Archcraft usa o backend `xrender`, sem blur real); o "vidro" é o da imagem.
- **WSL/Windows:** a janela mantém o Acrylic do Windows (vidro de verdade) com a imagem por baixo.
- Sem a imagem do tema, fica só a cor do tema.
- **Desktop (Arch/X11, feito pelo motor `theme`):** `theme set` dispara em segundo plano `theme _desktop <tema>` (o `set` continua voltando em ~40 ms) que (1) faz **transição suave** do papel de parede (~0,3 s, 12 frames direto no X11; as imagens `home/.config/theme/wallpapers/<tema>.jpg` saem do `gen-backgrounds.sh`), (2) reescreve as cores da **polybar** (`colors.ini`, translúcida) e a reinicia, e (3) gera o tema da dock **Plank**. `classic` devolve o original (guardado na primeira vez em `build/.desktop-orig`; backup da polybar em `colors.ini.theme-orig`). Não roda no WSL/Windows nem sem `$DISPLAY` (`THEME_NO_DESKTOP=1` desliga). Para o vidro da polybar e da dock, veja `docs/picom-glass.md`. A transição é só do papel de parede (visível também através do terminal em vidro): o WezTerm não anima troca de paleta, e polybar/dock trocam de uma vez.

**Transições no tmux:** ao trocar de janela, a aba da janela atual acende e assenta na cor do tema (~0,2 s, 8 quadros); ao trocar de painel, a borda do painel ativo faz o mesmo. É o `home/.config/cyber/tmux-anim`, disparado pelos hooks `session-window-changed` e `window-pane-changed` do tema (`tmux.conf.tmpl`); cada troca cancela a animação anterior e sempre termina na cor de repouso. Desligue com `tmux set -g @anim_off 1`; ajuste com `FRAMES`, `STEP` e `FLASH` no script. O tema `classic` não tem os hooks. O WezTerm em si não anima trocas de aba/janela (só o cursor, via `cursor_blink_ease_*`).

### Criar um tema novo
1. Copie uma paleta: `cp home/.config/theme/palettes/dracula.toml home/.config/theme/palettes/meu-tema.toml`
2. Edite as cores (`[colors]`, `[diff]`, `[tabbar]`, `[mascot]`) e as opções de `[features]` (vidro, opacidade, borda neon, estilo do tmux...).
3. `theme set meu-tema`. Pronto — nada mais precisa ser tocado.

Estado em `C:\Users\<user>\.theme_state`. Saída gerada fica em `~/.config/theme/build/<tema>/` (não versionada).
Utilitários usados pelo tema: `sudo pacman -S --needed fzf eza bat git-delta`.

## Tema do nvim exportado
`themes/<tema>.nvim/` — colorschemes independentes (sem depender do `theme`), regenerados a cada `backup.sh`. Veja `themes/cyberpunk.nvim/README.md`.

## Arch nativo (notebook) — mesma estrutura, sem WSL

O mesmo repositório serve ao WSL (WezTerm no Windows) e ao Linux nativo. `restore.sh` detecta o ambiente (`WSL_DISTRO_NAME` ou `microsoft` em `/proc/sys/kernel/osrelease`; `HUB_FORCE_NATIVE=1` força o modo nativo para testes):

| | WSL | Arch nativo |
|---|---|---|
| `WINHOME` (WezTerm + estado do tema) | `/mnt/c/Users/blubs` | `$HOME` |
| WezTerm | `.wezterm.lua` copiado para o Windows (abre `wsl.exe`) | `~/.wezterm.lua` (shell de login, sem Acrylic) |
| hub-tui | abas Sistemas / GPU / QWEN / Temas | Sistemas / Temas / projetos |
| workspace tmuxp | `workspace2.yaml` | `workspace-lite.yaml` se `~/repo/work/infocar-backend` não existir |

Passo a passo no notebook:

```sh
git clone <dotfiles> ~/dotfiles && git clone git@github.com:Brazlucas/hub-tui.git ~/repo/hub-tui
cd ~/dotfiles && ./restore.sh --packages     # pacman (packages/core.txt), rustup, plugins, theme e dotfiles
cd ~/repo/hub-tui && cargo build --release && install -m755 target/release/hub ~/.local/bin/hub
```

`packages/core.txt` é a lista mínima; `pacman-explicit.txt` é só referência do PC pessoal. Não é instalado automaticamente: docker (`usermod -aG docker`), asdf/phpenv/nvm — o `.zshrc` ignora o que não existir.
