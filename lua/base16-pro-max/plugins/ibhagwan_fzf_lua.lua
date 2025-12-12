local M = {}

M.url = "https://github.com/ibhagwan/fzf-lua"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local c = function_refs.colors

  highlights.FzfLuaNormal = { link = "NormalFloat" }
  highlights.FzfLuaBorder = { link = "FloatBorder" }
  highlights.FzfLuaTitle = { link = "FloatTitle" }
  highlights.FzfLuaHeaderBind = { fg = get_group_color("syntax", "type", c) }
  highlights.FzfLuaHeaderText = { fg = get_group_color("syntax", "constant", c) }
  highlights.FzfLuaFzfMatch = { fg = get_group_color("search", "match", c) }
  highlights.FzfLuaFzfPrompt = { fg = get_group_color("syntax", "constant", c) }
  highlights.FzfLuaPathColNr = { fg = get_group_color("states", "info", c) }
  highlights.FzfLuaPathLineNr = { fg = get_group_color("states", "success", c) }
  highlights.FzfLuaBufName = { fg = get_group_color("states", "hint", c) }
  highlights.FzfLuaBufNr = { fg = get_group_color("syntax", "type", c) }
  highlights.FzfLuaBufFlagCur = { fg = get_group_color("syntax", "constant", c) }
  highlights.FzfLuaBufFlagAlt = { fg = get_group_color("states", "info", c) }
  highlights.FzfLuaTabTitle = { fg = get_group_color("syntax", "operator", c) }
  highlights.FzfLuaTabMarker = { fg = get_group_color("syntax", "type", c) }
  highlights.FzfLuaLiveSym = { fg = get_group_color("syntax", "constant", c) }
end

return M
