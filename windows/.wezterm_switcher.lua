-- Seletor de tema estilo Alt+Tab para o WezTerm (Ctrl+Alt+T).
--   tocar            -> próximo tema (confirma ao soltar, ~0,15 s)
--   segurar Ctrl+Alt -> cada T avança (Shift+T volta); a prévia é ao vivo e o tema só é aplicado ao SOLTAR
--   segurar o T      -> avança em ritmo controlado (STEP_MIN_INTERVAL)
--   Esc cancela (volta ao tema original) · Enter confirma
-- A prévia só recolore o WezTerm (set_config_overrides); ao confirmar roda `theme set <nome>` (tudo).
-- Dados: <home>/.wezterm_themes/index.lua e <nome>.lua, gerados por `theme sync`.
local M = {}

local DEFAULTS = {
  confirm_mode = 'release',   -- 'release' (soltar Ctrl/Alt) | 'timeout' (confirma após TIMEOUT s sem toque)
  poll_interval = 0.04,       -- s entre leituras de keyboard_modifiers
  release_grace = 0.15,       -- s após o último toque em que o "soltar" é ignorado
  step_min_interval = 0.18,   -- s mínimos entre passos (limita o auto-repeat de segurar o T)
  timeout = 0.8,              -- só para confirm_mode = 'timeout'
  safety_clear = 3.0,         -- s para limpar a prévia caso o reload do tema não chegue
  debug = false,              -- loga eventos no log do WezTerm
}

