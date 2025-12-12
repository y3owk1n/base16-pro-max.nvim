local M = {}

M.url = "https://github.com/echasnovski/mini.statusline"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.MiniStatuslineDevinfo = { fg = get_group_color("foregrounds", "dark", c) }
  highlights.MiniStatuslineFileinfo = { fg = get_group_color("foregrounds", "dark", c) }
  highlights.MiniStatuslineFilename = {
    fg = get_group_color("modes", "normal", c),
  }
  highlights.MiniStatuslineInactive = { link = "StatuslineNC" }
  highlights.MiniStatuslineModeNormal = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("modes", "normal", c),
    bold = config.bold,
  }
  highlights.MiniStatuslineModeInsert = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("modes", "insert", c),
    bold = config.bold,
  }
  highlights.MiniStatuslineModeVisual = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("modes", "visual", c),
    bold = config.bold,
  }
  highlights.MiniStatuslineModeReplace = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("modes", "replace", c),
    bold = config.bold,
  }
  highlights.MiniStatuslineModeCommand = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("modes", "command", c),
    bold = config.bold,
  }
  highlights.MiniStatuslineModeOther = {
    fg = get_group_color("backgrounds", "normal", c),
    bg = get_group_color("modes", "other", c),
    bold = config.bold,
  }
end

return M
