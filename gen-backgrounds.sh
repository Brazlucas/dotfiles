#!/usr/bin/env bash
# Gera o plano de fundo do terminal e o papel de parede do desktop de cada tema (estilo próprio por tema).
# Veja gen-backgrounds.py. Uso: ./gen-backgrounds.sh [tema ...]   (precisa de python-pillow e python-numpy)
exec python3 "$(dirname "$0")/gen-backgrounds.py" "$@"
