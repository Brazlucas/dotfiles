-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Mason installs npm packages (vtsls, json-lsp, vue-language-server) from the public registry;
-- the global ~/.npmrc points to a private CodeArtifact registry whose token expires (E401).
vim.env.NPM_CONFIG_REGISTRY = "https://registry.npmjs.org/"

-- phpactor flags Eloquent magic methods (where, find, create...) as nonexistent.
vim.g.lazyvim_php_lsp = "intelephense"
