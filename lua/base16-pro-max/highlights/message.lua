local M = {}

---Setup message highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local config = require("base16-pro-max.config").config

  highlights.ErrorMsg = {
    fg = get_group_color("states", "error", c),
    bold = config.styles.bold,
  }
  highlights.WarningMsg = {
    fg = get_group_color("states", "warning", c),
    bold = config.styles.bold,
  }
  highlights.MoreMsg = { fg = get_group_color("states", "success", c) }
  highlights.ModeMsg = { fg = get_group_color("states", "success", c) }
  highlights.Question = { fg = get_group_color("states", "info", c) }
  highlights.NvimInternalError = { link = "ErrorMsg" }
end

return M
