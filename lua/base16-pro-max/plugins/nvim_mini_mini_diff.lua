local M = {}

M.url = "https://github.com/nvim-mini/mini.diff"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  highlights.MiniDiffAdd = { link = "DiffAdd" }
  highlights.MiniDiffChange = { link = "DiffChange" }
  highlights.MiniDiffDelete = { link = "DiffDelete" }
  highlights.MiniDiffSignAdd = { link = "DiffAdd" }
  highlights.MiniDiffSignChange = { link = "DiffChange" }
  highlights.MiniDiffSignDelete = { link = "DiffDelete" }
end

return M
