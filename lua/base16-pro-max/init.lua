---@module "base16-pro-max"

---@brief [[
---*base16-pro-max.nvim* Base16 for modern Neovim — not just colors.
---
---base16-pro-max.nvim is a highly configurable colorscheme engine for Neovim that
---aims to not only covers base16 colorschemes, but also include features
---that are built-in to most colorscheme plugins (e.g. dim_inactive_windows,
---blends, italics, custom highlights, etc.)
---
---It allows defining a semantic color palette, generating highlight
---groups automatically, and integrating with popular plugins.
---
---# Features ~
--- - Complete Base16 Implementation: Full support for the Base16 specification with semantic aliases
--- - Modern Styling Options: Transparency, italics, bold text, window dimming, and blend modes
--- - Extensive Plugin Support: Native integrations for popular Neovim plugins
--- - Semantic Color Groups: Intuitive color organization for backgrounds, syntax, states, diff, and search
--- - Runtime Validation: Comprehensive configuration validation with helpful error messages
--- - Performance Optimized: Efficient caching and minimal runtime overhead
--- - Highly Customizable: Override any aspect through configuration or runtime functions
---
---# Setup ~
---
---This module needs to be set up with `require('base16-pro-max').setup({})` (replace
---`{}` with your `config` table).
---
---see also |base16-pro-max.setup|
---
---# Quick Start ~
---
--->lua
---   -- Minimal setup with Kanagawa-inspired colors
---   {
---     "y3owk1n/base16-pro-max.nvim",
---     priority = 1000,
---     config = function()
---       require("base16-pro-max").setup {
---         colors = {
---           base00 = "#1f1f28", base01 = "#2a2a37", base02 = "#3a3a4e",
---           base03 = "#4e4e5e", base04 = "#9e9eaf", base05 = "#c5c5da",
---           base06 = "#dfdfef", base07 = "#e6e6f0", base08 = "#ff5f87",
---           base09 = "#ff8700", base0A = "#ffaf00", base0B = "#5fff87",
---           base0C = "#5fd7ff", base0D = "#5fafff", base0E = "#af87ff",
---           base0F = "#d7875f",
---         },
---         styles = { italic = true, transparency = true },
---         plugins = { enable_all = true },
---       }
---       vim.cmd.colorscheme "base16-pro-max"
---     end,
---   }
---<
---
---@brief ]]

---@toc base16-pro-max.contents

local M = {}

local did_setup = false

-- ------------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------------

---@mod base16-pro-max.setup Setup

