local base16_pro_max = require("base16-pro-max")

-- Get the color palette
local colors = base16_pro_max.colors()

-- Handle case where colors might not be available
if not colors then
  vim.notify("base16-pro-max.nvim colors not available. Make sure setup() is called first.", vim.log.levels.WARN)
  return {}
end

-- Check if enabled plugin
if not base16_pro_max.has_plugin("nvim_lualine_lualine_nvim") then
  vim.notify(
    "base16-pro-max.nvim: Lualine plugin not enabled. Make sure to enable the plugin at `config.plugins.nvim_lualine_lualine_nvim`.",
    vim.log.levels.WARN
  )
  return {}
end

local function get_group_color(group, key)
  return base16_pro_max.get_group_color(group, key) or colors.fg
end

local function get_bg()
  if base16_pro_max.config and base16_pro_max.config.styles.transparency then
    return "NONE"
  end
  return get_group_color("backgrounds", "dim")
end

local bg_base = get_bg()

local theme_colors = {
  -- Mode-specific colors
  normal_accent = get_group_color("states", "info"), -- blue
  insert_accent = get_group_color("states", "success"), -- green
  visual_accent = get_group_color("states", "warning"), -- yellow
  replace_accent = get_group_color("states", "hint"), -- orange
  command_accent = get_group_color("states", "error"), -- red

  -- Background colors
  bg_normal = get_group_color("backgrounds", "normal"),
  bg_light = get_group_color("backgrounds", "light"),

  -- Foreground colors
  fg_normal = get_group_color("foregrounds", "normal"),
  fg_dim = get_group_color("foregrounds", "dim"),
}

return {
  normal = {
    a = { bg = theme_colors.normal_accent, fg = theme_colors.bg_normal, gui = "bold" },
    b = { bg = theme_colors.bg_light, fg = theme_colors.normal_accent },
    c = { bg = bg_base, fg = theme_colors.fg_normal },
  },
  insert = {
    a = { bg = theme_colors.insert_accent, fg = theme_colors.bg_normal, gui = "bold" },
    b = { bg = theme_colors.bg_light, fg = theme_colors.insert_accent },
    c = { bg = bg_base, fg = theme_colors.fg_normal },
  },
  visual = {
    a = { bg = theme_colors.visual_accent, fg = theme_colors.bg_normal, gui = "bold" },
    b = { bg = theme_colors.bg_light, fg = theme_colors.visual_accent },
    c = { bg = bg_base, fg = theme_colors.fg_normal },
  },
  replace = {
    a = { bg = theme_colors.replace_accent, fg = theme_colors.bg_normal, gui = "bold" },
    b = { bg = theme_colors.bg_light, fg = theme_colors.replace_accent },
    c = { bg = bg_base, fg = theme_colors.fg_normal },
  },
  command = {
    a = { bg = theme_colors.command_accent, fg = theme_colors.bg_normal, gui = "bold" },
    b = { bg = theme_colors.bg_light, fg = theme_colors.command_accent },
    c = { bg = bg_base, fg = theme_colors.fg_normal },
  },
  inactive = {
    a = { bg = bg_base, fg = theme_colors.fg_dim, gui = "bold" },
    b = { bg = bg_base, fg = theme_colors.fg_dim },
    c = { bg = bg_base, fg = theme_colors.fg_dim },
  },
}
