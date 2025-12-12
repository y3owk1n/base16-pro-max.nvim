local M = {}

M.url = "https://github.com/nvim-mini/mini.icons"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local c = function_refs.colors

  highlights.MiniIconsAzure = { fg = get_group_color("syntax", "operator", c) }
  highlights.MiniIconsBlue = { fg = get_group_color("states", "info", c) }
  highlights.MiniIconsCyan = { fg = get_group_color("syntax", "operator", c) }
  highlights.MiniIconsGreen = { fg = get_group_color("states", "success", c) }
  highlights.MiniIconsGrey = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.MiniIconsOrange = { fg = get_group_color("states", "warning", c) }
  highlights.MiniIconsPurple = { fg = get_group_color("states", "hint", c) }
  highlights.MiniIconsRed = { fg = get_group_color("states", "error", c) }
  highlights.MiniIconsYellow = { fg = get_group_color("syntax", "type", c) }
end

return M