---@brief [[
---# Module setup ~
---
---Note that `colors` in the config table is compulsary and must be provided.
---
--->lua
---   require('base16').setup({}) -- replace {} with your config table
---<
---
---# Configuration Anotomy ~
---
---All boolean options are `false` and opt-in by default.
---
--- - `colors`: **Required** - the 16 Base 16 hex codes
--- - `highlight_groups`: **Optional** - additional highlight groups to set
--- - `before_highlight`: **Optional** - callback to run before setting highlight groups
--- - `styles`: **Optional** - styling options
--- - `plugins`: **Optional** - enable/disable plugins
--- - `setup_globals`: **Optional** - setup vim.g globals
--- - `color_groups`: **Optional** - semantic color groups
---
---# Colors Table ~
---
---The `colors` table is a mapping of Base16 colors to hex values. The plugin will
---automatically validate that all required colors are provided.
---
--->lua
---   {
---     base00 = "#000000", -- Default background
---     base01 = "#000000", -- Lighter background (status bars)
---     base02 = "#000000", -- Selection background
---     base03 = "#000000", -- Comments, line highlighting
---     base04 = "#000000", -- Dark foreground (status bars)
---     base05 = "#000000", -- Default foreground
---     base06 = "#000000", -- Light foreground
---     base07 = "#000000", -- Lightest foreground
---     base08 = "#000000", -- Red (variables, errors)
---     base09 = "#000000", -- Orange (integers, constants)
---     base0A = "#000000", -- Yellow (classes, search)
---     base0B = "#000000", -- Green (strings, success)
---     base0C = "#000000", -- Cyan (support, regex)
---     base0D = "#000000", -- Blue (functions, info)
---     base0E = "#000000", -- Purple (keywords, changes)
---     base0F = "#000000", -- Brown (deprecated)
---   }
---<
---
---# Semantic Alias Mapping ~
---
--- - base00 <-> bg
--- - base01 <-> bg_dim
--- - base02 <-> bg_light
--- - base03 <-> fg_dim
--- - base04 <-> fg_dark
--- - base05 <-> fg
--- - base06 <-> fg_light
--- - base07 <-> fg_bright
--- - base08 <-> red
--- - base09 <-> orange
--- - base0A <-> yellow
--- - base0B <-> green
--- - base0C <-> cyan
--- - base0D <-> blue
--- - base0E <-> purple
--- - base0F <-> brown
---
---# Default Configuration ~
---
--->lua
---   {
---     colors = {}, -- add this with your colors
---     highlight_groups = {},
---     before_highlight = nil,
---     styles = {
---       italic = false,
---       bold = false,
---       transparency = false,
---       use_cterm = false,
---       dim_inactive_windows = false,
---       blends = {
---         subtle = 10,
---         medium = 15,
---         strong = 25,
---         super = 50,
---       },
---     },
---     plugins = {
---       enable_all = false,
---     },
---     setup_globals = {
---       terminal_colors = false, -- set vim.g.terminal_color_* variables
---       base16_gui_colors = false, -- set vim.g.base16_gui* variables
---     },
---     color_groups = {
---       -- Background variations
---       backgrounds = {
---         normal = "bg",
---         dim = "bg_dim",
---         light = "bg_light",
---         selection = "bg_light",
---         cursor_line = function(function_refs)
---           return function_refs.blend_fn(function_refs.colors.bg_light, function_refs.colors.bg, 0.6)
---         end,
---         cursor_column = function(function_refs)
---           return function_refs.blend_fn(function_refs.colors.bg_dim, function_refs.colors.bg, 0.3)
---         end,
---       },
---
---       -- Foreground variations
---       foregrounds = {
---         normal = "fg",
---         dim = "fg_dim",
---         dark = "fg_dark",
---         light = "fg_light",
---         bright = "fg_bright",
---         comment = "fg_dark",
---         line_number = function(function_refs)
---           return function_refs.blend_fn(function_refs.colors.fg_dim, function_refs.colors.bg, 0.7)
---         end,
---         border = "fg_dim",
---       },
---
---       -- Semantic colors for syntax
---       syntax = {
---         variable = "fg",
---         constant = "orange",
---         string = "green",
---         number = "orange",
---         boolean = "orange",
---         keyword = "purple",
---         function_name = "blue",
---         type = "yellow",
---         comment = "fg_dark",
---         operator = "cyan",
---         delimiter = "fg_dark",
---         deprecated = "brown",
---       },
---
---       -- UI state colors
---       states = {
---         error = "red",
---         warning = "yellow",
---         info = "blue",
---         hint = "cyan",
---         success = "green",
---       },
---
---       -- Diff colors
---       diff = {
---         added = "green",
---         removed = "red",
---         changed = "orange",
---         text = "blue",
---       },
---
---       -- Git colors
---       git = {
---         added = "green",
---         removed = "red",
---         changed = "orange",
---         untracked = "brown",
---       },
---
---       -- Search and selection
---       search = {
---         match = "yellow",
---         current = "orange",
---         incremental = "orange",
---       },
---
---       -- Markdown
---       markdown = {
---         heading1 = "red",
---         heading2 = "orange",
---         heading3 = "yellow",
---         heading4 = "green",
---         heading5 = "cyan",
---         heading6 = "blue",
---       },
---
---       -- Modes
---       modes = {
---         normal = "blue",
---         insert = "green",
---         visual = "yellow",
---         visual_line = "yellow",
---         replace = "cyan",
---         command = "red",
---       },
---     },
---   }
---<
---
---@brief ]]

