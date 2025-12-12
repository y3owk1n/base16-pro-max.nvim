local M = {}

---Setup editor highlights (UI elements)
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local get_bg = require("base16-pro-max.lib.colors").get_bg
  local config = require("base16-pro-max.config").config

  -- Normal and floating windows
  highlights.Normal = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.NormalFloat = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.NormalNC = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = config.styles.dim_inactive_windows and get_group_color("backgrounds", "dim", c)
      or get_bg(get_group_color("backgrounds", "normal", c)),
    blend = config.styles.dim_inactive_windows and config.styles.blends.super or nil,
  }
  highlights.NormalSB = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_group_color("backgrounds", "normal", c),
  }

  -- Cursor and lines
  highlights.Cursor = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("foregrounds", "normal", c),
    bold = config.styles.bold,
  }
  highlights.lCursor = { link = "Cursor" }
  highlights.CursorIM = { link = "Cursor" }
  highlights.CursorLine = { bg = get_group_color("backgrounds", "cursor_line", c) }
  highlights.CursorColumn = { bg = get_bg(get_group_color("backgrounds", "cursor_column", c)) }
  highlights.CursorLineNr = {
    fg = get_group_color("syntax", "constant", c),
    bg = get_bg(get_group_color("backgrounds", "cursor_line", c)),
    bold = config.styles.bold,
  }
  highlights.LineNr = { fg = get_group_color("foregrounds", "line_number", c) }
  highlights.SignColumn = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.SignColumnSB = {
    fg = get_group_color("foregrounds", "dim", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.ColorColumn = { bg = get_bg(get_group_color("backgrounds", "dim", c)) }

  -- Window separators
  highlights.VertSplit = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.WinSeparator = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.WinBar = {
    fg = get_group_color("foregrounds", "dark", c),
    bg = get_bg(get_group_color("backgrounds", "light", c)),
  }
  highlights.WinBarNC = {
    fg = get_group_color("foregrounds", "dim", c),
    bg = get_bg(get_group_color("backgrounds", "dim", c)),
  }

  -- Folding and concealing
  highlights.Folded = {
    fg = get_group_color("foregrounds", "dim", c),
    bg = get_bg(get_group_color("backgrounds", "dim", c)),
  }
  highlights.FoldColumn = {
    fg = get_group_color("foregrounds", "dim", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.Conceal = { fg = get_group_color("foregrounds", "dim", c) }

  -- Visual selection
  highlights.Visual = { bg = get_group_color("backgrounds", "selection", c) }
  highlights.VisualNOS = { link = "Visual" }
  highlights.MatchParen = {
    bg = get_group_color("backgrounds", "selection", c),
    bold = config.styles.bold,
  }

  -- Search
  highlights.Search = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("search", "match", c),
    bold = config.styles.bold,
  }
  highlights.CurSearch = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("search", "current", c),
    bold = config.styles.bold,
  }
  highlights.IncSearch = { link = "CurSearch" }
  highlights.Substitute = { link = "IncSearch" }
end

return M
