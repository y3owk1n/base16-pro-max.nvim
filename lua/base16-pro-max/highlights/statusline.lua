local M = {}

---Setup status and tab line highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local get_bg = require("base16-pro-max.lib.colors").get_bg
  local config = require("base16-pro-max").config

  -- Tabline
  highlights.TabLine = {
    fg = get_group_color("foregrounds", "dim", c),
    bg = get_bg(get_group_color("backgrounds", "dim", c)),
  }
  highlights.TabLineFill = { bg = get_bg(get_group_color("backgrounds", "dim", c)) }
  highlights.TabLineSel = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_group_color("backgrounds", "light", c),
    bold = config.styles.bold,
  }

  -- Statusline
  highlights.StatusLine = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_group_color("backgrounds", "dim", c),
  }
  highlights.StatusLineNC = {
    fg = get_group_color("foregrounds", "dark", c),
    bg = get_group_color("backgrounds", "dim", c),
  }
end

return M
