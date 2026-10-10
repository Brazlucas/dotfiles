-- UI estilo AstroNvim: seletor File/Bufs/Git no neo-tree, buffers no topo, branch/diff na statusline
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      -- atualiza o status quando arquivos mudam fora do nvim (lazygit, outro terminal, agentes)
      filesystem = { use_libuv_file_watcher = true },
      source_selector = {
        winbar = true,
        statusline = false,
        content_layout = "center",
        sources = {
          { source = "filesystem", display_name = " 󰉓 File " },
          { source = "buffers", display_name = " 󰈚 Bufs " },
          { source = "git_status", display_name = " 󰊢 Git " },
        },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        separator_style = "thin",
        show_buffer_close_icons = true,
        diagnostics = "nvim_lsp",
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- branch à esquerda (já vem no LazyVim) + diff do git na direita
      local has_diff = false
      for _, c in ipairs(opts.sections.lualine_x or {}) do
        if c == "diff" or (type(c) == "table" and c[1] == "diff") then
          has_diff = true
        end
      end
      if not has_diff then
        table.insert(opts.sections.lualine_x, { "diff" })
      end
    end,
  },
}
