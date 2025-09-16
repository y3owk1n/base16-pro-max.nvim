local M = {}

M.url = "https://github.com/MagicDuck/grug-far.nvim"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local c = function_refs.colors

  highlights.GrugFarHelpHeader = { fg = get_group_color("states", "info", c) }
  highlights.GrugFarHelpHeaderKey = { fg = get_group_color("syntax", "constant", c) }
  highlights.GrugFarHelpWinActionKey = { fg = get_group_color("syntax", "constant", c) }
  highlights.GrugFarHelpWinActionPrefix = { fg = get_group_color("syntax", "operator", c) }
  highlights.GrugFarHelpWinActionText = { fg = get_group_color("states", "info", c) }
  highlights.GrugFarHelpWinHeader = { link = "FloatTitle" }
  highlights.GrugFarInputLabel = { fg = get_group_color("syntax", "operator", c) }
  highlights.GrugFarInputPlaceholder = { link = "Comment" }
  highlights.GrugFarResultsActionMessage = { fg = get_group_color("syntax", "operator", c) }
  highlights.GrugFarResultsChangeIndicator = { fg = get_group_color("diff", "changed", c) }
  highlights.GrugFarResultsRemoveIndicator = { fg = get_group_color("diff", "removed", c) }
  highlights.GrugFarResultsAddIndicator = { fg = get_group_color("diff", "added", c) }
  highlights.GrugFarResultsHeader = { fg = get_group_color("states", "info", c) }
  highlights.GrugFarResultsLineNo = { fg = get_group_color("states", "hint", c) }
  highlights.GrugFarResultsLineColumn = { link = "GrugFarResultsLineNo" }
  highlights.GrugFarResultsMatch = { link = "IncSearch" }
  highlights.GrugFarResultsPath = { fg = get_group_color("syntax", "operator", c) }
  highlights.GrugFarResultsStats = { fg = get_group_color("states", "hint", c) }
end

return M
