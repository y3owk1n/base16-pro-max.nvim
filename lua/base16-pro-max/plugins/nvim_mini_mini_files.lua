local M = {}

M.url = "https://github.com/nvim-mini/mini.files"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local get_bg = function_refs.get_bg_fn
  local c = function_refs.colors

  highlights.MiniFilesBorder = { link = "FloatBorder" }
  highlights.MiniFilesBorderModified = {
    fg = get_group_color("states", "warning", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.MiniFilesCursorLine = { link = "CursorLine" }
  highlights.MiniFilesDirectory = { link = "Directory" }
  highlights.MiniFilesFile = { fg = get_group_color("foregrounds", "normal", c) }
  highlights.MiniFilesNormal = { link = "NormalFloat" }
  highlights.MiniFilesTitle = { link = "FloatTitle" }
end

return M
