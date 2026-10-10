-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Vai para a home (dashboard do snacks.nvim) numa aba própria, sem mexer no layout atual
vim.keymap.set("n", "<leader>H", function()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "snacks_dashboard" then
        vim.api.nvim_set_current_tabpage(tab)
        return
      end
    end
  end
  vim.cmd("tabnew")
  Snacks.dashboard.open({ buf = 0, win = 0 })
end, { desc = "Home (Dashboard em aba própria)" })

-- Alterna entre os colorschemes instalados: <leader>uj (próximo) / <leader>uk (anterior)
local function cycle_colorscheme(step)
  local schemes = vim.fn.getcompletion("", "color")
  local current = vim.g.colors_name
  local index = 1
  for i, name in ipairs(schemes) do
    if name == current then
      index = i
      break
    end
  end
  local next_name = schemes[((index - 1 + step) % #schemes) + 1]
  vim.cmd.colorscheme(next_name)
  vim.notify("Colorscheme: " .. next_name)
end

vim.keymap.set("n", "<leader>uj", function() cycle_colorscheme(1) end, { desc = "Próximo colorscheme" })
vim.keymap.set("n", "<leader>uk", function() cycle_colorscheme(-1) end, { desc = "Colorscheme anterior" })
