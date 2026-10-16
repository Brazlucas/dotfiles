#!/usr/bin/env bash
# Gera o plano de fundo de cada tema: windows/.wezterm_bg/<tema>.jpg (duotone da arte macchiato.png com as cores
# do tema: fundo -> acento -> texto, desfocado). As imagens ficam no repositório, então o WezTerm só escolhe
# <tema>.jpg na hora da troca (sem gerar nada em tempo real) e o Windows/WSL não precisa de ImageMagick.
# Rode de novo sempre que criar ou editar uma paleta:  ./gen-backgrounds.sh   (ou ./gen-backgrounds.sh <tema>...)
# Lê as cores de <home do WezTerm>/.wezterm_themes/*.lua (gerado por `theme sync`/`theme set`).
set -euo pipefail
cd "$(dirname "$0")"

BLUR=2                       # desfoque (px) a 1920x1080; maior = vidro mais fosco
QUALITY=92
SRC=windows/.wezterm_bg/macchiato.png
OUT=windows/.wezterm_bg
THEMES_DIR="${WINHOME:-$HOME}/.wezterm_themes"
command -v magick >/dev/null || { echo "precisa do ImageMagick (sudo pacman -S imagemagick)" >&2; exit 1; }
[ -d "$THEMES_DIR" ] || { echo "sem $THEMES_DIR: rode \`theme sync\` antes" >&2; exit 1; }

# primeiro valor '#rrggbb' de uma chave do bloco `scheme` (as chaves do tab_bar vêm depois)
val() { sed -n "s/^[[:space:]]*$2 = '\(#[0-9a-fA-F]\{6\}\)'.*/\1/p" "$1" | head -1; }

if [ "$#" -gt 0 ]; then names=("$@"); else names=(); for f in "$THEMES_DIR"/*.lua; do n=$(basename "$f" .lua); [ "$n" = index ] || names+=("$n"); done; fi

for n in "${names[@]}"; do
  f="$THEMES_DIR/$n.lua"
  bg=$(val "$f" background); acc=$(val "$f" cursor_bg); fg=$(val "$f" foreground)
  [ -n "$bg" ] && [ -n "$acc" ] && [ -n "$fg" ] || { echo "pulando $n (cores não encontradas)" >&2; continue; }
  # -level 12.21% = cinza do fundo original da arte, que vira exatamente a cor de fundo do tema
  nice -n 10 magick "$SRC" -resize 1920x1080 -colorspace Gray -level 12.21%,100% -blur "0x$BLUR" \
    \( "xc:$bg" "xc:$acc" "xc:$fg" +append -filter Triangle -resize 256x1! \) -clut -colorspace sRGB -type TrueColor \
    -quality "$QUALITY" "$OUT/$n.jpg"
  echo "$n  ($bg $acc $fg)"
done
