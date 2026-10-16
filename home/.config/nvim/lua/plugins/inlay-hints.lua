-- Inlay hints: TypeScript/JavaScript e Vue (vtsls + vue_ls), Rust (rustaceanvim/rust-analyzer).
-- PHP/Laravel: nem o intelephense nem o phpactor expõem textDocument/inlayHint; o LazyVim liga os hints
-- sozinho em qualquer servidor que passe a oferecê-los.

-- O node padrão do nvm aqui é o v14 (projetos Vue 2) e o vtsls/vue-language-server/intelephense não rodam nele.
-- Os servidores sobem com o node mais novo instalado no nvm (só eles; o node do shell não muda).
local function lsp_node_path()
  local best, bestv
  for _, dir in ipairs(vim.fn.glob(vim.env.HOME .. "/.nvm/versions/node/v*", false, true)) do
    local v = vim.version.parse(vim.fn.fnamemodify(dir, ":t"):sub(2))
    if v and v.major >= 20 and (not bestv or vim.version.gt(v, bestv)) then
      best, bestv = dir, v
    end
  end
  return best and (best .. "/bin:" .. vim.env.PATH) or vim.env.PATH
end

local ts_hints = {
  parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- o LazyVim exclui "vue" dos hints por padrão; aqui vue entra (vem do vtsls + @vue/typescript-plugin)
      opts.inlay_hints = vim.tbl_deep_extend("force", opts.inlay_hints or {}, { enabled = true, exclude = {} })

      opts.servers = opts.servers or {}
      for _, name in ipairs({ "vtsls", "vue_ls", "intelephense" }) do
        opts.servers[name] = vim.tbl_deep_extend("force", opts.servers[name] or {}, {
          cmd_env = { PATH = lsp_node_path() },
        })
      end
      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls, {
        settings = {
          typescript = { inlayHints = ts_hints },
          javascript = { inlayHints = ts_hints },
        },
      })
    end,
  },
}
