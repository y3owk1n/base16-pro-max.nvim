local M = {}

M.url = "https://github.com/saghen/blink.cmp"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.BlinkCmpDoc = { link = "Normal" }
  highlights.BlinkCmpDocSeparator = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.BlinkCmpDocBorder = { link = "FloatBorder" }
  highlights.BlinkCmpSignatureHelp = { link = "Normal" }
  highlights.BlinkCmpSignatureHelpBorder = { link = "FloatBorder" }
  highlights.BlinkCmpSignatureHelpActiveParameter = { link = "Cursorline" }
  highlights.BlinkCmpGhostText = { link = "Comment" }
  highlights.BlinkCmpLabel = { link = "Comment" }
  highlights.BlinkCmpLabelDeprecated = { fg = get_group_color("syntax", "deprecated", c), strikethrough = true }
  highlights.BlinkCmpLabelMatch = {
    fg = get_group_color("foregrounds", "normal", c),
    bold = config.bold,
  }
  highlights.BlinkCmpDefault = { link = "Normal" }

  -- Completion item kinds with consistent semantic colors
  local cmp_kinds = {
    Text = "states.info",
    Method = "syntax.operator",
    Function = "syntax.operator",
    Constructor = "syntax.operator",
    Field = "states.info",
    Variable = "syntax.constant",
    Class = "syntax.type",
    Interface = "syntax.type",
    Module = "syntax.operator",
    Property = "syntax.operator",
    Unit = "states.info",
    Value = "states.error",
    Keyword = "syntax.keyword",
    Snippet = "syntax.constant",
    Color = "states.error",
    File = "syntax.operator",
    Reference = "states.error",
    Folder = "syntax.operator",
    Enum = "syntax.operator",
    EnumMember = "syntax.operator",
    Constant = "syntax.constant",
    Struct = "syntax.operator",
    Event = "syntax.operator",
    Operator = "syntax.operator",
    TypeParameter = "syntax.keyword",
  }

  for kind, color_path in pairs(cmp_kinds) do
    local group_name, color_name = color_path:match("([^.]+)%.([^.]+)")
    highlights["BlinkCmpKind" .. kind] = {
      fg = get_group_color(group_name, color_name, c),
    }
  end

  highlights.BlinkCmpMenuBorder = { link = "FloatBorder" }
end

return M
