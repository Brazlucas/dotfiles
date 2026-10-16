#!/usr/bin/env python3
"""Gera, para cada tema, o plano de fundo do terminal e o papel de parede do desktop, cada tema com um estilo próprio.

  windows/.wezterm_bg/<tema>.jpg             terminal: efeito discreto + a arte macchiato.png em duotone
  home/.config/theme/wallpapers/<tema>.jpg   desktop: o efeito completo (com sol nos temas "synthwave")

Estilos (veja STYLE): grid (synthwave), aurora, stars (céu estrelado), rain (chuva digital) e mesh (malha de brilho).
As cores vêm de <home do WezTerm>/.wezterm_themes/<tema>.lua (gerado por `theme sync`/`theme set`).
Use:  ./gen-backgrounds.sh [tema ...]      (precisa de python-pillow e python-numpy)
"""
import colorsys
import math
import os
import re
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1920, 1080
ROOT = Path(__file__).resolve().parent
ART = ROOT / "windows/.wezterm_bg/macchiato.png"
OUT_TERM = ROOT / "windows/.wezterm_bg"
OUT_WALL = ROOT / "home/.config/theme/wallpapers"
THEMES_DIR = Path(os.environ.get("WINHOME", Path.home())) / ".wezterm_themes"

STYLE = {
    "grid": ["synthwave-84", "blade-runner", "cyberpunk", "acid-jungle"],
    "aurora": ["nord", "everforest", "rose-pine", "kanagawa", "nightfox"],
    "stars": ["tokyo-night", "night-owl", "palenight", "poimandres", "horizon"],
    "rain": ["matrix"],
}
SUN = {"synthwave-84", "blade-runner"}      # desktop: sol listrado no horizonte
TERM_STRENGTH = 0.62                         # quanto do efeito aparece no terminal (o resto é a cor de fundo do tema)


def style_of(name):
    for style, names in STYLE.items():
        if name in names:
            return style
    return "mesh"


# ───────────── cores ─────────────
def rgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.float32)


def mix(a, b, t):
    return a + (b - a) * t


class Colors:
    def __init__(self, name):
        text = (THEMES_DIR / f"{name}.lua").read_text()
        first = lambda key: re.search(rf"^\s*{key} = '(#[0-9a-fA-F]{{6}})'", text, re.M).group(1)
        self.name = name
        self.bg, self.fg, self.a1 = rgb(first("background")), rgb(first("foreground")), rgb(first("cursor_bg"))
        ansi = re.search(r"ansi = \{([^}]*)\}", text).group(1)
        brights = re.search(r"brights = \{([^}]*)\}", text).group(1)
        cand = [rgb(c) for c in re.findall(r"#[0-9a-fA-F]{6}", ansi)[1:7] + re.findall(r"#[0-9a-fA-F]{6}", brights)[1:7]]
        h1 = colorsys.rgb_to_hsv(*(self.a1 / 255))[0]

        def score(c):
            h, s, v = colorsys.rgb_to_hsv(*(c / 255))
            dh = min(abs(h - h1), 1 - abs(h - h1))
            return dh * s * v

        self.a2 = max(cand, key=score)     # segunda cor de destaque: a mais viva e de matiz diferente do acento
        self.a3 = mix(self.a1, self.a2, 0.5)
        self.yellow = rgb(re.findall(r"#[0-9a-fA-F]{6}", ansi)[3])
        # as duas cores mais vivas de matizes diferentes (aurora: o acento do tema pode ser um cinza)
        def vivid(c):
            _, sat, val = colorsys.rgb_to_hsv(*(c / 255))
            return sat * val
        hue = lambda c: colorsys.rgb_to_hsv(*(c / 255))[0]
        # aurora: prefere tons frios (verde, ciano, azul, roxo); sem eles, as cores mais vivas da paleta
        pool = cand + [self.a1, self.a2]
        cool = [c for c in pool if 0.20 <= hue(c) <= 0.85 and vivid(c) > 0.25]
        ranked = sorted(cool or pool, key=vivid, reverse=True)
        self.v1 = ranked[0]
        far = lambda c: min(abs(hue(c) - hue(self.v1)), 1 - abs(hue(c) - hue(self.v1)))
        self.v2 = next((c for c in ranked[1:] if far(c) > 0.07), ranked[1] if len(ranked) > 1 else self.v1)


