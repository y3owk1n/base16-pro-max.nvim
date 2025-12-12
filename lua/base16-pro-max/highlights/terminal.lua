local M = {}

---Setup lsp highlights
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local get_bg = require("base16-pro-max.lib.colors").get_bg

  highlights.Terminal = {
    fg = get_group_color("foregrounds", "normal", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.TermCursor = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("states", "success", c),
  }
  highlights.TermCursorNC = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("foregrounds", "dim", c),
  }
end

return M
