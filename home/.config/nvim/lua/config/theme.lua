-- Integra o nvim ao sistema de temas (`theme`): lê o estado global, aplica o colorscheme
-- e acompanha mudanças feitas pelo WezTerm, pelo tmux ou pelo terminal.
local M = {}

local state_file = "/mnt/c/Users/blubs/.theme_state"
local legacy_file = "/mnt/c/Users/blubs/.cyber_state"
local palette_file = vim.fn.expand("~/.config/theme/build/current/nvim.lua")

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

local applied
-- aplica o colorscheme do tema: "generated" usa colors/theme.lua; senão um colorscheme nativo
function M.apply()
  local name = M.current()
  local ok, P = pcall(dofile, palette_file)
  local scheme = (ok and P.colorscheme) or "generated"
  local want = (scheme == "generated") and "theme" or scheme
  -- paleta gerada pode ter mudado mesmo com o mesmo nome do tema: reaplica sempre que o nome mudar
  if applied ~= name or vim.g.colors_name ~= want then
    pcall(vim.cmd.colorscheme, want)
    applied = name
  end
end

-- <leader>uz: liga/desliga (usa o CLI global, que também atualiza WezTerm e tmux)
function M.toggle()
  vim.system({ vim.fn.expand("~/.local/bin/theme"), "toggle" }, { text = true }, vim.schedule_wrap(function()
    M.apply()
    vim.notify("Tema: " .. M.current())
  end))
end

-- observa o estado a cada 1s
local timer
function M.watch()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(function()
    if applied ~= M.current() then M.apply() end
  end))
end

return M