# ───────────── utilidades ─────────────
YY, XX = np.mgrid[0:H, 0:W].astype(np.float32)


def to_img(a):
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))


def blur(a, r):
    return np.asarray(to_img(a).filter(ImageFilter.GaussianBlur(r)), dtype=np.float32)


def blob(cx, cy, r):
    """Mancha gaussiana (0..1), centro em fração da tela, raio em px."""
    d = np.hypot(XX - cx * W, YY - cy * H) / r
    return np.exp(-d * d)


def vgrad(top, bot, y0=0.0, y1=1.0):
    t = np.clip((YY / H - y0) / (y1 - y0), 0, 1)[..., None]
    return mix(top, bot, t)


def toward(out, color, mask, k):
    """Puxa `out` na direção de `color` onde `mask` (0..1) vale, com força k."""
    return mix(out, color, (np.clip(mask, 0, 1) * k)[..., None])


def vignette(a, strength=0.38):
    d = np.hypot((XX - W / 2) / (W / 2), (YY - H / 2) / (H / 2))
    return a * (1 - strength * np.clip(d - 0.4, 0, 1)[..., None] ** 1.4)


def grain(a, sigma, seed):
    rng = np.random.default_rng(seed)
    return a + rng.normal(0, sigma, (H, W, 1)).astype(np.float32)


def smooth_noise_1d(rng, n, k):
    v = np.convolve(rng.random(n + 2 * k), np.hanning(2 * k + 1) / np.hanning(2 * k + 1).sum(), "same")[k:-k]
    return (v - v.min()) / (v.max() - v.min() + 1e-6)


def seed_of(name):
    return sum(ord(c) * (i + 1) for i, c in enumerate(name))


# ───────────── estilos ─────────────
def mesh(c, sun=False):
    out = np.ones((H, W, 3), np.float32) * c.bg
    for color, (cx, cy, r), k in ((c.a1, (0.18, 0.25, 0.55 * H), 0.34), (c.a2, (0.84, 0.78, 0.62 * H), 0.30),
                                   (c.a3, (0.62, 0.04, 0.36 * H), 0.16), (c.a2, (0.08, 0.92, 0.30 * H), 0.12)):
        out = out + color * (blob(cx, cy, r) * k)[..., None]      # aditivo: mantém as cores vivas onde se encontram
    return out


def aurora(c, sun=False):
    rng = np.random.default_rng(seed_of(c.name))
    out = vgrad(c.bg * 0.86, mix(c.bg, c.v2, 0.10), 0.1, 1.0)
    x = XX / W
    mid = mix(c.v1, c.v2, 0.5)
    ribbons = [(0.26, 0.065, 1.00, 0.0, 0.085, c.v1, c.v2, 0.70), (0.38, 0.055, 0.72, 2.1, 0.070, c.v2, mid, 0.55),
               (0.50, 0.045, 1.25, 4.0, 0.060, mid, c.v1, 0.42), (0.60, 0.030, 0.85, 1.0, 0.045, c.v1, c.v2, 0.26)]
    for y0, amp, lam, ph, w, ca, cb, k in ribbons:
        curve = H * y0 + amp * H * (np.sin(2 * np.pi * x / lam + ph) + 0.5 * np.sin(2 * np.pi * x / (lam * 0.43) + ph * 2))
        d = (YY - curve) / (w * H)
        band = np.exp(-d * d) * np.where(d < 0, 1.0, np.exp(-d * 0.9))             # borda de cima nítida, de baixo esfumada
        rays = (0.72 + 0.28 * smooth_noise_1d(rng, W, 70))[None, :]                 # cortinas verticais suaves
        col = mix(ca, cb, x[..., None])
        out = out + (col - c.bg * 0.5) * (band * rays * k)[..., None] * 0.9
    return blur(np.clip(out, 0, 255), 9)