---Setup the base16-pro-max.nvim plugin
---@param user_config? Base16ProMax.Config
---@return nil
---@usage [[
---require("base16-pro-max").setup({
---  colors = { base00 = "#1f1f28", base01 = "#2a2a37", ... }
---})
---@usage ]]
function M.setup(user_config)
  if did_setup then
    return
  end

  require("base16-pro-max.lib.base16").get_base16_aliases() -- Ensure base16 aliases are loaded
  require("base16-pro-max.lib.base16").get_base16_raw() -- Ensure base16 raw colors are loaded

  local validator = require("base16-pro-max.validator")

  local valid, errors, warnings = validator.validate_config(user_config or {})

  if warnings and next(warnings) then
    local warning_msg = validator.format_errors({}, warnings)
    vim.notify(warning_msg, vim.log.levels.WARN)
  end

  if not valid then
    local error_msg = validator.format_errors(errors, {})

    -- Show detailed error message
    vim.notify("base16-pro-max.nvim setup failed:\n" .. error_msg, vim.log.levels.ERROR)

    -- Don't proceed with invalid configuration
    error("base16-pro-max.nvim: Invalid configuration. See above for details.")
  end

  local config = require("base16-pro-max.config")

  config.setup(user_config)

  -- Additional runtime validation that can only be done after merging
  local runtime_errors = {}

  -- Validate that colors are provided
  if not next(config.config.colors) then
    runtime_errors["colors"] = "No colors provided. At least base00-base0F are required."
  end

  -- Validate color group functions at runtime (if possible)
  if config.config.color_groups then
    local test_colors = require("base16-pro-max.lib.colors").add_semantic_palette(config.config.colors or {})

    for group_name, group_config in pairs(config.config.color_groups) do
      if type(group_config) == "table" then
        for key, color_value in pairs(group_config) do
          if type(color_value) == "function" then
            local function_refs = {
              blend_fn = require("base16-pro-max.utils.colors-manipulation").blend,
              colors = test_colors,
            }
            local success, result = pcall(color_value, function_refs)
            if not success then
              runtime_errors["color_groups." .. group_name .. "." .. key] = "Function failed: " .. tostring(result)
            elseif type(result) ~= "string" then
              runtime_errors["color_groups." .. group_name .. "." .. key] = "Function must return a string, got "
                .. type(result)
            end
          end
        end
      end
    end
  end

  -- Show runtime errors if any
  if next(runtime_errors) then
    local error_msg = validator.format_errors(runtime_errors, {})
    vim.notify("base16-pro-max.nvim runtime validation failed:\n" .. error_msg, vim.log.levels.ERROR)
    error("base16-pro-max.nvim: Runtime validation failed. See above for details.")
  end

  if config.config.setup_globals.terminal_colors then
    vim.g.terminal_color_0 = config.config.colors.base00
    vim.g.terminal_color_1 = config.config.colors.base08
    vim.g.terminal_color_2 = config.config.colors.base0B
    vim.g.terminal_color_3 = config.config.colors.base0A
    vim.g.terminal_color_4 = config.config.colors.base0D
    vim.g.terminal_color_5 = config.config.colors.base0E
    vim.g.terminal_color_6 = config.config.colors.base0C
    vim.g.terminal_color_7 = config.config.colors.base05
    vim.g.terminal_color_8 = config.config.colors.base03
    vim.g.terminal_color_9 = config.config.colors.base09
    vim.g.terminal_color_10 = config.config.colors.base01
    vim.g.terminal_color_11 = config.config.colors.base02
    vim.g.terminal_color_12 = config.config.colors.base04
    vim.g.terminal_color_13 = config.config.colors.base06
    vim.g.terminal_color_14 = config.config.colors.base0F
    vim.g.terminal_color_15 = config.config.colors.base07
  end

  if config.config.setup_globals.base16_gui_colors then
    vim.g.base16_gui00 = config.config.colors.base00
    vim.g.base16_gui01 = config.config.colors.base01
    vim.g.base16_gui02 = config.config.colors.base02
    vim.g.base16_gui03 = config.config.colors.base03
    vim.g.base16_gui04 = config.config.colors.base04
    vim.g.base16_gui05 = config.config.colors.base05
    vim.g.base16_gui06 = config.config.colors.base06
    vim.g.base16_gui07 = config.config.colors.base07
    vim.g.base16_gui08 = config.config.colors.base08
    vim.g.base16_gui09 = config.config.colors.base09
    vim.g.base16_gui0A = config.config.colors.base0A
    vim.g.base16_gui0B = config.config.colors.base0B
    vim.g.base16_gui0C = config.config.colors.base0C
    vim.g.base16_gui0D = config.config.colors.base0D
    vim.g.base16_gui0E = config.config.colors.base0E
    vim.g.base16_gui0F = config.config.colors.base0F
  end

  did_setup = true

  M._invalidate_cache()
