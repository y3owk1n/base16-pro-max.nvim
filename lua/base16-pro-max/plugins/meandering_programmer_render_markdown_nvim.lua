local M = {}

M.url = "https://github.com/MeanderingProgrammer/render-markdown.nvim"

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  for i = 1, 6 do
    highlights["RenderMarkdownH" .. i .. "Bg"] = {
      bg = get_group_color("markdown", "heading" .. i, c),
      blend = config.blends.medium,
    }
  end

  highlights.RenderMarkdownBullet = { fg = get_group_color("syntax", "constant", c) }
  highlights.RenderMarkdownChecked = { fg = get_group_color("syntax", "operator", c) }
  highlights.RenderMarkdownchecked = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.RenderMarkdownCode = { bg = get_group_color("backgrounds", "dim", c) }
  highlights.RenderMarkdownCodeInline = {
    bg = get_group_color("backgrounds", "dim", c),
    fg = get_group_color("foregrounds", "normal", c),
  }
  highlights.RenderMarkdownQuote = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.RenderMarkdownTableFill = { link = "Conceal" }
  highlights.RenderMarkdownTableHead = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.RenderMarkdownTableRow = { fg = get_group_color("foregrounds", "dim", c) }
end

return M
