# Ideias para as próximas sessões

Esforço: **P** ≈ 30 min · **M** ≈ 1–2 h · **G** ≈ meio dia. ★ = minha recomendação para começar.

## 1. Seletor de tema (Ctrl+Alt+T) — evoluir o "Alt+Tab"
- ★ **MRU de verdade (M):** tocar `Ctrl+Alt+T` alterna entre os **dois últimos** temas (como o Alt+Tab real); segurar mostra a lista em ordem de uso recente. Hoje o ciclo é alfabético.
- **Favoritos e ocultos (P):** `favorite = true` / `hidden = true` na paleta; o carrossel pula os ocultos e mostra os favoritos primeiro.
- **Transição suave (M):** ao confirmar, interpolar as cores em ~5 quadros em vez de trocar de uma vez (limitar quadros — o glitch antigo mostrou que reconfigurar rápido demais trava).
- **Card no tmux (M):** o popup com mini-mockup (prompt, código, diff, paleta) que deixamos de lado, só para quem está dentro do tmux.

## 2. Mais temas e pipeline
- ★ **Temas claros + automático dia/noite (M):** `catppuccin-latte`, `solarized-light`, `rose-pine-dawn`; troca por horário (nascer/pôr do sol) ou seguindo o modo claro/escuro do Windows. Exige `kind = "light"` nos geradores (bg do popup do gato, fade, vidro).
- **Gerar tema a partir de imagem (M):** `theme from-image wallpaper.png` extrai a paleta (k-means) e cria o `.toml`.
- **Modo "design" (P):** `theme edit <nome>` abre a paleta e recarrega ao salvar, para ajustar cor vendo o resultado.
- **Daltônicos e alto contraste (P):** variações de acessibilidade.

## 3. Mais ferramentas coloridas pelo mesmo sistema
- ★ **VS Code / Cursor (M):** gerar `workbench.colorCustomizations` + `editor.tokenColorCustomizations` a partir da paleta.
- **Windows (M):** cor de destaque do Windows (registro) e barra de título, para combinar com o vidro do WezTerm.
- **lazydocker, gitui, yazi, k9s, fastfetch (P cada):** temas gerados; no `htop` só aproximação (esquemas fixos).
- **Wallpaper sincronizado (G):** gerar um papel de parede (gradiente/ruído) do tema e aplicá-lo — o Acrylic do WezTerm mostra o que está por trás.

## 4. Segurança e contexto
- ★ **Tema por ambiente (M):** abrir `pgcli`/ssh de **produção** deixa a borda e a barra em vermelho; hook no zsh detecta host/profile/arquivo `.theme` do projeto.
- **Tema por projeto (P):** `.theme` na raiz do repositório (ex.: `infocar-backend` → `acid-jungle`) aplicado ao entrar na pasta.
- **Perfis de uso (M):** *foco* (sem vidro nem barras), *apresentação* (fonte grande, alto contraste), *bateria* (sem Acrylic nem animações) — independentes do tema.

## 5. Prompt, tmux e mascote
- **Prompt com mais informação (M):** duração do último comando, git ahead/behind, versão de node/php/python do projeto, profile da AWS — tudo com as cores do tema, com *transient prompt*.
- **tmux (M):** CPU/mem/bateria na barra, nome do projeto, indicador do tema atual; `prefix + Y` abre o seletor.
- **Neko (P):** mascote que muda por tema, dorme quando ocioso, frases aleatórias; opção de aparecer só na 1ª sessão do dia.
- **Seletor de sessões/pastas (M):** reaproveitar o motor do seletor (segurar e soltar) para trocar de sessão do tmux ou de projeto com prévia.

## 6. Qualidade e manutenção
- ★ **`theme doctor` + `theme lint` (M):** verifica dependências, links e estado; avisa contraste ruim (WCAG) entre `fg/bg`, `dim/bg`, `sel`.
- **CI no GitHub Actions (P):** rodar o gerador em todas as paletas, os testes `nvim -l`, `luacheck` e `shellcheck` a cada push.
- **`bootstrap.sh` para máquina nova (G):** pacman/yay, fonte Nerd, WezTerm no Windows via `winget`, restore e primeiro tema — tudo num comando.
- **Telemetria local (P):** `theme stats` (temas mais usados, tempo de uso).

## 7. Claude Code
- **Statusline própria (M):** gerada com as cores do tema (modelo, pasta, branch, custo/contexto) e o neko.
- **Hooks (P):** avisar com toast do WezTerm quando uma tarefa longa termina.
- **Investigar as "letras tortas" (P):** já aplicamos o tema do Claude com atraso e de forma atômica; se voltar, capturar o momento (`theme doctor` pode gravar o estado).

## 8. Fontes e vidro
- **Seletor de fonte/tamanho (M):** `Ctrl+Alt+F` no mesmo estilo Alt+Tab (prévia ao vivo, confirma ao soltar).
- **Opacidade em tempo real (P):** `Ctrl+Alt+↑/↓` ajusta o vidro; salvar por tema.

---
### Sugestão de ordem para amanhã
1. MRU no seletor (1) → 2. Temas claros + dia/noite (2) → 3. `theme doctor`/`lint` + CI (6) → 4. VS Code/Cursor (3) → 5. Tema por ambiente de produção (4).
Cada item cabe em uma sessão curta e não depende dos outros.
