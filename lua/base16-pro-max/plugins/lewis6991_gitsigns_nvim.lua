local M = {}

M.url = "https://github.com/lewis6991/gitsigns.nvim"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local c = function_refs.colors

  highlights.GitSignsAdd = { fg = get_group_color("git", "added", c) }
  highlights.GitSignsChange = { fg = get_group_color("git", "changed", c) }
  highlights.GitSignsDelete = { fg = get_group_color("git", "removed", c) }
  highlights.GitSignsUntracked = { fg = get_group_color("git", "untracked", c) }

  highlights.GitSignsAddLn = { link = "GitSignsAdd" }
  highlights.GitSignsChangeLn = { link = "GitSignsChange" }
  highlights.GitSignsDeleteLn = { link = "GitSignsDelete" }
  highlights.GitSignsUntrackedLn = { link = "GitSignsUntracked" }

  highlights.GitSignsAddInline = { link = "GitSignsAdd" }
  highlights.GitSignsChangeInline = { link = "GitSignsChange" }
  highlights.GitSignsDeleteInline = { link = "GitSignsDelete" }
  highlights.GitSignsUntrackedInline = { link = "GitSignsUntracked" }
end

return M