end

---@mod base16-pro-max.api API

---@private
---Setup the colorscheme
---@usage [[
---vim.cmd.colorscheme("base16-pro-max")
---@usage ]]
function M.colorscheme()
  -- Clear existing highlights
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  -- Apply highlights
  require("base16-pro-max.lib.highlights").apply_highlights()
end

---@private
---Re-apply highlights (for benchmarking only)
function M._reapply_highlights()
  require("base16-pro-max.lib.highlights").apply_highlights()
end

---Get the semantic color palette
---@return table<Base16ProMax.Group.Alias, string>|nil colors The semantic color palette, or nil if not set up
function M.colors()
  if not did_setup then
    vim.notify("base16-pro-max.nvim: Plugin not set up. Call setup() first.", vim.log.levels.ERROR)
    return nil
  end

  local config = require("base16-pro-max.config").config

  if not config.colors then
    vim.notify("base16-pro-max.nvim: No colors configured.", vim.log.levels.ERROR)
    return nil
  end

  local semantic_colors = require("base16-pro-max.lib.colors").get_semantic_colors()

  return semantic_colors
end

---Get a specific color by name
---@param name Base16ProMax.Group.Alias|Base16ProMax.Group.Raw Color name (e.g., "red", "bg", "base08")
---@return string|nil color The hex color value, or nil if not found
function M.get_color(name)
  local colors = M.colors()
  if not colors then
    return nil
  end
  return colors[name]
end

---Get multiple colors at once
---@param names Base16ProMax.Group.Alias[]|Base16ProMax.Group.Raw[] Array of color names
---@return table<string, string> colors Map of color names to hex values
function M.get_colors(names)
  local colors = M.colors()
  local result = {}

  if not colors then
    return result
  end

  for _, name in ipairs(names) do
    local color = colors[name]
    if color then
      result[name] = color
    end
  end

  return result
end

---Get all raw base16 colors
---@return table<Base16ProMax.Group.Raw, string>|nil colors The raw base16 colors, or nil if not set up
function M.raw_colors()
  local config = require("base16-pro-max.config").config

  if not did_setup or not config.colors then
    return nil
  end

  -- Return a copy to prevent modification
  local raw = {}
  for k, v in pairs(config.colors) do
    raw[k] = v
  end
  return raw
end

---Get semantic color mapping
---@return table<Base16ProMax.Group.Alias, Base16ProMax.Group.Raw> mapping The semantic to raw color mapping
function M.color_mapping()
  return vim.deepcopy(require("base16-pro-max.lib.base16").base16_alias_map)
end

---Get a color from groups
---@param group string The color group name
---@param key string The color key within the group
---@return string|nil color The resolved color, or nil if not found
function M.get_group_color(group, key)
  local colors = M.colors()
  if not colors then
    return nil
  end
  return require("base16-pro-max.lib.colors").get_group_color(group, key, colors)
end

---Invalidate the color cache (useful when colors are updated)
---@private
function M._invalidate_cache()
  if not did_setup then
    return
  end

  local cterm = require("base16-pro-max.utils.cterm")
  local manipulation = require("base16-pro-max.utils.colors-manipulation")
  local highlights = require("base16-pro-max.lib.highlights")
  local colors = require("base16-pro-max.lib.colors")

  cterm._invalidate_cache()
  manipulation._invalidate_cache()
  highlights._invalidate_cache()
  colors._invalidate_cache()
end

---Validate color configuration
---@param colors table<Base16ProMax.Group.Raw, string> The colors to validate
---@return boolean valid True if all required colors are present
---@return string[] missing Array of missing color keys
function M.validate_colors(colors)
  local required_colors = require("base16-pro-max.lib.base16").get_base16_raw()

  local missing = {}
  for _, color in ipairs(required_colors) do
    if not colors[color] then
      table.insert(missing, color)
    end
  end

  return #missing == 0, missing
end

---Check if a plugin is enabled
---@param name string The plugin name
---@return boolean
function M.has_plugin(name)
  return require("base16-pro-max.plugins").has_plugin(name)
end

return M
