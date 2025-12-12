local M = {}

M.url = "https://github.com/MagicDuck/grug-far.nvim"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  highlights.GrugFarResultsMatch = { link = "IncSearch" }
end

return M
