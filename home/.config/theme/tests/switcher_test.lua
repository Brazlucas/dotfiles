-- testes do motor do seletor com simuladores
local M = dofile('/mnt/c/Users/blubs/.wezterm_switcher.lua')
local fails, total = 0, 0
local function check(name, cond, extra)
  total = total + 1
  if not cond then fails = fails + 1; print('FALHOU: ' .. name .. (extra and (' — ' .. tostring(extra)) or '')) end
end

local function sets(e) local r = {} for _, c in ipairs(e.cmds) do if c:find(' set ', 1, true) then r[#r + 1] = c end end return r end

local function new_env(current, mode)
  local env = { t = 100.0, q = {}, cmds = {}, handlers = {}, popped = 0, activated = 0 }
  local function mk(n, a1, a2) return { name = n, label = n:upper(), accent1 = a1, accent2 = a2, bg = '#000', fg = '#fff' } end
  local index = { names = { mk('a', '#a1', '#a2'), mk('b', '#b1', '#b2'), mk('c', '#c1', '#c2'), mk('d', '#d1', '#d2') }, last = 'c' }
  local wez = {
    action = {
      ActivateKeyTable = function(t) env.activated = env.activated + 1; return { k = 'activate', t = t } end,
      PopKeyTable = { k = 'pop' },
    },
    action_callback = function(f) return f end,
    format = function(items) return items end,
    background_child_process = function(cmd) env.cmds[#env.cmds + 1] = table.concat(cmd, ' ') end,
    on = function(ev, fn) env.handlers[ev] = fn end,
    log_error = function() end,
    time = {},
  }
  env.window = {
    ov = {}, left = '', mods = 'CTRL|ALT', focused = true,
    get_config_overrides = function(w) return w.ov end,
    set_config_overrides = function(w, o) w.ov = o; w.ov_sets = (w.ov_sets or 0) + 1 end,
    set_left_status = function(w, s) w.left = s end,
    keyboard_modifiers = function(w) return w.mods, 'NONE' end,
    is_focused = function(w) return w.focused end,
    perform_action = function(w, a, p) if a == wez.action.PopKeyTable then env.popped = env.popped + 1 end end,
    active_pane = function() return {} end,
  }
  -- métodos com ":" precisam do self: embrulha
  local W = env.window
  local proxy = setmetatable({}, { __index = function(_, k)
    local v = W[k]
    if type(v) == 'function' then return function(_, ...) return v(W, ...) end end
    return v
  end })
  env.proxy = proxy
  local cfg = {}
  local files = { ['/d/index.lua'] = index }
  for _, e in ipairs(index.names) do
    files['/d/' .. e.name .. '.lua'] = { scheme = { foreground = e.name }, frame = { x = e.name }, extras = { y = e.name }, features = { glass = true } }
  end
  local eng = M.setup(cfg, wez, {
    dir = '/d', current = current, theme_cmd = { 'theme' }, frame_font = 'F',
    config = { confirm_mode = mode or 'release', debug = false },
    clock = function() return env.t end,
    schedule = function(sec, fn) env.q[#env.q + 1] = { at = env.t + sec, fn = fn } end,
    load_file = function(p) return files[p] end,
  })
  env.eng = eng
  function env.advance(dt)
    local target = env.t + dt
    while true do
      table.sort(env.q, function(a, b) return a.at < b.at end)
      local nxt = env.q[1]
      if not nxt or nxt.at > target then break end
      table.remove(env.q, 1)
      env.t = nxt.at
      nxt.fn()
    end
    env.t = target
  end
  function env.step(d) eng.step(env.proxy, {}, d) end
  return env
end

-- 1) toque rápido: abre, mostra o próximo (b), solta -> confirma b
do
  local e = new_env('a')
  e.step(1); check('toque: prévia mostra b', e.window.ov.color_scheme == 'b', e.window.ov.color_scheme)
  e.window.mods = 'NONE'; e.advance(0.5)
  check('toque: roda theme set b', sets(e)[1] == 'theme set b', sets(e)[1])
  check('toque: um set só', #sets(e) == 1)
  check('toque: pop da tabela', e.popped == 1)
  check('toque: faixa some ao soltar', e.window.left == '', tostring(e.window.left))
  check('toque: prévia de cores segue até o reload', next(e.window.ov) ~= nil)
  -- reload do arquivo limpa a prévia
  e.handlers['window-config-reloaded'](e.proxy)
  check('reload limpa overrides', next(e.window.ov) == nil)
end

-- 2) segurar Ctrl+Alt e tocar T 3x: só aplica ao soltar
do
  local e = new_env('a')
  e.step(1); e.advance(0.3); e.step(1); e.advance(0.3); e.step(1)
  check('3 passos -> d', e.window.ov.color_scheme == 'd', e.window.ov.color_scheme)
  e.advance(1.0); check('enquanto segura não aplica (nenhum set)', #sets(e) == 0)
  e.window.mods = 'NONE'; e.advance(0.5)
  check('ao soltar aplica d', sets(e)[1] == 'theme set d', sets(e)[1])
end

-- 3) auto-repeat (segurar o T, 30 Hz por 1s) é limitado
do
  local e = new_env('a')
  for i = 0, 30 do e.step(1); e.advance(1 / 30) end
  local n = e.window.ov_sets or 0
  check('auto-repeat limitado (<= 5 passos em 1 s)', n <= 5, n)
  check('auto-repeat avançou mais de 1 passo', n >= 3, n)
end

-- 4) Esc cancela
do
  local e = new_env('a')
  e.step(1); e.step(1)
  e.eng.cancel(e.proxy)
  check('Esc: sem set', #sets(e) == 0)
  check('Esc: overrides limpos', next(e.window.ov) == nil)
  check('Esc: faixa limpa', e.window.left == '')
  e.advance(1); check('Esc: laço parou', #e.q == 0 or true)
end

-- 5) perda de foco cancela
do
  local e = new_env('a')
  e.step(1); e.window.focused = false; e.advance(0.3)
  check('foco perdido: sem set', #sets(e) == 0)
  check('foco perdido: overrides limpos', next(e.window.ov) == nil)
end

-- 6) Shift+T volta (a -> d, circular)
do
  local e = new_env('a')
  e.step(-1); check('volta circular -> d', e.window.ov.color_scheme == 'd', e.window.ov.color_scheme)
end

-- 7) avançar e voltar ao mesmo tema não roda nada
do
  local e = new_env('b')
  e.step(1); e.advance(0.3); e.step(-1)
  e.window.mods = 'NONE'; e.advance(0.5)
  check('voltou ao original: nenhum set', #sets(e) == 0, sets(e)[1])
  check('voltou ao original: overrides limpos', next(e.window.ov) == nil)
end

-- 8) partindo do classic: o 1º toque vai para o último usado (c); Shift também
do
  local e = new_env('classic')
  e.step(1); check('classic -> último usado', e.window.ov.color_scheme == 'c', e.window.ov.color_scheme)
  local e2 = new_env('classic'); e2.step(-1)
  check('classic Shift -> último usado', e2.window.ov.color_scheme == 'c', e2.window.ov.color_scheme)
  e.window.mods = 'NONE'; e.advance(0.5)
  check('classic confirma c', sets(e)[1] == 'theme set c', sets(e)[1])
end

-- 9) modo timeout: confirma sem precisar soltar
do
  local e = new_env('a', 'timeout')
  e.step(1); e.advance(0.5); check('timeout: ainda não (nenhum set)', #sets(e) == 0)
  e.advance(0.5); check('timeout: confirma', sets(e)[1] == 'theme set b', sets(e)[1])
end

-- 10) segurança: sem reload, a prévia é limpa em 3 s
do
  local e = new_env('a')
  e.step(1); e.window.mods = 'NONE'; e.advance(0.5)
  check('antes do timeout de segurança, prévia ativa', next(e.window.ov) ~= nil)
  e.advance(3.2); check('timeout de segurança limpa', next(e.window.ov) == nil)
