# Vidro real no WezTerm (Arch nativo / Archcraft)

O Archcraft usa Openbox + `picom`. Por padrão o picom roda no backend `xrender`, que não desfoca nada. Para o vidro
(desfoque do que está atrás do terminal) o picom precisa do backend `glx`, e o desfoque vale só para o WezTerm.
Isto é configuração do **sistema** (`~/.config/picom.conf`), não faz parte do `restore.sh`: aplique à mão no notebook.

Em `~/.config/picom.conf`:

```conf
backend = "glx";
# blur-kern = "3x3box";        # método do xrender; comente
blur-method = "dual_kawase";
blur-strength = 7;             # 1–20; maior = mais fosco

rules: (
  # ...regras que já existem...
  , {
    match = "class_g = 'org.wezfurlong.wezterm'";
    blur-background = true;
  }
)
```

Reiniciar o compositor (a tela pisca um instante): `pkill -x picom; setsid picom &`.

O `.wezterm.lua` põe a translucidez nas **camadas** do fundo (`GLASS`, 0,55 no Linux): com `config.background` o
`window_background_opacity` não vale, então sem isso a janela fica sólida e o blur não aparece. Menor `GLASS` = mais
vidro (mais do fundo desfocado atravessa); a imagem do tema e o véu (`BG_VEIL`) mantêm as letras legíveis. O desfoque
só aparece onde há algo atrás da janela (não com ela maximizada sobre um desktop vazio).

Teste rápido: abra uma imagem de xadrez fino atrás de uma janela do WezTerm; dentro da janela o xadrez deve virar cinza liso.

## Barra (polybar) e dock (Plank)
O motor `theme` deixa a polybar e a dock translúcidas (alfa nas cores). **Só a polybar leva desfoque.** O Plank fica de
fora: a janela dele cobre a base da tela inteira, e o blur borraria tudo que está atrás (ex.: a barra de status do tmux),
mesmo fora do painel dos ícones. Pontos que pegam:

- Com `blur-method` definido, o picom desfoca **toda** janela translúcida por padrão. O `blur-background = false` global
  não vale nas regras: o que decide é a regra. Por isso o Plank tem uma regra explícita `false`.
- Em regras que se sobrepõem, **a última vence**. Mantenha a regra do Plank depois da do Polybar.
- Tire o `blur-background = false;` da regra dos docks que já existe, senão ele vence para a polybar.

```conf
  , {
    match = "class_g = 'Polybar'";
    blur-background = true;
  }, {
    match = "class_g = 'Plank'";
    blur-background = false;
  }
```
(Não consegui confirmar visualmente o desfoque da polybar: o gerenciador de janelas não deixa pôr uma janela por baixo dela.)

## Voltar ao que era antes
```sh
cp ~/.config/picom.conf.bak-xrender ~/.config/picom.conf && pkill -x picom; setsid picom &
```
Se o picom não subir com o `glx`, o mesmo comando restaura o `xrender` (a tela fica sem blur, só transparência).

## Ajustes
- Mais fosco/mais nítido: `blur-strength`.
- Letras difíceis de ler: aumente `GLASS` (mais sólido) ou `BG_VEIL` em `.wezterm.lua`.
- WezTerm no Windows: o vidro vem do Acrylic do sistema, nada a fazer aqui.
