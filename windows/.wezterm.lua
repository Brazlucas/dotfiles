local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Tema cyberpunk liga/desliga: estado em ~/.cyber_state ("on"/"off").
-- Alterne com Ctrl+Alt+G (aqui), prefixo+T (tmux) ou <leader>uz (nvim).
-- O WezTerm recarrega sozinho quando o arquivo muda.
local state_file = wezterm.home_dir .. '/.cyber_state'
local function cyber_on()
  local f = io.open(state_file, 'r')
  if not f then return true end
  local v = f:read('*l')
  f:close()
  return v ~= 'off'
end
local CYBER = cyber_on()
wezterm.add_to_config_reload_watch_list(state_file)

-- Shell: abre o WSL (distro padrão) direto no home
config.default_prog = { 'wsl.exe', '--cd', '~' }

-- Tema Darcula (JetBrains)
config.color_schemes = {
  ['Cyberpunk'] = {
    foreground = '#d3dcea',
    background = '#080b10',
    cursor_bg = '#ff2a6d',
    cursor_fg = '#080b10',
    cursor_border = '#ff2a6d',
    selection_fg = '#ffffff',
    selection_bg = '#12404a',
    scrollbar_thumb = '#1f2a37',
    split = '#ff2a6d',
    ansi = {
      '#0d1117', '#ff2a6d', '#00ffa3', '#fcee0a',
      '#3d8bff', '#b45cff', '#05f2ff', '#d3dcea',
    },
    brights = {
      '#44505f', '#ff5c93', '#5dffc3', '#fff75e',
      '#74adff', '#dc82ff', '#6ffaff', '#ffffff',
    },
    tab_bar = {
      background = '#06080c',
      active_tab = { bg_color = '#080b10', fg_color = '#05f2ff', intensity = 'Bold' },
      inactive_tab = { bg_color = '#06080c', fg_color = '#5c6b80' },
      inactive_tab_hover = { bg_color = '#0d1117', fg_color = '#ff2a6d' },
      new_tab = { bg_color = '#06080c', fg_color = '#5c6b80' },
      new_tab_hover = { bg_color = '#0d1117', fg_color = '#ff2a6d' },
    },
  },
  ['Darcula'] = {
    foreground = '#a9b7c6',
    background = '#2b2b2b',
    cursor_bg = '#bbbbbb',
    cursor_fg = '#2b2b2b',
    cursor_border = '#bbbbbb',
    selection_fg = '#a9b7c6',
    selection_bg = '#214283',
    scrollbar_thumb = '#555555',
    split = '#555555',
    ansi = {
      '#2b2b2b', '#cc666e', '#6a8759', '#bbb529',
      '#6897bb', '#9876aa', '#629755', '#a9b7c6',
    },
    brights = {
      '#555555', '#ff6b68', '#a5c261', '#ffc66d',
      '#6d9cbe', '#b389c5', '#6eb26e', '#ffffff',
    },
    tab_bar = {
      background = '#3c3f41',
      active_tab = { bg_color = '#2b2b2b', fg_color = '#a9b7c6' },
      inactive_tab = { bg_color = '#3c3f41', fg_color = '#808080' },
      inactive_tab_hover = { bg_color = '#4e5254', fg_color = '#a9b7c6' },
      new_tab = { bg_color = '#3c3f41', fg_color = '#808080' },
      new_tab_hover = { bg_color = '#4e5254', fg_color = '#a9b7c6' },
    },
  },
}

-- Alterna entre temas com Ctrl+Alt+T (Ctrl+Alt+Shift+T volta ao anterior)
-- O tema escolhido fica salvo em ~/.wezterm_theme e é restaurado ao reabrir
local themes = {
  'Cyberpunk',
  'Darcula',
  'Tokyo Night',
  'Catppuccin Mocha',
  'Dracula (Official)',
  'Gruvbox Dark (Gogh)',
  'Catppuccin Macchiato',
  'Catppuccin Frappe',
  'Tokyo Night Storm',
  'Nord (Gogh)',
  'One Dark (Gogh)',
  'Solarized Dark (Gogh)',
  'Kanagawa (Gogh)',
  'Monokai Pro (Gogh)',
  'Material (Gogh)',
  'Ayu Dark (Gogh)',
  'Catppuccin Latte',
  'Solarized Light (Gogh)',
  'Gruvbox Light (Gogh)',
  'One Light (Gogh)',
}

local theme_file = wezterm.home_dir .. '/.wezterm_theme'

