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
      -- colorscheme vem do sistema de temas global (`theme`); classic = wildcharm de sempre
      colorscheme = function()
        require("config.theme").apply()
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
