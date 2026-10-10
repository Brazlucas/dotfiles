# Instalação dos extras que vivem fora do ~/.config/theme (bat, btop, pgcli, git).
import re
import shutil
import subprocess


def _sub_line(path, pattern, repl):
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    new, n = re.subn(pattern, repl, text, flags=re.M)
    if n and new != text:
        path.write_text(new, encoding="utf-8")


def install(m, name, src):
    p = m.load(name)
    f = p["features"]
    colorize = f.get("colorize", False)
    cfg = m.HOME / ".config"

    # btop: tema gerado (ou volta ao original do clássico)
    btop = cfg / "btop" / "btop.conf"
    if colorize:
        m.write(cfg / "btop" / "themes" / "theme.theme", (src / "btop.theme").read_text(encoding="utf-8"))
        _sub_line(btop, r'^color_theme = .*$', 'color_theme = "theme"')
        _sub_line(btop, r'^truecolor = .*$', 'truecolor = True')
    else:
        _sub_line(btop, r'^color_theme = .*$', 'color_theme = "/usr/share/btop/themes/adapta.theme"')
        _sub_line(btop, r'^truecolor = .*$', 'truecolor = False')

    # pgcli: estilo pygments mais próximo
    _sub_line(cfg / "pgcli" / "config", r'^syntax_style = .*$', f"syntax_style = {f.get('pgcli_style', 'default')}")

    # bat: tema .tmTheme + cache
    if colorize:
        m.write(cfg / "bat" / "themes" / "theme.tmTheme", (src / "bat.tmTheme").read_text(encoding="utf-8"))
        if shutil.which("bat"):
            # em segundo plano: só afeta o próximo uso do bat e custava ~400 ms na troca de tema
            subprocess.Popen(["bat", "cache", "--build"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                             stdin=subprocess.DEVNULL, start_new_session=True)

    # git: inclui o arquivo do delta (include de arquivo ausente é ignorado)
    gitconfig = m.HOME / ".gitconfig"
    inc = "[include]\n\tpath = ~/.config/theme/build/current/delta.gitconfig\n"
    text = gitconfig.read_text(encoding="utf-8") if gitconfig.exists() else ""
    if "build/current/delta.gitconfig" not in text:
        gitconfig.write_text(text.rstrip("\n") + "\n" + inc, encoding="utf-8")

    # Claude Code: tema customizado (~/.claude/themes/<nome>.json) + "theme" no settings.json
    settings = m.HOME / ".claude" / "settings.json"
    if settings.exists():
        want = f"custom:{name}" if f.get("claude") == "custom" else (f.get("claude") or "dark-ansi")
        if f.get("claude") == "custom":
            m.write(m.HOME / ".claude" / "themes" / f"{name}.json",
                    (src / "claude-theme.json").read_text(encoding="utf-8"))
        bak = settings.with_name("settings.json.bak-theme")
        if not bak.exists():
            bak.write_bytes(settings.read_bytes())
        _sub_line(settings, r'^(\s*)"theme"\s*:\s*"[^"]*"', r'\1"theme": "%s"' % want)