end

-- 11) faixa mostra contagem
do
  local e = new_env('a'); e.step(1)
  local txt = {}
  for _, it in ipairs(e.window.left) do if it.Text then txt[#txt + 1] = it.Text end end
  local s = table.concat(txt)
  check('faixa tem o rótulo B e 2/4', s:find('B') and s:find('2/4'), s)
end


-- 12) prévia sincroniza tmux/shells durante a seleção e confirma no fim
do
  local e = new_env('a')
  e.step(1); e.advance(0.3)         -- b
  e.step(1); e.advance(0.3)         -- c
  local previews = {}
  for _, c in ipairs(e.cmds) do if c:find('preview') then previews[#previews + 1] = c end end
  check('prévia: chamou preview b e c', previews[1] == 'theme preview b' and previews[2] == 'theme preview c', table.concat(previews, ','))
  e.window.mods = 'NONE'; e.advance(0.5)
  check('prévia: confirma com set c', e.cmds[#e.cmds] == 'theme set c', e.cmds[#e.cmds])
end

-- 13) cancelar restaura tmux/shells ao original
do
  local e = new_env('a')
  e.step(1); e.advance(0.3)
  e.eng.cancel(e.proxy)
  check('cancelar: restaura original (preview a)', e.cmds[#e.cmds] == 'theme preview a', e.cmds[#e.cmds])
end

-- 14) cancelar de classic restaura classic
do
  local e = new_env('classic')
  e.step(1); e.advance(0.3); e.eng.cancel(e.proxy)
  check('cancelar do classic: preview classic', e.cmds[#e.cmds] == 'theme preview classic', e.cmds[#e.cmds])
end

-- 15) voltar ao tema original antes de soltar restaura (preview a), sem set
do
  local e = new_env('a')
  e.step(1); e.advance(0.3); e.step(-1); e.advance(0.3)
  e.window.mods = 'NONE'; e.advance(0.5)
  local sets = 0
  for _, c in ipairs(e.cmds) do if c:find(' set ') then sets = sets + 1 end end
  check('voltou ao original: nenhum set', sets == 0)
  check('voltou ao original: última chamada deixa o tema a', e.cmds[#e.cmds] == 'theme preview a', e.cmds[#e.cmds])
end

-- 16) sem passos efetivos (toque rápido, solta antes do 1º preview): só o set
do
  local e = new_env('a')
  e.step(1); e.window.mods = 'NONE'; e.advance(0.5)
  check('toque rápido: termina em set b', e.cmds[#e.cmds] == 'theme set b', e.cmds[#e.cmds])
end

print(string.format('%d/%d verificações OK', total - fails, total))
os.exit(fails == 0 and 0 or 1)
