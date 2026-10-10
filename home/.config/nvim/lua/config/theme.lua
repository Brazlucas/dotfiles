-- Integra o nvim ao sistema de temas (`theme`): lê o estado global, aplica o colorscheme
-- e acompanha mudanças feitas pelo WezTerm, pelo tmux ou pelo terminal.
local M = {}

local state_file = "/mnt/c/Users/blubs/.theme_state"
local legacy_file = "/mnt/c/Users/blubs/.cyber_state"
local palette_file = vim.fn.expand("~/.config/theme/build/current/nvim.lua")
-- marcador do tema ativo (nome + hora): muda em `theme set` E em `theme preview` (prévia do seletor Ctrl+Alt+T)
local active_dir = vim.fn.expand("~/.config/theme/build")
local active_file = active_dir .. "/.active"

local function read(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local v = f:read("*l")
  f:close()
  return v
end

-- nome do tema ativo (compatível com o antigo on/off)
function M.current()
  local name = read(state_file)
  if name and name ~= "" then return name end
  return read(legacy_file) == "off" and "classic" or "cyberpunk"
end

function M.is_on()
  return M.current() ~= "classic"
end

local applied -- marcador aplicado por último

-- aplica o colorscheme do tema: "generated" usa colors/theme.lua; senão um colorscheme nativo
function M.apply()
  local mk = read(active_file)
  if mk == nil or mk == "" then return end  -- arquivo sendo regravado: o próximo evento reaplica
  local ok, P = pcall(dofile, palette_file)
  local scheme = (ok and P.colorscheme) or "generated"
  local want = (scheme == "generated") and "theme" or scheme
  -- o marcador muda a cada troca (inclusive prévias); a paleta é relida a cada `colorscheme theme`
  if applied ~= mk or vim.g.colors_name ~= want then
    pcall(vim.cmd.colorscheme, want)
    applied = mk
  end
end

-- <leader>uz: liga/desliga (usa o CLI global, que também atualiza WezTerm e tmux)
function M.toggle()
  vim.system({ vim.fn.expand("~/.local/bin/theme"), "toggle" }, { text = true }, vim.schedule_wrap(function()
    M.apply()
    vim.notify("Tema: " .. M.current())
  end))
end

-- acompanha o tema: observador de arquivo (reação imediata, inclusive na prévia) + relógio de 1s de reserva
local timer, fs_event
local function sync()
  local mk = read(active_file)
  if mk and mk ~= "" and mk ~= applied then M.apply() end
end

function M.watch()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(sync))
  fs_event = vim.uv.new_fs_event()
  if fs_event then
    fs_event:start(active_dir, {}, vim.schedule_wrap(function(err, fname)
      if not err and fname == ".active" then sync() end
    end))
  end
end

return M
