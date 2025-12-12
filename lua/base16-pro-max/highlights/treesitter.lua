local M = {}

---Setup treesitter highlights
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local blend = require("base16-pro-max.utils.colors-manipulation").blend
  local config = require("base16-pro-max.config").config

  -- Variables
  highlights["@variable"] = { fg = get_group_color("syntax", "variable", c) }
  highlights["@variable.builtin"] = {
    fg = get_group_color("states", "error", c),
    bold = config.styles.bold,
    italic = config.styles.italic,
  }
  highlights["@variable.parameter"] = { fg = get_group_color("syntax", "constant", c), italic = config.styles.italic }
  highlights["@variable.parameter.builtin"] = {
    fg = get_group_color("syntax", "keyword", c),
    bold = config.styles.bold,
  }
  highlights["@variable.member"] = { fg = get_group_color("syntax", "operator", c) }

  -- Constants
  highlights["@constant"] = {
    fg = get_group_color("syntax", "constant", c),
    bold = config.styles.bold,
  }
  highlights["@constant.builtin"] = {
    fg = get_group_color("states", "error", c),
    bold = config.styles.bold,
  }
  highlights["@constant.macro"] = { fg = get_group_color("syntax", "constant", c) }

  -- Modules and labels
  highlights["@module"] = { fg = get_group_color("syntax", "variable", c), bold = config.styles.bold }
  highlights["@module.builtin"] = {
    fg = get_group_color("syntax", "variable", c),
    bold = config.styles.bold,
  }
  highlights["@label"] = { link = "Label" }

  -- Strings
  highlights["@string"] = { link = "String" }
  highlights["@string.regexp"] = { fg = get_group_color("syntax", "keyword", c) }
  highlights["@string.escape"] = { fg = get_group_color("syntax", "function_name", c) }
  highlights["@string.special"] = { link = "String" }
  highlights["@string.special.symbol"] = { link = "Identifier" }
  highlights["@string.special.url"] = { fg = get_group_color("syntax", "keyword", c) }

  -- Numbers and characters
  highlights["@character"] = { link = "Character" }
  highlights["@character.special"] = { link = "Character" }
  highlights["@boolean"] = { link = "Boolean" }
  highlights["@number"] = { link = "Number" }
  highlights["@number.float"] = { link = "Number" }
  highlights["@float"] = { link = "Number" }

  -- Types
  highlights["@type"] = { fg = get_group_color("syntax", "constant", c) }
  highlights["@type.builtin"] = {
    fg = get_group_color("syntax", "constant", c),
    bold = config.styles.bold,
    italic = config.styles.italic,
  }
  highlights["@type.definition"] = { link = "Type" }

  -- Attributes and properties
  highlights["@attribute"] = { fg = get_group_color("syntax", "type", c), italic = config.styles.italic }
  highlights["@attribute.builtin"] = {
    fg = get_group_color("syntax", "type", c),
    bold = config.styles.bold,
  }
  highlights["@property"] = { fg = get_group_color("syntax", "operator", c) }

  -- Functions
  highlights["@function"] = { link = "Function" }
  highlights["@function.builtin"] = {
    fg = get_group_color("syntax", "operator", c),
    bold = config.styles.bold,
  }
  highlights["@function.call"] = { link = "Function" }
  highlights["@function.macro"] = { link = "Function" }
  highlights["@function.method"] = { link = "Function" }
  highlights["@function.method.call"] = { link = "Function" }

  -- Operators and constructors
  highlights["@constructor"] = { fg = get_group_color("syntax", "comment", c) }
  highlights["@operator"] = { link = "Operator" }

  -- Keywords (comprehensive mapping)
  highlights["@keyword"] = { link = "Keyword" }
  highlights["@keyword.modifier"] = { link = "Function" }
  highlights["@keyword.type"] = { link = "Function" }
  highlights["@keyword.coroutine"] = { link = "Function" }
  highlights["@keyword.function"] = {
    fg = get_group_color("syntax", "keyword", c),
    bold = config.styles.bold,
  }
  highlights["@keyword.operator"] = { fg = get_group_color("syntax", "keyword", c) }
  highlights["@keyword.import"] = { link = "Include" }
  highlights["@keyword.repeat"] = { link = "Repeat" }
  highlights["@keyword.return"] = {
    fg = get_group_color("states", "error", c),
    bold = config.styles.bold,
  }
  highlights["@keyword.debug"] = { link = "Exception" }
  highlights["@keyword.exception"] = { link = "Exception" }
  highlights["@keyword.conditional"] = { link = "Conditional" }
  highlights["@keyword.conditional.ternary"] = { link = "Operator" }
  highlights["@keyword.directive"] = { link = "PreProc" }
  highlights["@keyword.directive.define"] = { link = "Define" }
  highlights["@keyword.export"] = {
    fg = get_group_color("syntax", "function_name", c),
    italic = config.styles.italic,
  }

  -- Punctuation
  highlights["@punctuation.delimiter.regex"] = { link = "@string.regexp" }
  highlights["@punctuation.delimiter"] = { link = "Delimiter" }
  highlights["@punctuation.bracket"] = { link = "@constructor" }
  highlights["@punctuation.special"] = { link = "Special" }

  -- Comments with semantic highlighting
  highlights["@comment"] = { link = "Comment" }
  highlights["@comment.documentation"] = { link = "Comment" }
  highlights["@comment.todo"] = {
    fg = get_group_color("syntax", "type", c),
    bg = blend(get_group_color("syntax", "type", c), get_group_color("backgrounds", "normal", c), 0.1),
    bold = config.styles.bold,
  }
  highlights["@comment.note"] = {
    fg = get_group_color("states", "info", c),
    bg = blend(get_group_color("states", "info", c), get_group_color("backgrounds", "normal", c), 0.1),
    bold = config.styles.bold,
  }
  highlights["@comment.warning"] = {
    fg = get_group_color("states", "warning", c),
    bg = blend(get_group_color("states", "warning", c), get_group_color("backgrounds", "normal", c), 0.1),
    bold = config.styles.bold,
  }
  highlights["@comment.error"] = {
    fg = get_group_color("states", "error", c),
    bg = blend(get_group_color("states", "error", c), get_group_color("backgrounds", "normal", c), 0.1),
    bold = config.styles.bold,
  }

  -- LSP semantic tokens
  highlights["@lsp.type.comment"] = {}
  highlights["@lsp.type.comment.c"] = { link = "@comment" }
  highlights["@lsp.type.comment.cpp"] = { link = "@comment" }
  highlights["@lsp.type.enum"] = { link = "@type" }
  highlights["@lsp.type.interface"] = { link = "@type" }
  highlights["@lsp.type.keyword"] = { link = "@keyword" }
  highlights["@lsp.type.namespace"] = { link = "@module" }
  highlights["@lsp.type.namespace.python"] = { link = "@variable" }
  highlights["@lsp.type.parameter"] = { link = "@variable.parameter" }
  highlights["@lsp.type.property"] = { link = "@property" }
  highlights["@lsp.type.variable"] = {} -- defer to treesitter for regular variables
  highlights["@lsp.type.variable.svelte"] = { link = "@variable" }
  highlights["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" }
  highlights["@lsp.typemod.operator.injected"] = { link = "@operator" }
  highlights["@lsp.typemod.string.injected"] = { link = "@string" }
  highlights["@lsp.typemod.variable.constant"] = { link = "@constant" }
  highlights["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" }
  highlights["@lsp.typemod.variable.injected"] = { link = "@variable" }
end

return M
