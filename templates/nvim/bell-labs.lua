-- Bell Labs — Neovim colourscheme (colors/bell-labs.lua).
-- Deliberately close to acme: plain text and almost no syntax
-- colour. Comments, strings and diagnostics are the only coloured text.
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = "{{mode}}"
vim.g.colors_name = "bell-labs"

local c = {
  bg = "{{background}}", bg_alt = "{{background_alt}}", bg_dim = "{{background_dim}}",
  fg = "{{foreground}}", fg_dim = "{{foreground_dim}}", muted = "{{muted}}",
  sel = "{{selection}}", sel_alt = "{{selection_alt}}",
  border = "{{border_active}}", border_dim = "{{border_inactive}}",
  accent = "{{accent}}", red = "{{red}}", green = "{{green}}", yellow = "{{yellow}}",
  blue = "{{bright_blue}}", cyan = "{{cyan}}", grey = "{{bright_black}}",
}

local hl = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end

-- Editor surfaces
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
hl("FloatBorder", { fg = c.border, bg = c.bg_alt })
hl("FloatTitle", { fg = c.fg, bg = c.bg_alt, bold = true })
hl("NormalNC", { link = "Normal" })
hl("SignColumn", { bg = c.bg })
hl("LineNr", { fg = c.muted })
hl("CursorLineNr", { fg = c.fg, bold = true })
hl("CursorLine", { bg = c.bg_dim })
hl("ColorColumn", { bg = c.bg_dim })
hl("Cursor", { fg = c.bg, bg = c.fg })
hl("Visual", { bg = c.sel })
hl("Search", { bg = c.sel_alt })
hl("IncSearch", { fg = c.bg, bg = c.accent })
hl("CurSearch", { link = "IncSearch" })
hl("MatchParen", { bg = c.sel_alt, bold = true })
hl("StatusLine", { fg = c.fg, bg = c.bg_alt })
hl("StatusLineNC", { fg = c.fg_dim, bg = c.bg_alt })
hl("WinSeparator", { fg = c.border })
hl("VertSplit", { link = "WinSeparator" })
hl("TabLine", { fg = c.fg_dim, bg = c.bg_alt })
hl("TabLineSel", { fg = c.fg, bg = c.sel_alt, bold = true })
hl("TabLineFill", { bg = c.bg_alt })
hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel", { bg = c.sel_alt })
hl("PmenuSbar", { bg = c.bg_alt })
hl("PmenuThumb", { bg = c.muted })
hl("Folded", { fg = c.fg_dim, bg = c.bg_dim })
hl("NonText", { fg = c.border_dim })
hl("Whitespace", { fg = c.border_dim })
hl("EndOfBuffer", { fg = c.bg })
hl("Directory", { fg = c.accent })
hl("Title", { fg = c.fg, bold = true })
hl("ErrorMsg", { fg = c.red })
hl("WarningMsg", { fg = c.yellow })
hl("MoreMsg", { fg = c.green })
hl("Question", { fg = c.green })
hl("SpecialKey", { fg = c.grey })

-- Syntax: almost monochrome
hl("Comment", { fg = c.green, italic = true })
hl("String", { fg = c.accent })
hl("Character", { link = "String" })
hl("Constant", { fg = c.fg })
hl("Number", { fg = c.fg })
hl("Boolean", { fg = c.fg })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.fg })
hl("Statement", { fg = c.fg, bold = true })
hl("Keyword", { fg = c.fg, bold = true })
hl("Operator", { fg = c.fg })
hl("PreProc", { fg = c.fg_dim })
hl("Type", { fg = c.fg })
hl("Special", { fg = c.fg_dim })
hl("Delimiter", { fg = c.fg })
hl("Underlined", { fg = c.accent, underline = true })
hl("Todo", { fg = c.fg, bg = c.sel, bold = true })
hl("Error", { fg = c.red, bold = true })
hl("@variable", { fg = c.fg })
hl("@markup.heading", { fg = c.fg, bold = true })
hl("@markup.link", { fg = c.accent, underline = true })
hl("@markup.raw", { fg = c.accent })

-- Diagnostics and diffs
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticOk", { fg = c.green })
hl("DiagnosticUnderlineError", { sp = c.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.yellow, undercurl = true })
hl("DiffAdd", { bg = "{{diff_add}}" })
hl("DiffDelete", { fg = c.red, bg = "{{diff_delete}}" })
hl("DiffChange", { bg = c.bg_dim })
hl("DiffText", { bg = c.sel })
hl("Added", { fg = c.green })
hl("Removed", { fg = c.red })
hl("Changed", { fg = c.yellow })
