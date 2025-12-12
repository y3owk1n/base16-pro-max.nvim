local M = {}

M.url = "https://github.com/folke/which-key.nvim"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.WhichKey = {
    fg = get_group_color("states", "info", c),
    bold = config.bold,
  }
  highlights.WhichKeyBorder = { link = "FloatBorder" }
  highlights.WhichKeyDesc = { fg = get_group_color("foregrounds", "normal", c) }
  highlights.WhichKeyFloat = { link = "NormalFloat" }
  highlights.WhichKeyGroup = {
    fg = get_group_color("states", "hint", c),
    bold = config.bold,
  }
  highlights.WhichKeyIcon = { fg = get_group_color("states", "info", c) }

  highlights.WhichKeyIconAzure = { link = "MiniIconsAzure" }
  highlights.WhichKeyIconBlue = { link = "MiniIconsBlue" }
  highlights.WhichKeyIconCyan = { link = "MiniIconsCyan" }
  highlights.WhichKeyIconGreen = { link = "MiniIconsGreen" }
  highlights.WhichKeyIconGrey = { link = "MiniIconsGrey" }
  highlights.WhichKeyIconOrange = { link = "MiniIconsOrange" }
  highlights.WhichKeyIconPurple = { link = "MiniIconsPurple" }
  highlights.WhichKeyIconRed = { link = "MiniIconsRed" }
  highlights.WhichKeyIconYellow = { link = "MiniIconsYellow" }

  highlights.WhichKeyNormal = { link = "Normal" }
  highlights.WhichKeySeparator = { fg = get_group_color("foregrounds", "dim", c) }
  highlights.WhichKeyTitle = { link = "FloatTitle" }
  highlights.WhichKeyValue = { fg = get_group_color("syntax", "constant", c) }
end

return M
