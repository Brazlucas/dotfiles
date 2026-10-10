-- Colorscheme padrão e logo da home (dashboard do snacks.nvim)
local header = [[
██╗     ██╗   ██╗ ██████╗ ██╗   ██╗███████╗████████╗ █████╗ 
██║     ██║   ██║██╔═══██╗██║   ██║██╔════╝╚══██╔══╝██╔══██╗
██║     ██║   ██║██║   ██║██║   ██║█████╗     ██║   ███████║
██║     ██║   ██║██║▄▄ ██║██║   ██║██╔══╝     ██║   ██╔══██║
███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗   ██║   ██║  ██║
╚══════╝ ╚═════╝  ╚══▀▀═╝  ╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═╝
                                                            
  " |\\__/,|   (`\\ ",
	" |_ _  |.--.) )",
	" ( T   )     / ",
	"(((^_(((/(((_/ ",
]]

return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- cyberpunk quando o estado global está ligado; senão o wildcharm de sempre
      colorscheme = function()
        local cyber = require("config.cyber")
        cyber.apply(cyber.is_on())
      end,
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = { header = header },
      },
    },
  },
}
