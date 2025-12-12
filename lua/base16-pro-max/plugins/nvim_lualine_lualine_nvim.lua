local M = {}

M.url = "https://github.com/nvim-lualine/lualine.nvim"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  -- No hl groups for Lualine
  -- Refer to `lua/lualine/themes/base16-pro-max.lua` for the setup
end

return M
