# Geradores extras ("colorir tudo"): LS_COLORS/eza, fzf, ripgrep, zsh plugins, bat, delta, lazygit, lazydocker, btop, htop, wttr.
# Carregado por bin/theme (register(m) recebe o módulo principal).
import shutil


def register(m):
    def sgr(hexc, bold=False):
        return ("1;" if bold else "") + "38;2;" + m.hex_rgb(hexc)

    def gen_env(p, v):
        f = p["features"]
        c = p["colors"]
        lines = ["# gerado por `theme` — carregado pelo ~/.zshrc (exec zsh para aplicar)"]
        if not f.get("colorize", False):
            lines.append("# tema sem colorização extra (visual original): nada a exportar")
            m.write(m.OUT / "env.zsh", "\n".join(lines) + "\n")
            return
        ls = {
            "rs": "0", "di": sgr(c["blue"], True), "ln": sgr(c["accent2"]), "mh": "0",
            "pi": sgr(c["yellow"]), "so": sgr(c["magenta"]), "do": sgr(c["magenta"]),
            "bd": sgr(c["yellow"], True), "cd": sgr(c["yellow"]), "or": sgr(c["red"], True),
            "mi": sgr(c["red"]), "su": "1;" + sgr(c["bg"]) + ";48;2;" + m.hex_rgb(c["red"]),
            "sg": "1;" + sgr(c["bg"]) + ";48;2;" + m.hex_rgb(c["yellow"]),
            "tw": sgr(c["blue"], True), "ow": sgr(c["blue"], True), "st": sgr(c["blue"], True),
            "ex": sgr(c["green"], True),
        }
        groups = {
            c["accent1"]: "zip tar gz tgz xz bz2 7z rar zst deb rpm jar war",
            c["magenta"]: "png jpg jpeg gif svg webp bmp ico tiff avif",
            c["accent2"]: "mp3 flac wav ogg m4a mp4 mkv mov avi webm",
            c["yellow"]: "md txt pdf rst log csv json yaml yml toml ini conf env",
            c["green"]: "py js ts tsx jsx php rb go rs c h cpp java lua sh zsh vue css html sql",
        }
        parts = [f"{k}={x}" for k, x in ls.items()]
        for col, exts in groups.items():
            parts += [f"*.{e}={sgr(col)}" for e in exts.split()]
        lscolors = ":".join(parts)
        eza = ":".join([
            f"da={sgr(c['dim'])}", f"sn={sgr(c['green'])}", f"sb={sgr(c['green'])}",
            f"uu={sgr(c['accent2'])}", f"un={sgr(c['accent2'])}", f"gu={sgr(c['magenta'])}", f"gn={sgr(c['magenta'])}",
            f"ur={sgr(c['yellow'])}", f"uw={sgr(c['accent1'])}", f"ux={sgr(c['green'])}", f"ue={sgr(c['green'])}",
            f"gr={sgr(c['yellow'])}", f"gw={sgr(c['accent1'])}", f"gx={sgr(c['green'])}",
            f"tr={sgr(c['yellow'])}", f"tw={sgr(c['accent1'])}", f"tx={sgr(c['green'])}",
            f"hd=4;{sgr(c['fg'])}", f"lp={sgr(c['accent2'])}", f"cc={sgr(c['accent1'])}",
            f"gm={sgr(c['blue'])}", f"ga={sgr(c['green'])}", f"gd={sgr(c['red'])}", f"gv={sgr(c['magenta'])}",
        ])
        fzf = (
            "--height=40% --layout=reverse --border=rounded --info=inline "
            f"--color=bg:-1,bg+:{c['sel']},fg:{c['fg']},fg+:{c['white']},hl:{c['accent1']},hl+:{c['accent1']},"
            f"info:{c['accent2']},prompt:{c['accent1']},pointer:{c['accent1']},marker:{c['green']},"
            f"spinner:{c['accent2']},header:{c['dim']},border:{c['line']},gutter:-1,query:{c['white']}"
        )
        hs = {
            "command": f"fg={c['accent2']}", "builtin": f"fg={c['accent2']},bold", "alias": f"fg={c['accent2']}",
            "function": f"fg={c['accent2']}", "precommand": f"fg={c['accent1']},italic",
            "reserved-word": f"fg={c['accent1']}", "arg0": f"fg={c['accent2']}",
            "path": f"fg={c['blue']},underline", "unknown-token": f"fg={c['red']}",
            "single-hyphen-option": f"fg={c['magenta']}", "double-hyphen-option": f"fg={c['magenta']}",
            "comment": f"fg={c['dim']}", "single-quoted-argument": f"fg={c['green']}",
            "double-quoted-argument": f"fg={c['green']}", "dollar-double-quoted-argument": f"fg={c['yellow']}",
            "globbing": f"fg={c['yellow']}", "redirection": f"fg={c['accent1']}",
            "commandseparator": f"fg={c['accent1']}", "history-expansion": f"fg={c['yellow']}",
            "back-quoted-argument": f"fg={c['magenta']}",
        }
        lines += [
            f"export LS_COLORS='{lscolors}'",
            f"export EZA_COLORS='{eza}'",
            f"export FZF_DEFAULT_OPTS=\"{fzf}\"",
            "export BAT_THEME=theme",
            "export LG_CONFIG_FILE=\"$HOME/.config/lazygit/config.yml,$HOME/.config/theme/build/current/lazygit.yml\"",
            "export RIPGREP_CONFIG_PATH=\"$HOME/.config/theme/build/current/ripgreprc\"",
            "zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}",
            f"ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg={c['dim']}'",
            "typeset -gA ZSH_HIGHLIGHT_STYLES",
        ]
        lines += [f"ZSH_HIGHLIGHT_STYLES[{k}]='{x}'" for k, x in hs.items()]
        lines += [
            "if (( $+commands[eza] )); then",
            "  alias ls='eza --icons --group-directories-first'",
            "  alias ll='eza -l --icons --git --group-directories-first'",
            "  alias la='eza -la --icons --git --group-directories-first'",
            "  alias tree='eza --tree --icons'",
            "fi",
            "(( $+commands[bat] )) && alias bcat='bat --paging=never'",
        ]
        m.write(m.OUT / "env.zsh", "\n".join(lines) + "\n")

    def gen_files(p, v):
        f = p["features"]
        c = p["colors"]
        T = m.ROOT / "templates"
        for tmpl, out in (("btop.theme.tmpl", "btop.theme"), ("bat.tmTheme.tmpl", "bat.tmTheme"),
                          ("lazygit.yml.tmpl", "lazygit.yml"),
                          ("lazydocker.yml.tmpl", "lazydocker.yml")):
            text = m.render((T / tmpl).read_text(encoding="utf-8"), v)
            m.write(m.OUT / out, text if f.get("colorize") else f"# {out}: tema sem colorização extra\n")
        rg = "# ripgrep — gerado por `theme`\n"
        if f.get("colorize"):
            rg += "".join(f"--colors={k}:{a}:{val}\n" for k, a, val in (
                ("path", "fg", m.hex_rgb(c["accent2"]).replace(";", ",")),
                ("line", "fg", m.hex_rgb(c["dim"]).replace(";", ",")),
                ("column", "fg", m.hex_rgb(c["dim"]).replace(";", ",")),
                ("match", "fg", m.hex_rgb(c["accent1"]).replace(";", ",")),
                ("match", "style", "bold"),
            ))
        m.write(m.OUT / "ripgreprc", rg)
        # delta (diff do git): só liga o pager se o delta estiver instalado
        d = ["# delta — gerado por `theme`"]
        if f.get("colorize") and shutil.which("delta"):
            dd = p.get("diff", {})
            d += [
                "[core]", "\tpager = delta",
                "[interactive]", "\tdiffFilter = delta --color-only",
                "[merge]", "\tconflictstyle = diff3",
                "[delta]", "\tnavigate = true", "\tline-numbers = true", "\tsyntax-theme = theme",
                f"\tplus-style = syntax \"{dd.get('add', c['bg_alt'])}\"",
                f"\tminus-style = syntax \"{dd.get('delete', c['bg_alt'])}\"",
                f"\tplus-emph-style = syntax \"{dd.get('text', c['sel'])}\"",
                f"\tminus-emph-style = syntax \"{dd.get('delete', c['bg_alt'])}\" bold",
                f"\tfile-style = bold {c['accent2']}", f"\tfile-decoration-style = {c['accent1']} ul",
                "\thunk-header-style = file line-number syntax",
                f"\thunk-header-decoration-style = {c['accent1']} box",
                f"\tline-numbers-minus-style = {c['red']}", f"\tline-numbers-plus-style = {c['green']}",
                f"\tline-numbers-zero-style = {c['dim']}",
            ]
        m.write(m.OUT / "delta.gitconfig", "\n".join(d) + "\n")

    def mix(a, b, t):
        """mistura a cor a com b (t=0 -> a, t=1 -> b)."""
        ra = [int(a.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        rb = [int(b.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        return "#%02x%02x%02x" % tuple(round(x + (y - x) * t) for x, y in zip(ra, rb))

    def gen_claude(p, v):
        """Tema customizado do Claude Code: ~/.claude/themes/<nome>.json (base dark + overrides)."""
        c = p["colors"]
        d = p.get("diff", {})
        o = {
            "claude": c["accent1"], "claudeShimmer": c["brights"][1],
            "claudeBlue_FOR_SYSTEM_SPINNER": c["accent2"], "claudeBlueShimmer_FOR_SYSTEM_SPINNER": c["brights"][6],
            "autoAccept": c["magenta"], "autoAcceptShimmer": c["brights"][5],
            "skill": c["magenta"], "bashBorder": c["accent1"],
            "permission": c["accent2"], "permissionShimmer": c["brights"][6],
            "planMode": c["green"], "ide": c["blue"],
            "promptBorder": c["dim"], "promptBorderShimmer": c["subtle"],
            "text": c["fg"], "inverseText": c["bg"],
            "inactive": c["dim"], "inactiveShimmer": c["subtle"], "subtle": c["subtle"],
            "suggestion": c["accent2"], "remember": c["blue"], "background": c["accent2"],
            "success": c["green"], "error": c["red"], "warning": c["yellow"],
            "warningShimmer": mix(c["yellow"], c["white"], 0.35), "merged": c["magenta"],
            "diffAdded": d.get("add", mix(c["green"], c["bg"], 0.8)),
            "diffRemoved": d.get("delete", mix(c["red"], c["bg"], 0.8)),
            "diffAddedDimmed": mix(d.get("add", c["bg_alt"]), c["bg"], 0.5),
            "diffRemovedDimmed": mix(d.get("delete", c["bg_alt"]), c["bg"], 0.5),
            "diffAddedWord": mix(c["green"], c["bg"], 0.55), "diffRemovedWord": mix(c["red"], c["bg"], 0.55),
            "red_FOR_SUBAGENTS_ONLY": c["red"], "blue_FOR_SUBAGENTS_ONLY": c["blue"],
            "green_FOR_SUBAGENTS_ONLY": c["green"], "yellow_FOR_SUBAGENTS_ONLY": c["yellow"],
            "purple_FOR_SUBAGENTS_ONLY": c["magenta"], "orange_FOR_SUBAGENTS_ONLY": mix(c["yellow"], c["red"], 0.5),
            "pink_FOR_SUBAGENTS_ONLY": c["accent1"], "cyan_FOR_SUBAGENTS_ONLY": c["cyan"],
            "professionalBlue": c["blue"], "chromeYellow": c["yellow"],
            "clawd_body": c["accent1"], "clawd_background": c["bg"],
            "userMessageBackground": c["bg_alt"], "userMessageBackgroundHover": mix(c["bg_alt"], c["white"], 0.06),
            "composerSidebarBackground": c["bg_deep"], "selectionBg": c["sel"],
            "bashMessageBackgroundColor": c["bg_alt"], "memoryBackgroundColor": c["bg_alt"],
            "fastMode": c["accent2"], "fastModeShimmer": c["brights"][6],
            "briefLabelYou": c["accent2"], "briefLabelClaude": c["accent1"],
        }
        import json
        data = {"name": v["label"], "base": "dark", "overrides": o}
        m.write(m.OUT / "claude-theme.json", json.dumps(data, indent=2, ensure_ascii=False) + "\n")

    def gen_wttr(p, v):
        """Script sed que remapeia as cores 256 fixas do wttr.in para índices ANSI (por matiz).
        Índices da paleta ANSI (não RGB) são repintados pelo WezTerm quando o tema muda, inclusive no texto já impresso."""
        import colorsys
        out = ["# wttr.in — gerado por `theme`; remapeia cores 256 para a paleta ANSI do terminal"]
        if p["features"].get("colorize"):
            def xterm(n):
                if n < 232:
                    n -= 16
                    return tuple((0 if x == 0 else 55 + 40 * x) for x in (n // 36, n // 6 % 6, n % 6))
                return (8 + 10 * (n - 232),) * 3

            def pick(n):
                h, s, val = colorsys.rgb_to_hsv(*(x / 255 for x in xterm(n)))
                if s < 0.2:
                    return "35" if val > 0.55 else "90"   # nuvem = accent1 (ANSI 5)
                h *= 360
                if h < 15 or h >= 340:
                    return "31"
                if h < 45:
                    return "91"
                if h < 70:
                    return "33"
                if h < 170:
                    return "32"
                if h < 200:
                    return "36"
                if h < 240:
                    return "36"   # chuva/neve = accent2 (ANSI 6)
                if h < 260:
                    return "34"
                return "35"

            for n in range(16, 256):
                out.append(f"s/\\x1b\\[38;5;{n}m/\\x1b[{pick(n)}m/g")
            out.append("1s/.*/\\x1b[1;35m&\\x1b[0m/")
        m.write(m.OUT / "wttr.sed", "\n".join(out) + "\n")

    return [gen_env, gen_files, gen_claude, gen_wttr]
