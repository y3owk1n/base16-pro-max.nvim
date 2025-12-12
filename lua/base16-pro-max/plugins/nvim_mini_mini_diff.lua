local M = {}

M.url = "https://github.com/nvim-mini/mini.diff"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.MiniDiffAdd = { link = "DiffAdd" }
  highlights.MiniDiffDelete = { link = "DiffDelete" }
  highlights.MiniDiffSignAdd = { link = "DiffAdd" }
  highlights.MiniDiffSignChange = { link = "DiffChange" }
  highlights.MiniDiffSignDelete = { link = "DiffDelete" }

  highlights.MiniDiffOverAdd = {
    fg = get_group_color("diff", "added", c),
    bg = get_group_color("diff", "added", c),
    blend = config.blends.medium,
  }
  highlights.MiniDiffOverChange = {
    fg = get_group_color("diff", "changed", c),
    bg = get_group_color("diff", "changed", c),
    blend = config.blends.medium,
  }
  highlights.MiniDiffOverChangeBuf = {
    fg = get_group_color("diff", "changed", c),
  }
  highlights.MiniDiffOverContext = {
    fg = get_group_color("foregrounds", "dark", c),
    bg = get_group_color("diff", "changed", c),
    blend = config.blends.medium,
  }
  highlights.MiniDiffOverContextBuf = {
    fg = get_group_color("foregrounds", "dark", c),
  }
  highlights.MiniDiffOverDelete = {
    fg = get_group_color("diff", "removed", c),
    bg = get_group_color("diff", "removed", c),
    blend = config.blends.medium,
  }
end

return M
