local M = {}

---Setup lsp highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color

  highlights.LspReferenceText = { bg = get_group_color("backgrounds", "light", c) }
  highlights.LspReferenceRead = { bg = get_group_color("backgrounds", "light", c) }
  highlights.LspReferenceWrite = { bg = get_group_color("backgrounds", "light", c) }
end

return M
