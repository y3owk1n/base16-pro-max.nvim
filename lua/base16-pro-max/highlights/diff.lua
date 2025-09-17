local M = {}

---Setup diff highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color

  highlights.DiffAdd = { fg = get_group_color("diff", "added", c) }
  highlights.DiffChange = { fg = get_group_color("diff", "changed", c) }
  highlights.DiffDelete = { fg = get_group_color("diff", "removed", c) }
  highlights.DiffText = { fg = get_group_color("diff", "text", c) }
end

return M