def stars(c, sun=False):
    rng = np.random.default_rng(seed_of(c.name))
    out = vgrad(c.bg * 0.72, mix(c.bg, c.a1, 0.16), 0.30, 1.0)
    line = H * (0.12 + 0.62 * XX / W)                                         # via-láctea na diagonal
    cloud = blur(np.repeat(rng.random((H // 8, W // 8, 1)).astype(np.float32) * 255, 3, axis=2), 1)
    cloud = np.asarray(Image.fromarray(cloud.astype(np.uint8)).resize((W, H), Image.BICUBIC).filter(ImageFilter.GaussianBlur(30)), np.float32)[..., 0] / 255
    out = toward(out, mix(c.a2, c.a1, 0.4), np.exp(-(((YY - line) / (0.17 * H)) ** 2)) * (0.35 + 0.9 * cloud), 0.22)
    layer = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(layer)
    for _ in range(1500):
        b = rng.random() ** 3
        x, y = rng.random() * W, rng.random() ** 0.9 * H
        tint = mix(c.fg, c.a2, rng.random() * 0.55)
        r = 0.5 + b * 1.5
        d.ellipse([x - r, y - r, x + r, y + r], fill=tuple(int(v) for v in np.clip(tint * (0.25 + 0.75 * b), 0, 255)))
        if b > 0.93:                                                         # só as mais brilhantes ganham cruz
            L = 4 + 9 * b
            col = tuple(int(v) for v in tint * 0.55)
            d.line([x - L, y, x + L, y], fill=col, width=1)
            d.line([x, y - L, x, y + L], fill=col, width=1)
    s = np.asarray(layer, np.float32)
    out = np.clip(out + s + blur(s, 3) * 1.1, 0, 255)
    bokeh = np.zeros((H, W, 3), np.float32)
    for i in range(7):
        cx, cy, r = rng.random(), 0.45 + rng.random() * 0.5, 40 + rng.random() * 90
        bokeh = toward(bokeh, c.a1 if i % 2 else c.a2, blob(cx, cy, r) ** 6, 0.5)
    return np.clip(out + blur(bokeh, 14) * 0.22, 0, 255)


def grid(c, sun=False):
    hz = int(H * 0.60)
    sky = vgrad(c.bg * 0.82, mix(c.bg, c.a1, 0.34), 0.05, hz / H)
    floor = vgrad(mix(c.bg, c.a1, 0.10), c.bg * 0.70, hz / H, 1.0)
    out = np.where((YY < hz)[..., None], sky, floor)
    out = toward(out, c.a1, np.exp(-(((YY - hz) / (0.03 * H)) ** 2)), 0.55)   # brilho do horizonte
    out = toward(out, c.a2, np.exp(-(((YY - hz) / (0.012 * H)) ** 2)), 0.45)
    if sun:
        cx, cy, r = W / 2, hz - 0.045 * H, 0.215 * H
        disk = (np.hypot(XX - cx, YY - cy) < r) & (YY < hz)
        t = np.clip((YY - (cy - r)) / (2 * r), 0, 1)[..., None]
        sun_col = mix(c.yellow, c.a1, np.clip(t * 1.15, 0, 1))
        u = np.clip((YY - cy) / r, 0, 1)
        gap = 0.12 + 0.50 * u
        stripes = ((YY - cy + 0.01 * H) / (0.055 * H)) % 1.0 < gap
        mask = (disk & ~((YY > cy) & stripes)).astype(np.float32)
        glow = blur(np.repeat(mask[..., None] * 255, 3, axis=2), 40)[..., 0] / 255
        out = toward(out, c.a1, glow, 0.38)
        out = mix(out, sun_col, (mask * 0.96)[..., None])
    lines = Image.new("L", (W, H))
    d = ImageDraw.Draw(lines)
    for i in range(-26, 27):
        d.line([W / 2 + i * W * 0.0045, hz, W / 2 + i * W * 0.085, H], fill=255, width=2)
    for k in range(1, 16):
        y = hz + (H - hz) * (k / 15) ** 2.3
        d.line([0, y, W, y], fill=255, width=2)
    lm = np.asarray(lines, np.float32) / 255
    depth = np.clip((YY - hz) / (H - hz), 0, 1) ** 0.7
    lm = np.where(YY > hz, lm * (0.18 + 0.82 * depth), 0)
    col = mix(c.a1, c.a2, np.clip((YY - hz) / (H - hz), 0, 1)[..., None] * 0.7)
    lit = col * lm[..., None]
    return np.clip(out + lit * 0.95 + blur(lit, 3) * 1.2, 0, 255)


def rain(c, sun=False):
    rng = np.random.default_rng(seed_of(c.name))
    out = vgrad(c.bg * 0.85, c.bg, 0.0, 1.0)
    font_path = subprocess.run(["fc-match", "-f", "%{file}", "JetBrains Mono:style=Bold"], capture_output=True, text=True).stdout
    font = ImageFont.truetype(font_path, 17)
    cw, lh = 21, 24
    chars = "0123456789ABCDEF<>/\\|=+*#$%&"
    layer = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(layer)
    for col in range(W // cw + 1):
        x, n = col * cw + 2, int(rng.integers(8, 36))
        head = int(rng.integers(-4, H // lh + 6))
        for j in range(n):
            y = (head - j) * lh
            if not -lh < y < H:
                continue
            t = j / n
            color = c.fg if j == 0 else mix(c.a1, c.bg, 0.15 + 0.85 * t) * (1 - 0.65 * t)
            d.text((x, y), chars[int(rng.integers(len(chars)))], font=font, fill=tuple(int(v) for v in np.clip(color, 0, 255)))
    s = np.asarray(layer, np.float32)
    return np.clip(out + s * 0.85 + blur(s, 5) * 1.3, 0, 255)


EFFECT = {"mesh": mesh, "aurora": aurora, "stars": stars, "grid": grid, "rain": rain}


# ───────────── composição ─────────────
def art_duotone(c):
    """A arte macchiato.png em duotone com as cores do tema (fundo -> acento -> texto), com o fundo dela = fundo do tema."""
    g = np.asarray(Image.open(ART).convert("L").resize((W, H), Image.LANCZOS), np.float32) / 255
    g = np.clip((g - 0.1221) / (1 - 0.1221), 0, 1)[..., None]
    out = np.where(g < 0.5, mix(c.bg, c.a1, g / 0.5), mix(c.a1, c.fg, (g - 0.5) / 0.5))
    return blur(out, 1.6)


def save(a, path, quality):
    to_img(a).save(path, quality=quality, optimize=True, progressive=True)


def build(name):
    c = Colors(name)
    style = style_of(name)
    seed = seed_of(name)
    # desktop: efeito completo
    wall = EFFECT[style](c, sun=name in SUN)
    save(grain(vignette(wall), 1.1, seed), OUT_WALL / f"{name}.jpg", 86)
    # terminal: efeito discreto (sem sol) por baixo + a arte; o que o véu do WezTerm esconde não importa
    term = mix(c.bg, EFFECT[style](c, sun=False), TERM_STRENGTH)
    term = np.maximum(vignette(term, 0.30), art_duotone(c))
    save(grain(term, 0.7, seed + 1), OUT_TERM / f"{name}.jpg", 88)
    return style


def main(argv):
    OUT_WALL.mkdir(parents=True, exist_ok=True)
    OUT_TERM.mkdir(parents=True, exist_ok=True)
    if not THEMES_DIR.is_dir():
        sys.exit(f"sem {THEMES_DIR}: rode `theme sync` antes")
    names = argv or sorted(p.stem for p in THEMES_DIR.glob("*.lua") if p.stem != "index")
    for n in names:
        print(f"{n:<18} {build(n)}", flush=True)


if __name__ == "__main__":
    main(sys.argv[1:])
