local M = {}

---Setup diagnostic highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local config = require("base16-pro-max").config

  -- Diagnostic messages
  highlights.DiagnosticError = {
    fg = get_group_color("states", "error", c),
    bold = config.styles.bold,
  }
  highlights.DiagnosticWarn = {
    fg = get_group_color("states", "warning", c),
    bold = config.styles.bold,
  }
  highlights.DiagnosticInfo = {
    fg = get_group_color("states", "info", c),
    bold = config.styles.bold,
  }
  highlights.DiagnosticHint = {
    fg = get_group_color("states", "hint", c),
    bold = config.styles.bold,
  }
  highlights.DiagnosticDeprecated = {
    fg = get_group_color("foregrounds", "deprecated", c),
    strikethrough = true,
  }

  -- Diagnostic floating
  highlights.DiagnosticFloatingError = {
    link = "DiagnosticError",
  }
  highlights.DiagnosticFloatingWarn = {
    link = "DiagnosticWarn",
  }
  highlights.DiagnosticFloatingInfo = {
    link = "DiagnosticInfo",
  }
  highlights.DiagnosticFloatingHint = {
    link = "DiagnosticHint",
  }
  highlights.DiagnosticFloatingOk = {
    link = "DiagnosticOk",
  }

  -- Diagnostic sign
  highlights.DiagnosticSignError = {
    link = "DiagnosticError",
  }
  highlights.DiagnosticSignWarn = {
    link = "DiagnosticWarn",
  }
  highlights.DiagnosticSignInfo = {
    link = "DiagnosticInfo",
  }
  highlights.DiagnosticSignHint = {
    link = "DiagnosticHint",
  }
  highlights.DiagnosticSignOk = {
    link = "DiagnosticOk",
  }

  -- Diagnostic underlines
  highlights.DiagnosticUnderlineError = {
    sp = get_group_color("states", "error", c),
    undercurl = true,
  }
  highlights.DiagnosticUnderlineWarn = {
    sp = get_group_color("states", "warning", c),
    undercurl = true,
  }
  highlights.DiagnosticUnderlineInfo = {
    sp = get_group_color("states", "info", c),
    undercurl = true,
  }
  highlights.DiagnosticUnderlineHint = {
    sp = get_group_color("states", "hint", c),
    undercurl = true,
  }

  -- Diagnostic virtual text
  highlights.DiagnosticVirtualTextError = {
    fg = get_group_color("states", "error", c),
    bg = get_group_color("states", "error", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextWarn = {
    fg = get_group_color("states", "warning", c),
    bg = get_group_color("states", "warning", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextInfo = {
    fg = get_group_color("states", "info", c),
    bg = get_group_color("states", "info", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextHint = {
    fg = get_group_color("states", "hint", c),
    bg = get_group_color("states", "hint", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextOk = {
    fg = get_group_color("states", "success", c),
    bg = get_group_color("states", "success", c),
    blend = config.styles.blends.subtle,
  }

  -- Diagnostic virtual line
  highlights.DiagnosticVirtualLinesError = {
    fg = get_group_color("states", "error", c),
    bg = get_group_color("states", "error", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesWarn = {
    fg = get_group_color("states", "warning", c),
    bg = get_group_color("states", "warning", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesInfo = {
    fg = get_group_color("states", "info", c),
    bg = get_group_color("states", "info", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesHint = {
    fg = get_group_color("states", "hint", c),
    bg = get_group_color("states", "hint", c),
    blend = config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesOk = {
    fg = get_group_color("states", "success", c),
    bg = get_group_color("states", "success", c),
    blend = config.styles.blends.subtle,
  }
end

return M
