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

O `.wezterm.lua` já deixa a janela translúcida (`window_background_opacity` do tema); a imagem do tema e o véu
(`BG_VEIL`) mantêm as letras legíveis. O desfoque só aparece onde há algo atrás da janela (não com ela maximizada
sobre um desktop vazio).

## Voltar ao que era antes
```sh
cp ~/.config/picom.conf.bak-xrender ~/.config/picom.conf && pkill -x picom; setsid picom &
```
Se o picom não subir com o `glx`, o mesmo comando restaura o `xrender` (a tela fica sem blur, só transparência).

## Ajustes
- Mais fosco/mais nítido: `blur-strength`.
- Letras difíceis de ler: aumente `BG_VEIL` em `.wezterm.lua` ou reduza a transparência do tema.
- WezTerm no Windows: o vidro vem do Acrylic do sistema, nada a fazer aqui.
