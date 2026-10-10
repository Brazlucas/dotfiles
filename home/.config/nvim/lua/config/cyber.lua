-- Tema cyberpunk liga/desliga, sincronizado com WezTerm e tmux via ~/.cyber_state do Windows.
local M = {}

local state_file = "/mnt/c/Users/blubs/.cyber_state"
local ON, OFF = "cyberpunk", "wildcharm"

function M.is_on()
  local f = io.open(state_file, "r")
  if not f then return true end
  local v = f:read("*l")
  f:close()
  return v ~= "off"
end

function M.apply(on)
  local want = on and ON or OFF
  if vim.g.colors_name ~= want then pcall(vim.cmd.colorscheme, want) end
end

-- <leader>uz: roda o script global (WezTerm + tmux) e já aplica aqui
function M.toggle()
  local new_on = not M.is_on()
  vim.system({ vim.fn.expand("~/.config/cyber/toggle.sh"), new_on and "on" or "off" }, { text = true })
  M.apply(new_on)
  vim.notify("Cyberpunk: " .. (new_on and "ligado" or "desligado"))
end

-- observa o arquivo de estado (WezTerm/tmux podem ter mudado) a cada 1s
local timer
function M.watch()
  if timer then return end
  timer = vim.uv.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(function()
    local on = M.is_on()
    if (vim.g.colors_name == ON) ~= on and (vim.g.colors_name == ON or vim.g.colors_name == OFF) then
      M.apply(on)
    end
  end))
end

return M
