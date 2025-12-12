local M = {}

---Setup float highlights
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local get_bg = require("base16-pro-max.lib.colors").get_bg
  local config = require("base16-pro-max.config").config

  highlights.FloatBorder = {
    fg = get_group_color("foregrounds", "border", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.FloatShadow = { bg = get_group_color("backgrounds", "light", c) }
  highlights.FloatTitle = {
    fg = get_group_color("syntax", "operator", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
    bold = config.styles.bold,
    italic = config.styles.italic,
  }
  highlights.FloatShadowThrough = { link = "FloatShadow" }
  highlights.WildMenu = { link = "IncSearch" }
  highlights.Directory = {
    fg = get_group_color("syntax", "operator", c),
    bold = config.styles.bold,
  }
  highlights.Title = {
    fg = get_group_color("syntax", "operator", c),
    bold = config.styles.bold,
  }
end

return M
