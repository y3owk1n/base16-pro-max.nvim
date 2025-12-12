local M = {}

M.url = "https://github.com/folke/flash.nvim"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local c = function_refs.colors

  highlights.FlashLabel = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("states", "error", c),
  }
end

return M