function M.setup(config, wezterm, opts)
  opts = opts or {}
  local C = {}
  for k, v in pairs(DEFAULTS) do C[k] = v end
  for k, v in pairs(opts.config or {}) do C[k] = v end

  local act = wezterm.action
  local dir = opts.dir
  local current = opts.current            -- nome do tema ativo (nil/classic = fora do carrossel)
  local theme_cmd = opts.theme_cmd        -- {'wsl.exe','-e','/home/.../theme'}
  local frame_font = opts.frame_font
  local clock = opts.clock or function()
    local t = wezterm.time.now()
    return tonumber(t:format('%s')) + (tonumber(t:format('%.3f')) or 0)
  end
  local schedule = opts.schedule or function(sec, fn) wezterm.time.call_after(sec, fn) end
  local load_file = opts.load_file or function(path) return dofile(path) end

  local function dbg(msg)
    if C.debug then wezterm.log_error('SWITCHER ' .. msg) end
  end

  -- índice dos temas (lista ordenada + último usado)
  local ok, index = pcall(load_file, dir .. '/index.lua')
  if not ok or type(index) ~= 'table' or not index.names or #index.names == 0 then
    wezterm.log_error('switcher: índice de temas indisponível (rode `theme sync`): ' .. tostring(index))
    return nil
  end
  local names = index.names
  local function position(name)
    for i, e in ipairs(names) do if e.name == name then return i end end
    return nil
  end

  local cache = {}
  local function theme_data(name)
    if cache[name] == nil then
      local ok2, T = pcall(load_file, dir .. '/' .. name .. '.lua')
      cache[name] = (ok2 and type(T) == 'table') and T or false
    end
    return cache[name] or nil
  end

  local S = { active = false, gen = 0, idx = 0, base = nil, last_event = 0, last_step = 0, pending = nil, pane = nil }

  local function banner(window)
    local n = #names
    local function at(i) return names[((i - 1) % n) + 1] end
    local sel = at(S.idx)
    local prev, nxt = at(S.idx - 1), at(S.idx + 1)
    local dim = '#808080'
    window:set_left_status(wezterm.format {
      { Foreground = { Color = dim } }, { Text = ' ◀ ' .. prev.label .. '   ' },
      { Foreground = { Color = sel.accent1 } }, { Text = '▐' },
      { Foreground = { Color = sel.accent2 } }, { Text = '██' },
      { Foreground = { Color = sel.accent1 } }, { Attribute = { Intensity = 'Bold' } },
      { Text = ' ' .. sel.label .. ' ' },
      { Attribute = { Intensity = 'Normal' } },
      { Foreground = { Color = sel.accent2 } }, { Text = '██' },
      { Foreground = { Color = sel.accent1 } }, { Text = '▌' },
      { Foreground = { Color = dim } }, { Text = '   ' .. nxt.label .. ' ▶  · ' .. S.idx .. '/' .. n .. '  ' },
    })
  end

  local function apply_preview(window, entry)
    local T = theme_data(entry.name)
    if not T then return end
    local o = window:get_config_overrides() or {}
    o.color_schemes = { [entry.name] = T.scheme }
    o.color_scheme = entry.name
    local f = {}
    if frame_font then f.font = frame_font; f.font_size = 10.5 end
    for k, v in pairs(T.frame or {}) do f[k] = v end
    o.window_frame = f
    o.colors = T.extras
    window:set_config_overrides(o)
  end

  local function clear_overrides(window)
    window:set_config_overrides({})
    window:set_left_status('')
  end

  local function pop_table(window)
    pcall(function() window:perform_action(act.PopKeyTable, S.pane or window:active_pane()) end)
  end

  local function finish(window)
    S.active = false
    S.gen = S.gen + 1
    pop_table(window)
  end

  local function cancel(window)
    if not S.active then return end
    dbg('cancelar')
    finish(window)
    clear_overrides(window)
  end

  local function commit(window)
    if not S.active then return end
    local entry = names[((S.idx - 1) % #names) + 1]
    dbg('confirmar ' .. entry.name)
    finish(window)
    if entry.name == S.base then
      clear_overrides(window)
      return
    end
    -- mantém a prévia até o reload do arquivo de tema; timeout de segurança limpa
    local cmd = {}
    for _, a in ipairs(theme_cmd) do cmd[#cmd + 1] = a end
    cmd[#cmd + 1] = 'set'
    cmd[#cmd + 1] = entry.name
    wezterm.background_child_process(cmd)
    S.pending = S.gen
    local token = S.pending
    schedule(C.safety_clear, function()
      if S.pending == token then
        S.pending = nil
        clear_overrides(window)
      end
    end)
  end

  local function mods_of(window)
    local okm, m = pcall(function() return (window:keyboard_modifiers()) end)
    if not okm or m == nil then return nil end
    return tostring(m)
  end

  local function poll(window, gen)
    if not S.active or S.gen ~= gen then return end
    local now = clock()
    if not window:is_focused() then cancel(window); return end
    if C.confirm_mode == 'timeout' then
      if now - S.last_event > C.timeout then commit(window); return end
    else
      local m = mods_of(window)
      if m ~= nil and now - S.last_event > C.release_grace then
        if not (m:find('CTRL') and m:find('ALT')) then
          dbg('soltou: mods=' .. m)
          commit(window)
          return
        end
      end
    end
    schedule(C.poll_interval, function() poll(window, gen) end)
  end

  local function step(window, pane, dir_)
    local now = clock()
    if not S.active then
      S.active = true
      S.gen = S.gen + 1
      S.pending = nil
      S.pane = pane
      S.base = (current and position(current)) and current or nil
      local start = position(current or '')
      if not start then
        -- partindo do classic: o próximo é o último usado (igual ao `theme next`)
        start = (position(index.last) or 1) - dir_
      end
      S.idx = start
      S.last_step = 0
      pcall(function() window:perform_action(act.ActivateKeyTable { name = 'theme_switch', one_shot = false, replace_current = true }, pane) end)
      schedule(C.poll_interval, function() poll(window, S.gen) end)
    end
    S.last_event = now
    if now - S.last_step < C.step_min_interval then return end   -- auto-repeat: ignora
    S.last_step = now
    S.idx = ((S.idx - 1 + dir_) % #names) + 1
    dbg('passo ' .. dir_ .. ' -> ' .. names[S.idx].name)
    apply_preview(window, names[S.idx])
    banner(window)
  end

  local function a_step(d) return wezterm.action_callback(function(w, p) step(w, p, d) end) end
  local a_cancel = wezterm.action_callback(function(w) cancel(w) end)
  local a_commit = wezterm.action_callback(function(w) commit(w) end)

  config.keys = config.keys or {}
  table.insert(config.keys, { key = 't', mods = 'CTRL|ALT', action = a_step(1) })
  table.insert(config.keys, { key = 'T', mods = 'CTRL|ALT|SHIFT', action = a_step(-1) })

  config.key_tables = config.key_tables or {}
  config.key_tables.theme_switch = {
    { key = 't', mods = 'CTRL|ALT', action = a_step(1) },
    { key = 'T', mods = 'CTRL|ALT|SHIFT', action = a_step(-1) },
    { key = 'RightArrow', mods = 'NONE', action = a_step(1) },
    { key = 'LeftArrow', mods = 'NONE', action = a_step(-1) },
    { key = 'RightArrow', mods = 'CTRL|ALT', action = a_step(1) },
    { key = 'LeftArrow', mods = 'CTRL|ALT', action = a_step(-1) },
    { key = 'Escape', mods = 'NONE', action = a_cancel },
    { key = 'Enter', mods = 'NONE', action = a_commit },
  }

  -- reload do arquivo de tema chegou: a prévia já não é necessária
  wezterm.on('window-config-reloaded', function(window)
    if S.pending then
      S.pending = nil
      clear_overrides(window)
    end
  end)

  return { state = S, step = step, cancel = cancel, commit = commit }
end

return M
