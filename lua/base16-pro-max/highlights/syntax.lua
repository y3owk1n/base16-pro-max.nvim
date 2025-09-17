local M = {}

---Setup syntax highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local get_bg = require("base16-pro-max.lib.colors").get_bg
  local config = require("base16-pro-max").config

  -- Comments
  highlights.Comment = {
    fg = get_group_color("syntax", "comment", c),
    italic = config.styles.italic,
  }

  -- Constants
  highlights.Constant = { fg = get_group_color("syntax", "constant", c), bold = config.styles.bold }
  highlights.String = { fg = get_group_color("syntax", "string", c) }
  highlights.Character = { fg = get_group_color("syntax", "constant", c) }
  highlights.Number = { fg = get_group_color("syntax", "number", c) }
  highlights.Boolean = { fg = get_group_color("syntax", "boolean", c) }
  highlights.Float = { fg = get_group_color("syntax", "number", c) }

  -- Identifiers
  highlights.Identifier = { fg = get_group_color("syntax", "variable", c) }
  highlights.Function = {
    fg = get_group_color("syntax", "function_name", c),
    bold = config.styles.bold,
  }

  -- Keywords and statements
  highlights.Statement = { fg = get_group_color("syntax", "function_name", c) }
  highlights.Conditional = { fg = get_group_color("syntax", "keyword", c) }
  highlights.Repeat = { fg = get_group_color("syntax", "keyword", c) }
  highlights.Label = { fg = get_group_color("syntax", "operator", c) }
  highlights.Operator = { fg = get_group_color("syntax", "operator", c) }
  highlights.Keyword = {
    fg = get_group_color("syntax", "keyword", c),
    bold = config.styles.bold,
  }
  highlights.Exception = { fg = get_group_color("states", "error", c) }

  -- Preprocessor
  highlights.PreProc = { link = "PreCondit" }
  highlights.Include = { fg = get_group_color("syntax", "function_name", c), italic = config.styles.italic }
  highlights.Define = { fg = get_group_color("syntax", "keyword", c) }
  highlights.Macro = { fg = get_group_color("states", "error", c) }
  highlights.PreCondit = { fg = get_group_color("syntax", "keyword", c), italic = config.styles.italic }

  -- Types
  highlights.Type = {
    fg = get_group_color("syntax", "type", c),
    bold = config.styles.bold,
  }
  highlights.StorageClass = { fg = get_group_color("syntax", "type", c) }
  highlights.Structure = { fg = get_group_color("syntax", "operator", c) }
  highlights.Typedef = { link = "Type" }

  -- Specials
  highlights.Special = { fg = get_group_color("syntax", "operator", c) }
  highlights.SpecialChar = { link = "Special" }
  highlights.Tag = { fg = get_group_color("syntax", "operator", c) }
  highlights.Delimiter = { fg = get_group_color("syntax", "delimiter", c) }
  highlights.SpecialComment = { link = "Special" }
  highlights.Debug = { fg = get_group_color("states", "error", c) }

  -- Misc
  highlights.Underlined = { underline = true }
  highlights.Bold = { bold = config.styles.bold }
  highlights.Italic = { italic = config.styles.italic }
  highlights.Ignore = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.Error = {
    fg = get_group_color("states", "error", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.Todo = {
    fg = get_group_color("syntax", "type", c),
    bg = get_bg(get_group_color("backgrounds", "dim", c)),
  }

  -- Health check colors
  highlights.healthError = { fg = get_group_color("states", "error", c) }
  highlights.healthSuccess = { fg = get_group_color("states", "success", c) }
  highlights.healthWarning = { fg = get_group_color("states", "warning", c) }
end

return M
