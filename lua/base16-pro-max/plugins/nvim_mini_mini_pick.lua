local M = {}

M.url = "https://github.com/nvim-mini/mini.pick"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local get_bg = function_refs.get_bg_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.MiniPickBorder = { link = "FloatBorder" }
  highlights.MiniPickBorderBusy = {
    fg = get_group_color("states", "warning", c),
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
  }
  highlights.MiniPickBorderText = { link = "FloatTitle" }
  highlights.MiniPickCursor = { link = "CursorLine" }
  highlights.MiniPickIconDirectory = { link = "Directory" }
  highlights.MiniPickIconFile = { link = "MiniPickNormal" }
  highlights.MiniPickHeader = {
    fg = get_group_color("markdown", "heading1", c),
    bg = get_group_color("markdown", "heading1", c),
    blend = config.blends.medium,
  }
  highlights.MiniPickMatchCurrent = { link = "CursorLine" }
  highlights.MiniPickMatchMarked = { link = "Visual" }
  highlights.MiniPickMatchRanges = { fg = get_group_color("search", "match", c) }
  highlights.MiniPickNormal = { link = "NormalFloat" }
  highlights.MiniPickPreviewLine = { link = "CursorLine" }
  highlights.MiniPickPreviewRegion = { link = "IncSearch" }
  highlights.MiniPickPrompt = {
    bg = get_bg(get_group_color("backgrounds", "normal", c)),
    bold = config.bold,
  }
end

return M
