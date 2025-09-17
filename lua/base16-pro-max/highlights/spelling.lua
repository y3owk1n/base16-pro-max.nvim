local M = {}

---Setup spelling highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color

  highlights.SpellBad = { sp = get_group_color("states", "error", c), undercurl = true }
  highlights.SpellCap = { sp = get_group_color("states", "info", c), undercurl = true }
  highlights.SpellLocal = { sp = get_group_color("syntax", "operator", c), undercurl = true }
  highlights.SpellRare = { sp = get_group_color("states", "hint", c), undercurl = true }
end

return M
