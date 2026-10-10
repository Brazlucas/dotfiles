-- Cyberpunk: base wildcharm + fundo transparente (o vidro do WezTerm aparece) + acentos neon.
-- Liga/desliga com <leader>uz (ou Ctrl+Alt+G no WezTerm). Desligado = wildcharm, como era antes.
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.o.background = "dark"
pcall(vim.cmd.colorscheme, "wildcharm")
vim.g.colors_name = "cyberpunk"

local c = {
  fg = "#d3dcea", dim = "#5c6b80", panel = "#0d1117", deep = "#06080c", line = "#1f2a37",
  cyan = "#05f2ff", pink = "#ff2a6d", blue = "#3d8bff", violet = "#b45cff",
  mint = "#00ffa3", yellow = "#fcee0a", sel = "#12404a",
}
local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- fundo transparente
for _, g in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer", "FoldColumn",
  "MsgArea", "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "WhichKeyNormal",
  "SnacksNormal", "SnacksPicterNormal" }) do
  hl(g, { fg = c.fg, bg = "NONE" })
end
hl("EndOfBuffer", { fg = "#080b10", bg = "NONE" })

-- sintaxe
hl("Comment", { fg = c.dim, italic = true })
hl("Constant", { fg = c.yellow })
hl("String", { fg = c.mint })
hl("Character", { fg = c.mint })
hl("Number", { fg = c.yellow })
hl("Boolean", { fg = c.yellow, bold = true })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.cyan })
hl("Statement", { fg = c.pink })
hl("Conditional", { fg = c.pink })
hl("Repeat", { fg = c.pink })
hl("Keyword", { fg = c.pink, italic = true })
hl("Operator", { fg = c.violet })
hl("Exception", { fg = c.pink })
hl("PreProc", { fg = c.violet })
hl("Include", { fg = c.violet })
hl("Type", { fg = c.blue })
hl("Structure", { fg = c.blue })
hl("Special", { fg = c.cyan })
hl("Delimiter", { fg = "#8a9bb3" })
hl("Title", { fg = c.pink, bold = true })
hl("Directory", { fg = c.cyan })
hl("Todo", { fg = "#080b10", bg = c.yellow, bold = true })

-- interface
hl("Cursor", { fg = "#080b10", bg = c.pink })
hl("CursorLine", { bg = c.panel })
hl("CursorLineNr", { fg = c.pink, bold = true })
hl("LineNr", { fg = c.dim })
hl("Visual", { bg = c.sel })
hl("Search", { fg = "#080b10", bg = c.pink })
hl("IncSearch", { fg = "#080b10", bg = c.cyan, bold = true })
hl("CurSearch", { fg = "#080b10", bg = c.cyan, bold = true })
hl("MatchParen", { fg = c.cyan, bold = true, underline = true })
hl("NonText", { fg = "#6f819a" })
hl("Whitespace", { fg = c.line })
hl("ColorColumn", { bg = c.panel })
hl("Folded", { fg = c.dim, bg = c.panel })
hl("WinSeparator", { fg = c.line, bg = "NONE" })
hl("VertSplit", { fg = c.line, bg = "NONE" })
hl("FloatBorder", { fg = c.pink, bg = "NONE" })
hl("FloatTitle", { fg = c.cyan, bg = "NONE", bold = true })
hl("Pmenu", { fg = c.fg, bg = c.panel })
hl("PmenuSel", { fg = c.cyan, bg = c.sel, bold = true })
hl("PmenuSbar", { bg = c.panel })
hl("PmenuThumb", { bg = c.pink })
hl("StatusLine", { fg = c.fg, bg = c.deep })
hl("StatusLineNC", { fg = c.dim, bg = c.deep })
hl("TabLine", { fg = c.dim, bg = c.deep })
hl("TabLineFill", { bg = c.deep })
hl("TabLineSel", { fg = c.cyan, bg = "#080b10", bold = true })

-- diagnósticos e diff
hl("DiagnosticError", { fg = c.pink })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.cyan })
hl("DiagnosticHint", { fg = c.blue })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.pink })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.cyan })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.blue })
hl("DiffAdd", { bg = "#06301f" })
hl("DiffChange", { bg = "#0c2440" })
hl("DiffDelete", { bg = "#3a0f1f" })
hl("DiffText", { bg = "#12404a" })
hl("Added", { fg = c.mint })
hl("Changed", { fg = c.blue })
hl("Removed", { fg = c.pink })

-- plugins
-- picker (snacks): diretório/caminho legíveis em vez de quase invisíveis
hl("SnacksPickerDir", { fg = "#6f819a" })
hl("SnacksPickerPathHidden", { fg = "#6f819a" })
hl("SnacksPickerPathIgnored", { fg = c.dim })
hl("SnacksPickerComment", { fg = c.dim })
hl("SnacksPickerTotals", { fg = c.dim })
hl("SnacksPickerIdx", { fg = c.dim })
hl("SnacksPickerPrompt", { fg = c.pink, bold = true })
hl("SnacksPickerMatch", { fg = c.cyan, bold = true })
hl("SnacksPickerListCursorLine", { bg = c.sel })
hl("SnacksPickerBorder", { fg = c.pink })
hl("SnacksPickerTitle", { fg = c.cyan, bold = true })
hl("SnacksDashboardHeader", { fg = c.pink })
hl("SnacksDashboardKey", { fg = c.cyan, bold = true })
hl("NeoTreeDirectoryName", { fg = c.cyan })
hl("NeoTreeDirectoryIcon", { fg = c.cyan })
hl("NeoTreeRootName", { fg = c.pink, bold = true })
hl("NeoTreeGitModified", { fg = c.blue })
hl("NeoTreeGitAdded", { fg = c.mint })
hl("BufferLineFill", { bg = "NONE" })
hl("BufferLineBackground", { fg = c.dim, bg = "NONE" })
hl("BufferLineBufferSelected", { fg = c.cyan, bg = "NONE", bold = true })
hl("BufferLineIndicatorSelected", { fg = c.pink, bg = "NONE" })
