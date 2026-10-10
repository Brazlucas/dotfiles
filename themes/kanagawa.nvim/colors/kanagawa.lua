-- kanagawa: colorscheme exportado do sistema `theme` (autocontido). Base wildcharm + fundo transparente.
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.termguicolors = true
vim.o.background = "dark"
pcall(vim.cmd.colorscheme, "wildcharm")
vim.g.colors_name = "kanagawa"

local P = (function()
return {
  name = 'kanagawa',
  colorscheme = 'generated',
  colors = {
    bg = '#1f1f28',
    bg_alt = '#2a2a37',
    bg_deep = '#16161d',
    fg = '#dcd7ba',
    dim = '#727169',
    subtle = '#938aa9',
    delim = '#c8c093',
    line = '#363646',
    sel = '#2d4f67',
    sel_fg = '#dcd7ba',
    accent1 = '#ff9e3b',
    accent2 = '#7fb4ca',
    red = '#c34043',
    green = '#76946a',
    yellow = '#c0a36e',
    blue = '#7e9cd8',
    magenta = '#957fb8',
    cyan = '#6a9589',
    white = '#ffffff',
  },
  diff = {
    add = '#303635',
    change = '#32384b',
    delete = '#40262d',
    text = '#2d4f67',
  },
}
end)()
local k = P.colors
local c = {
  fg = k.fg, dim = k.dim, panel = k.bg_alt, deep = k.bg_deep, line = k.line,
  cyan = k.accent2, pink = k.accent1, blue = k.blue, violet = k.magenta,
  mint = k.green, yellow = k.yellow, sel = k.sel, bg = k.bg,
  subtle = k.subtle, delim = k.delim,
}
local D = P.diff

local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- fundo transparente
for _, g in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer", "FoldColumn",
  "MsgArea", "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "WhichKeyNormal",
  "SnacksNormal", "SnacksPicterNormal" }) do
  hl(g, { fg = c.fg, bg = "NONE" })
end
hl("EndOfBuffer", { fg = c.bg, bg = "NONE" })

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
hl("Delimiter", { fg = c.delim })
hl("Title", { fg = c.pink, bold = true })
hl("Directory", { fg = c.cyan })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- interface
hl("Cursor", { fg = c.bg, bg = c.pink })
hl("CursorLine", { bg = c.panel })
hl("CursorLineNr", { fg = c.pink, bold = true })
hl("LineNr", { fg = c.dim })
hl("Visual", { bg = c.sel })
hl("Search", { fg = c.bg, bg = c.pink })
hl("IncSearch", { fg = c.bg, bg = c.cyan, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.cyan, bold = true })
hl("MatchParen", { fg = c.cyan, bold = true, underline = true })
hl("NonText", { fg = c.subtle })
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
hl("TabLineSel", { fg = c.cyan, bg = c.bg, bold = true })

-- diagnósticos e diff
hl("DiagnosticError", { fg = c.pink })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.cyan })
hl("DiagnosticHint", { fg = c.blue })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.pink })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.cyan })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.blue })
hl("DiffAdd", { bg = D.add })
hl("DiffChange", { bg = D.change })
hl("DiffDelete", { bg = D.delete })
hl("DiffText", { bg = D.text })
hl("Added", { fg = c.mint })
hl("Changed", { fg = c.blue })
hl("Removed", { fg = c.pink })

-- plugins
-- picker (snacks): diretório/caminho legíveis em vez de quase invisíveis
hl("SnacksPickerDir", { fg = c.subtle })
hl("SnacksPickerPathHidden", { fg = c.subtle })
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
