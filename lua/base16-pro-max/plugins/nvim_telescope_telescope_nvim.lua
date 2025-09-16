local M = {}

M.url = "https://github.com/nvim-telescope/telescope.nvim"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local c = function_refs.colors

  highlights.TelescopeBorder = { link = "FloatBorder" }
  highlights.TelescopeNormal = { link = "NormalFloat" }
  highlights.TelescopePreviewNormal = { link = "TelescopeNormal" }
  highlights.TelescopePromptNormal = { link = "TelescopeNormal" }
  highlights.TelescopeResultsNormal = { link = "TelescopeNormal" }
  highlights.TelescopeTitle = { link = "FloatTitle" }
  highlights.TelescopeSelectionCaret = {
    fg = get_group_color("syntax", "constant", c),
    bg = get_group_color("backgrounds", "cursor_line", c),
  }
  highlights.TelescopeSelection = {
    link = "CursorLine",
  }
  highlights.TelescopeMatching = { fg = get_group_color("search", "match", c) }
  highlights.TelescopePromptPrefix = { fg = get_group_color("syntax", "constant", c) }

  highlights.TelescopePreviewTitle = {
    link = "FloatTitle",
  }
  highlights.TelescopePromptTitle = {
    link = "FloatTitle",
  }
  highlights.TelescopeResultsTitle = {
    link = "FloatTitle",
  }
end

return M