local function load_theme()
  local f = io.open(theme_file, 'r')
  if not f then return nil end
  local name = f:read('*l')
  f:close()
  return name
end

local function save_theme(name)
  local f = io.open(theme_file, 'w')
  if f then
    f:write(name)
    f:close()
  end
end

-- Cores da moldura da janela / barra de abas acompanham o tema ativo
local function scheme_def(name)
  return config.color_schemes[name] or wezterm.color.get_builtin_schemes()[name]
end

local function frame_for(name)
  local sc = scheme_def(name) or {}
  local bar = (sc.tab_bar and sc.tab_bar.background) or sc.background or '#1b1b1b'
  local fg = (sc.tab_bar and sc.tab_bar.inactive_tab and sc.tab_bar.inactive_tab.fg_color)
    or sc.foreground or '#808080'
  local accent = (sc.ansi and sc.ansi[7]) or fg
  local frame = {
    font = wezterm.font_with_fallback { 'JetBrains Mono', 'Cascadia Code' },
    font_size = 10.5,
    active_titlebar_bg = bar,
    inactive_titlebar_bg = bar,
    active_titlebar_fg = fg,
    inactive_titlebar_fg = fg,
    inactive_titlebar_border_bottom = bar,
    active_titlebar_border_bottom = bar,
    button_fg = fg,
    button_bg = bar,
    button_hover_fg = accent,
    button_hover_bg = (sc.background or bar),
  }
  if name == 'Cyberpunk' then
    -- contorno neon fino
    frame.border_left_width = '1px'
    frame.border_right_width = '1px'
    frame.border_bottom_height = '1px'
    frame.border_top_height = '1px'
    frame.border_left_color = '#ff2a6d'
    frame.border_right_color = '#05f2ff'
    frame.border_bottom_color = '#ff2a6d'
    frame.border_top_color = '#05f2ff'
  end
  return frame
end

local saved_theme = load_theme()
local valid = false
for _, n in ipairs(themes) do if n == saved_theme then valid = true end end
config.color_scheme = CYBER and (valid and saved_theme or 'Cyberpunk') or 'Darcula'
if CYBER then config.window_frame = frame_for(config.color_scheme) end

local function cycle_theme(step)
  return wezterm.action_callback(function(window)
    local overrides = window:get_config_overrides() or {}
    local current = overrides.color_scheme or config.color_scheme
    local idx = 1
    for i, name in ipairs(themes) do
      if name == current then idx = i break end
    end
    idx = (idx - 1 + step) % #themes + 1
    overrides.color_scheme = themes[idx]
    if CYBER then overrides.window_frame = frame_for(themes[idx]) end
    window:set_config_overrides(overrides)
    if CYBER then save_theme(themes[idx]) end
    window:toast_notification('WezTerm', 'Tema: ' .. themes[idx], nil, 1500)
  end)
end

-- Liga/desliga o tema em tudo (WezTerm, tmux, nvim) via script no WSL
local function toggle_cyber()
  return wezterm.action_callback(function(window)
    wezterm.background_child_process {
      'wsl.exe', '-e', '/home/luqueta/.config/cyber/toggle.sh', 'toggle',
    }
    window:toast_notification('WezTerm', CYBER and 'Cyberpunk: desligando…' or 'Cyberpunk: ligando…', nil, 1500)
  end)
end

config.keys = {
  { key = 't', mods = 'CTRL|ALT', action = cycle_theme(1) },
  { key = 'T', mods = 'CTRL|ALT|SHIFT', action = cycle_theme(-1) },
  { key = 'g', mods = 'CTRL|ALT', action = toggle_cyber() },
}

-- Fonte
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Cascadia Code',
  'Consolas',
}
config.font_size = CYBER and 11.5 or 11.0
if CYBER then
  config.line_height = 1.1
  config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
end

-- Janela
config.initial_cols = 130
config.initial_rows = 35
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'

if not CYBER then
  -- ───── Visual original (tema desligado) ─────
  config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
  config.win32_system_backdrop = 'Disable'
  config.window_background_opacity = 1.0
  config.text_background_opacity = 1.0
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = true

  -- ao desligar, descarta overrides de tema das janelas abertas
  wezterm.on('window-config-reloaded', function(window)
    local o = window:get_config_overrides()
    if o and next(o) ~= nil then window:set_config_overrides({}) end
  end)

  return config
end

