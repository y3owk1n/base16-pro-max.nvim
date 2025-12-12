local M = {}

---Setup popup menu highlights
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local get_bg = require("base16-pro-max.lib.colors").get_bg
  local blend = require("base16-pro-max.utils.colors-manipulation").blend
  local config = require("base16-pro-max.config").config

  highlights.Pmenu = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.PmenuSel = {
    bg = get_group_color("backgrounds", "selection", c),
    bold = config.styles.bold,
  }
  highlights.PmenuSbar = { bg = get_group_color("backgrounds", "light", c) }
  highlights.PmenuThumb = { bg = get_group_color("foregrounds", "dark", c) }
  highlights.PmenuKind = {
    fg = get_group_color("syntax", "keyword", c),
    bold = config.styles.bold,
  }
  highlights.PmenuKindSel = {
    fg = get_group_color("syntax", "keyword", c),
    bg = blend(get_group_color("syntax", "function_name", c), get_group_color("backgrounds", "normal", c), 0.3),
    bold = config.styles.bold,
  }
  highlights.PmenuExtra = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.PmenuExtraSel = {
    fg = get_group_color("foregrounds", "dim", c),
    bg = blend(get_group_color("syntax", "function_name", c), get_group_color("backgrounds", "normal", c), 0.3),
  }
end

return M
