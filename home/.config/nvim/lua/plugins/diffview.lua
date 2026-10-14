-- Diffview + integração com o neo-tree: na aba Git, Enter/duplo clique num arquivo modificado abre o diff dele
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview (todos os modificados)" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview: fechar" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Histórico do arquivo" },
    },
    opts = function()
      -- commit/push sem sair do Diffview (painel de arquivos): `-` já faz stage/unstage; C = commit, P = push
      local function git(args, msg_ok)
        vim.system(vim.list_extend({ "git" }, args), { text = true }, vim.schedule_wrap(function(r)
          if r.code == 0 then
            vim.notify(msg_ok, vim.log.levels.INFO)
            require("diffview").emit("refresh_files")
          else
            vim.notify((r.stderr ~= "" and r.stderr or r.stdout), vim.log.levels.ERROR)
          end
        end))
      end
      local function commit()
        vim.ui.input({ prompt = "Mensagem do commit: " }, function(msg)
          if msg and msg ~= "" then git({ "commit", "-m", msg }, "Commit feito") end
        end)
      end
      local function push() git({ "push" }, "Push feito") end
      return {
      enhanced_diff_hl = true,
      keymaps = {
        -- <leader>e/<leader>b do Diffview roubam o atalho do neo-tree; `q` fecha o Diffview
        view = { ["<leader>e"] = false, ["<leader>b"] = false, ["q"] = "<cmd>DiffviewClose<cr>" },
        file_panel = { ["<leader>e"] = false, ["<leader>b"] = false, ["q"] = "<cmd>DiffviewClose<cr>", ["C"] = commit, ["P"] = push },
        file_history_panel = { ["<leader>e"] = false, ["<leader>b"] = false, ["q"] = "<cmd>DiffviewClose<cr>" },
      },
      }
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      local function open_diff(state)
        local node = state.tree:get_node()
        -- pasta: comportamento normal (expandir/recolher)
        if node.type == "directory" then
          require("neo-tree.sources.git_status.commands").open(state)
          return
        end
        vim.cmd("DiffviewOpen -C" .. vim.fn.fnameescape(state.path) .. " -- " .. vim.fn.fnameescape(node.path))
      end
      opts.git_status = vim.tbl_deep_extend("force", opts.git_status or {}, {
        window = { mappings = { ["<cr>"] = open_diff, ["<2-LeftMouse>"] = open_diff, ["o"] = "open" } },
      })
    end,
  },
}
