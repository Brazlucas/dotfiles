local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Shell: abre o WSL (distro padrão) direto no home
config.default_prog = { 'wsl.exe', '--cd', '~' }

-- ───── Tema ─────
-- Tudo (cores, vidro, abas, fonte…) vem do sistema de temas global: `theme set <nome>` no WSL
-- gera C:\Users\<user>\.wezterm_theme.lua a partir de ~/.config/theme/palettes/<nome>.toml.
-- Atalhos: Ctrl+Alt+G liga/desliga (cyberpunk ↔ clássico); Ctrl+Alt+T / Ctrl+Alt+Shift+T = seletor Alt+Tab de temas.
local theme_file = wezterm.home_dir .. '/.wezterm_theme.lua'
wezterm.add_to_config_reload_watch_list(theme_file) -- recarrega sozinho quando o tema muda

local ok, T = pcall(dofile, theme_file)
if not ok or type(T) ~= 'table' then
  wezterm.log_error('wezterm: tema indisponível (' .. tostring(T) .. '); usando padrão')
  T = {
    name = 'fallback', scheme = {}, frame = {}, extras = {}, palette_ui = {},
    features = { glass = false, opacity = 1.0, fancy_tabs = false, padding = 8,
                 font_size = 11.0, line_height = 1.0, cursor = 'SteadyBlock' },
  }
end
local F = T.features

config.color_schemes = { [T.name] = T.scheme }
if next(T.scheme) ~= nil then config.color_scheme = T.name end

local function theme_cmd(arg)
  return wezterm.action_callback(function(window)
    wezterm.background_child_process { 'wsl.exe', '-e', '/home/luqueta/.local/bin/theme', arg }
  end)
end

config.keys = {
  { key = 'g', mods = 'CTRL|ALT', action = theme_cmd('toggle') },
}

-- Seletor estilo Alt+Tab (Ctrl+Alt+T / Ctrl+Alt+Shift+T): prévia ao vivo, confirma ao soltar Ctrl/Alt.
-- Veja .wezterm_switcher.lua (dados em .wezterm_themes/, gerados por `theme sync`).
local SW = nil            -- instância do seletor (para aba/relógio acompanharem a prévia)
local refresh_status      -- definida mais abaixo (só existe no modo com vidro)
local sw_ok, sw = pcall(dofile, wezterm.home_dir .. '/.wezterm_switcher.lua')
if sw_ok and type(sw) == 'table' then
  local setup_ok, err = pcall(function()
    SW = sw.setup(config, wezterm, {
    dir = wezterm.home_dir .. '/.wezterm_themes',
    current = T.name,
    theme_cmd = { 'wsl.exe', '-e', '/home/luqueta/.local/bin/theme' },
    frame_font = wezterm.font_with_fallback { 'JetBrains Mono', 'Cascadia Code' },
    on_preview = function(window) if refresh_status then refresh_status(window) end end,
    })
  end)
  if not setup_ok then wezterm.log_error('switcher: ' .. tostring(err)) end
else
  wezterm.log_error('switcher: módulo indisponível (' .. tostring(sw) .. ')')
end

-- Fonte
config.font = wezterm.font_with_fallback { 'JetBrains Mono', 'Cascadia Code', 'Consolas' }
config.font_size = F.font_size
if F.line_height and F.line_height ~= 1.0 then
  config.line_height = F.line_height
  config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
end

-- Janela
config.initial_cols = 130
config.initial_rows = 35
config.scrollback_lines = 10000
config.audible_bell = 'Disabled'
config.window_padding = { left = F.padding, right = F.padding, top = F.padding, bottom = F.padding }
config.default_cursor_style = F.cursor

if not F.glass then
  -- ───── Sem vidro (ex.: clássico = visual original) ─────
  config.window_padding = { left = 8, right = 8, top = 6, bottom = 6 }
  config.win32_system_backdrop = 'Disable'
  config.window_background_opacity = 1.0
  config.text_background_opacity = 1.0
  config.use_fancy_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = true
  return config
end

-- ───── Vidro ─────
-- Acrylic = transparência com blur; o padding 0 deixa o tmux encostar nas bordas
config.win32_system_backdrop = 'Acrylic'
config.window_background_opacity = F.opacity
config.text_background_opacity = 1.0
config.use_resize_increments = true -- redimensiona em múltiplos exatos de célula (sem sobra embaixo)
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.65 }

if F.cursor:find('^Blinking') then
  config.cursor_blink_rate = 700
  config.cursor_blink_ease_in = 'EaseOut'
  config.cursor_blink_ease_out = 'EaseOut'
else
  config.cursor_blink_rate = 0
end
config.animation_fps = 60
config.max_fps = 120

if F.fancy_tabs then
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

  local frame = {
    font = wezterm.font_with_fallback { 'JetBrains Mono', 'Cascadia Code' },
    font_size = 10.5,
  }
  for k, v in pairs(T.frame) do frame[k] = v end
  config.window_frame = frame
end

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
  local PT = SW and SW.preview_data and SW.preview_data() or nil   -- tema em prévia (seletor), se houver
  local a1, a2 = (PT and PT.accent1) or T.accent1, (PT and PT.accent2) or T.accent2
  if tab.is_active then
    return {
      { Foreground = { Color = a1 } },
      { Text = ' ▍' },
      { Foreground = { Color = a2 } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = icon .. ' ' .. idx .. ' ' .. title .. ' ' },
    }
  end
  return ' ' .. icon .. ' ' .. idx .. ' ' .. title .. ' '
end)

-- Detalhes extras (busca, modo cópia, paleta de comandos) com as cores do tema
config.visual_bell = { fade_in_duration_ms = 60, fade_out_duration_ms = 140, target = 'CursorColor' }
config.bold_brightens_ansi_colors = 'BrightAndBold'
config.colors = T.extras
config.command_palette_bg_color = T.palette_ui.bg_alt
config.command_palette_fg_color = T.palette_ui.accent2
config.command_palette_rows = 12
config.char_select_bg_color = T.palette_ui.bg_alt
config.char_select_fg_color = T.palette_ui.accent2

-- Barra de status à direita: workspace + hora (atualiza a cada 2s; só redesenha se mudar)
config.status_update_interval = 2000

local last_status = {}
-- calcula e aplica o status à direita; usa as cores do tema em prévia (seletor) quando houver
refresh_status = function(window)
  local id = window:window_id()
  local PT = SW and SW.preview_data and SW.preview_data() or nil
  local a = ((PT and PT.scheme) or T.scheme).ansi or {}
  local a1 = (PT and PT.accent1) or T.accent1
  local a2 = (PT and PT.accent2) or T.accent2
  local text = wezterm.format {
    { Foreground = { Color = a[5] or a2 } },
    { Text = '󰒋 ' .. window:active_workspace() .. '  ' },
    { Foreground = { Color = a[2] or a1 } },
    { Text = '│ ' },
    { Foreground = { Color = a[7] or a2 } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = '󰥔 ' .. wezterm.strftime('%H:%M') .. '  ' },
  }
  if last_status[id] ~= text then
    last_status[id] = text
    window:set_right_status(text)
  end
end

wezterm.on('update-status', function(window, pane) refresh_status(window) end)

return config