-- ───── Visual cyberpunk ─────
-- padding 0: o tmux encosta nas bordas da janela
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.use_resize_increments = true

-- Efeito de vidro (Windows 11): Acrylic = transparência com blur
config.win32_system_backdrop = 'Acrylic'
config.window_background_opacity = 0.80
config.text_background_opacity = 1.0

-- Painéis inativos levemente escurecidos
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.65 }

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 700
config.cursor_blink_ease_in = 'EaseOut'
config.cursor_blink_ease_out = 'EaseOut'
config.animation_fps = 60
config.max_fps = 120

-- Barra de abas integrada à janela (com botão X em cada aba e botões da janela)
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.integrated_title_button_style = 'Windows'
config.integrated_title_button_alignment = 'Right'
config.integrated_title_button_color = 'Auto'
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 64
config.show_new_tab_button_in_tab_bar = true

local icons = {
  zsh = '', bash = '', fish = '', nvim = '', vim = '', node = '',
  python = '', python3 = '', ssh = '󰣀', docker = '', git = '', lazygit = '',
  tmux = '', htop = '', btop = '', php = '', ruby = '', go = '', cargo = '',
  wsl = '', ['wsl.exe'] = '',
}

local TAB_MIN = 26 -- largura mínima (em caracteres) do título de cada aba

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local pane = tab.active_pane
  local proc = (pane.foreground_process_name or ''):match('([^/\\]+)$') or ''
  proc = proc:gsub('%.exe$', '')
  local icon = icons[proc] or ''
  local cwd = pane.current_working_dir
  local dir = cwd and cwd.file_path and cwd.file_path:match('([^/]+)/?$') or nil
  local title = tab.tab_title
  if not title or #title == 0 then title = dir or pane.title end
  title = wezterm.truncate_right(title, math.max(TAB_MIN, max_width - 10))
  title = wezterm.pad_right(title, TAB_MIN)
  local idx = tab.tab_index + 1
  if tab.is_active then
    return {
      { Foreground = { Color = '#ff2a6d' } },
      { Text = ' ▍' },
      { Foreground = { Color = '#05f2ff' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = icon .. ' ' .. idx .. ' ' .. title .. ' ' },
    }
  end
  return ' ' .. icon .. ' ' .. idx .. ' ' .. title .. ' '
end)

-- Detalhes extras
config.bold_brightens_ansi_colors = 'BrightAndBold'
config.visual_bell = { fade_in_duration_ms = 60, fade_out_duration_ms = 140, target = 'CursorColor' }
config.colors = {
  visual_bell = '#ff2a6d',
  compose_cursor = '#fcee0a',
  copy_mode_active_highlight_bg = { Color = '#ff2a6d' },
  copy_mode_active_highlight_fg = { Color = '#080b10' },
  copy_mode_inactive_highlight_bg = { Color = '#12404a' },
  copy_mode_inactive_highlight_fg = { Color = '#ffffff' },
  quick_select_label_bg = { Color = '#ff2a6d' },
  quick_select_label_fg = { Color = '#080b10' },
  quick_select_match_bg = { Color = '#05f2ff' },
  quick_select_match_fg = { Color = '#080b10' },
}
config.command_palette_bg_color = '#0d1117'
config.command_palette_fg_color = '#05f2ff'
config.command_palette_rows = 12
config.char_select_bg_color = '#0d1117'
config.char_select_fg_color = '#05f2ff'

-- Barra de status à direita: workspace + hora (atualiza a cada 2s, leve)
config.status_update_interval = 2000

local last_status = {}
wezterm.on('update-status', function(window, pane)
  local id = window:window_id()
  local name = window:effective_config().color_scheme
  local sc = config.color_schemes[name] or wezterm.color.get_builtin_schemes()[name] or {}
  local accent = (sc.ansi and sc.ansi[7]) or '#05f2ff'
  local hot = (sc.ansi and sc.ansi[2]) or '#ff2a6d'
  local dim = (sc.ansi and sc.ansi[5]) or '#5a6199'
  local text = wezterm.format {
    { Foreground = { Color = dim } },
    { Text = '󰒋 ' .. window:active_workspace() .. '  ' },
    { Foreground = { Color = hot } },
    { Text = '│ ' },
    { Foreground = { Color = accent } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = '󰥔 ' .. wezterm.strftime('%H:%M') .. '  ' },
  }
  if last_status[id] ~= text then
    last_status[id] = text
    window:set_right_status(text)
  end
end)

return config
