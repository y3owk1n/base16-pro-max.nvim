local M = {}

M.url = "https://github.com/y3owk1n/undo-glow.nvim"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.UgUndo = {
    bg = get_group_color("states", "error", c),
    blend = config.blends.strong,
  }
  highlights.UgRedo = {
    bg = get_group_color("states", "success", c),
    blend = config.blends.strong,
  }
  highlights.UgYank = {
    bg = get_group_color("syntax", "constant", c),
    blend = config.blends.strong,
  }
  highlights.UgPaste = {
    bg = get_group_color("syntax", "operator", c),
    blend = config.blends.strong,
  }
  highlights.UgSearch = {
    bg = get_group_color("states", "info", c),
    blend = config.blends.strong,
  }
  highlights.UgComment = {
    bg = get_group_color("syntax", "type", c),
    blend = config.blends.strong,
  }
  highlights.UgCursor = { bg = get_group_color("backgrounds", "light", c) }
end

return M
