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

local V = {}

local U = {}

-- ------------------------------------------------------------------
-- States & caches
-- ------------------------------------------------------------------

local did_setup = false

---@type table<string, string>|nil
local _blend_cache = nil

---@type Base16ProMax.Group.Alias[]|nil
local _base16_aliases = nil

---@type Base16ProMax.Group.Raw[]|nil
local _base16_raw = nil

---@type table<string, string>|nil
local _color_cache = nil

---@type table<number, { r: integer, g: integer, b: integer }>|nil
local _cterm_cache = nil

---@type table<string, integer|"NONE">
local _hex_to_cterm_cache = {}

---@type table<string, vim.api.keyset.highlight>|nil
local _computed_highlights_cache = nil

-- ------------------------------------------------------------------
-- Constants
-- ------------------------------------------------------------------

---Reference `https://github.com/tinted-theming/home/blob/main/styling.md`
---@type table<Base16ProMax.Group.Alias, Base16ProMax.Group.Raw>
local base16_alias_map = {
  bg = "base00", -- Default background
  bg_dim = "base01", -- Lighter Background (Used for status bars)
  bg_light = "base02", -- Selection background
  fg_dim = "base03", -- Comments, Invisibles, Line Highlighting
  fg_dark = "base04", -- Dark Foreground (Used for status bars)
  fg = "base05", -- Default Foreground, Caret, Delimiters, Operators
  fg_light = "base06", -- Light foreground
  fg_bright = "base07", -- The Lightest Foreground
  red = "base08", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
  orange = "base09", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
  yellow = "base0A", -- Classes, Markup Bold, Search Text Background
  green = "base0B", -- Strings, Inherited Class, Markup Code, Diff Inserted
  cyan = "base0C", -- Support, Regular Expressions, Escape Characters, Markup Quotes
  blue = "base0D", -- Functions, Methods, Attribute IDs, Headings
  purple = "base0E", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
  brown = "base0F", -- Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
}

-- ------------------------------------------------------------------
-- Types
-- ------------------------------------------------------------------

---@mod base16-pro-max.types Types

---@class Base16ProMax.Config
---@field colors? table<Base16ProMax.Group.Raw, string> Colors to override
---@field styles? Base16ProMax.Config.Styles Styles to override
---@field highlight_groups? Base16ProMax.Config.HighlightGroups.Table|Base16ProMax.Config.HighlightGroups.Function  Additional highlight groups to set
---@field before_highlight? fun(group: string, opts: vim.api.keyset.highlight, c: table<Base16ProMax.Group.Alias, string>): nil Callback to run before setting highlight groups
---@field plugins? Base16ProMax.Config.Plugins Enable/disable plugins
---@field color_groups? Base16ProMax.Config.ColorGroups Color groups to override
---@field setup_globals? Base16ProMax.Config.SetupGlobals Setup globals

---@alias Base16ProMax.Config.HighlightGroups.Table table<string, vim.api.keyset.highlight>
---@alias Base16ProMax.Config.HighlightGroups.Function fun(function_refs: Base16ProMax.Config.HighlightGroups.FunctionRefs): Base16ProMax.Config.HighlightGroups.Table

---@class Base16ProMax.Config.HighlightGroups.FunctionRefs
---@field get_group_color_fn fun(group: string, key: string, c: table<Base16ProMax.Group.Alias, string>): string|nil
---@field get_bg_fn fun(bg: string): string|nil
---@field blend_fn fun(fg: string, bg: string, alpha: number): string
---@field styles_config Base16ProMax.Config.Styles Styles configuration
---@field colors table<Base16ProMax.Group.Alias, string> Semantic color palette

---@class Base16ProMax.Config.SetupGlobals
---@field terminal_colors? boolean Set terminal colors
---@field base16_gui_colors? boolean Set base16 gui colors

---@class Base16ProMax.Config.ColorGroups
---@field backgrounds? Base16ProMax.Config.ColorGroups.Backgrounds Background colors
---@field foregrounds? Base16ProMax.Config.ColorGroups.Foregrounds Foreground colors
---@field syntax? Base16ProMax.Config.ColorGroups.Syntax Syntax colors
---@field states? Base16ProMax.Config.ColorGroups.States Semantic colors
---@field diff? Base16ProMax.Config.ColorGroups.Diff Diff colors
---@field git? Base16ProMax.Config.ColorGroups.Git Git colors
---@field search? Base16ProMax.Config.ColorGroups.Search Search colors

---@alias Base16ProMax.Config.ColorGroups.Color string|Base16ProMax.Config.ColorGroups.Color.Function
---@alias Base16ProMax.Config.ColorGroups.Color.Function fun(function_refs: Base16ProMax.Config.ColorGroups.Color.FunctionRefs): string

---@class Base16ProMax.Config.ColorGroups.Color.FunctionRefs
---@field blend_fn fun(fg: string, bg: string, alpha: number): string Blend function
---@field colors table<Base16ProMax.Group.Alias, string> Semantic color palette

---@class Base16ProMax.Config.ColorGroups.Backgrounds
---@field normal? Base16ProMax.Config.ColorGroups.Color Normal background
---@field dim? Base16ProMax.Config.ColorGroups.Color Dim background
---@field light? Base16ProMax.Config.ColorGroups.Color Light background
---@field selection? Base16ProMax.Config.ColorGroups.Color Selection background
---@field cursor_line? Base16ProMax.Config.ColorGroups.Color Cursor line background
---@field cursor_column? Base16ProMax.Config.ColorGroups.Color Cursor column background

---@class Base16ProMax.Config.ColorGroups.Foregrounds
---@field normal? Base16ProMax.Config.ColorGroups.Color Normal foreground
---@field dim? Base16ProMax.Config.ColorGroups.Color Dim foreground
---@field dark? Base16ProMax.Config.ColorGroups.Color Dark foreground
---@field light? Base16ProMax.Config.ColorGroups.Color Light foreground
---@field bright? Base16ProMax.Config.ColorGroups.Color Bright foreground
---@field comment? Base16ProMax.Config.ColorGroups.Color Comment foreground
---@field line_number? Base16ProMax.Config.ColorGroups.Color Line number foreground
---@field deprecated? Base16ProMax.Config.ColorGroups.Color deprecated foreground

---@class Base16ProMax.Config.ColorGroups.Syntax
---@field variable? Base16ProMax.Config.ColorGroups.Color Variable foreground
---@field constant? Base16ProMax.Config.ColorGroups.Color Constant foreground
---@field string? Base16ProMax.Config.ColorGroups.Color String foreground
---@field number? Base16ProMax.Config.ColorGroups.Color Number foreground
---@field boolean? Base16ProMax.Config.ColorGroups.Color Boolean foreground
---@field keyword? Base16ProMax.Config.ColorGroups.Color Keyword foreground
---@field function_name? Base16ProMax.Config.ColorGroups.Color Function name foreground
---@field type? Base16ProMax.Config.ColorGroups.Color Type foreground
---@field comment? Base16ProMax.Config.ColorGroups.Color Comment foreground
---@field operator? Base16ProMax.Config.ColorGroups.Color Operator foreground
---@field delimiter? Base16ProMax.Config.ColorGroups.Color Delimiter foreground

---@class Base16ProMax.Config.ColorGroups.States
---@field error? Base16ProMax.Config.ColorGroups.Color Error foreground
---@field warning? Base16ProMax.Config.ColorGroups.Color Warning foreground
---@field info? Base16ProMax.Config.ColorGroups.Color Info foreground
---@field hint? Base16ProMax.Config.ColorGroups.Color Hint foreground
---@field success? Base16ProMax.Config.ColorGroups.Color Success foreground

---@class Base16ProMax.Config.ColorGroups.Diff
---@field added? Base16ProMax.Config.ColorGroups.Color Added foreground
---@field removed? Base16ProMax.Config.ColorGroups.Color Removed foreground
---@field changed? Base16ProMax.Config.ColorGroups.Color Changed foreground
---@field text? Base16ProMax.Config.ColorGroups.Color Text foreground

---@class Base16ProMax.Config.ColorGroups.Git
---@field added? Base16ProMax.Config.ColorGroups.Color Added foreground
---@field removed? Base16ProMax.Config.ColorGroups.Color Removed foreground
---@field changed? Base16ProMax.Config.ColorGroups.Color Changed foreground
---@field untracked? Base16ProMax.Config.ColorGroups.Color Untracked foreground

---@class Base16ProMax.Config.ColorGroups.Search
---@field match? Base16ProMax.Config.ColorGroups.Color Match foreground
---@field current? Base16ProMax.Config.ColorGroups.Color Current match foreground
---@field incremental? Base16ProMax.Config.ColorGroups.Color Incremental match foreground

---@class Base16ProMax.Config.Styles
---@field italic? boolean Enable italics
---@field bold? boolean Enable bold text
---@field transparency? boolean Transparent background
---@field dim_inactive_windows? boolean Dim inactive windows
---@field blends? Base16ProMax.Config.Styles.Blends Blend values to override
---@field use_cterm? boolean Use cterm colors (overrides colors)

---@class Base16ProMax.Config.Styles.Blends
---@field subtle? number barely visible backgrounds (10%)
---@field medium? number noticeable but not distracting (15%)
---@field strong? number prominent highlights (25%)
---@field super? number very prominent highlights (50%)

---@class Base16ProMax.Config.Plugins
---@field enable_all? boolean Enable all plugins
---@field nvim_mini_mini_icons? boolean Enable Mini Icons
---@field nvim_mini_mini_diff? boolean Enable Mini Diff
---@field nvim_mini_mini_files? boolean Enable Mini Files
---@field nvim_mini_mini_pick? boolean Enable Mini Pick
---@field meandering_programmer_render_markdown_nvim? boolean Enable Render Markdown
---@field y3owk1n_undo_glow_nvim? boolean Enable Undo Glow
---@field y3owk1n_time_machine_nvim? boolean Enable Time Machine
---@field saghen_blink_cmp? boolean Enable Blink Cmp
---@field magicduck_grug_far_nvim? boolean Enable Grug Far
---@field folke_which_key_nvim? boolean Enable Which Key
---@field folke_flash_nvim? boolean Enable Flash
---@field lewis6991_gitsigns_nvim? boolean Enable Git Signs

---@alias Base16ProMax.Group.Raw
---| '"base00"' # Default background (Semantic Alias: bg)
---| '"base01"' # Lighter Background (Used for status bars) (Semantic Alias: bg_dim)
---| '"base02"' # Selection background (Semantic Alias: bg_light)
---| '"base03"' # Comments, Invisibles, Line Highlighting (Semantic Alias: fg_dim)
---| '"base04"' # Dark Foreground (Used for status bars) (Semantic Alias: fg_dark)
---| '"base05"' # Default Foreground, Caret, Delimiters, Operators (Semantic Alias: fg)
---| '"base06"' # Light foreground (Semantic Alias: fg_light)
---| '"base07"' # The Lightest Foreground (Semantic Alias: fg_bright)
---| '"base08"' # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted (Semantic Alias: red)
---| '"base09"' # Integers, Boolean, Constants, XML Attributes, Markup Link Url (Semantic Alias: orange)
---| '"base0A"' # Classes, Markup Bold, Search Text Background (Semantic Alias: yellow)
---| '"base0B"' # Strings, Inherited Class, Markup Code, Diff Inserted (Semantic Alias: green)
---| '"base0C"' # Support, Regular Expressions, Escape Characters, Markup Quotes (Semantic Alias: cyan)
---| '"base0D"' # Functions, Methods, Attribute IDs, Headings (Semantic Alias: blue)
---| '"base0E"' # Keywords, Storage, Selector, Markup Italic, Diff Changed (Semantic Alias: purple)
---| '"base0F"' # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?> (Semantic Alias: brown)

---@alias Base16ProMax.Group.Alias
---| '"bg"' # Default background (Raw Base16ProMax: base00)
---| '"bg_dim"' # Lighter Background (Used for status bars) (Raw Base16ProMax: base01)
---| '"bg_light"' # Selection background (Raw Base16ProMax: base02)
---| '"fg_dim"' # Comments, Invisibles, Line Highlighting (Raw Base16ProMax: base03)
---| '"fg_dark"' # Dark Foreground (Used for status bars) (Raw Base16ProMax: base04)
---| '"fg"' # Default Foreground, Caret, Delimiters, Operators (Raw Base16ProMax: base05)
---| '"fg_light"' # Light foreground (Raw Base16ProMax: base06)
---| '"fg_bright"' # The Lightest Foreground (Raw Base16ProMax: base07)
---| '"red"' # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted (Raw Base16ProMax: base08)
---| '"orange"' # Integers, Boolean, Constants, XML Attributes, Markup Link Url (Raw Base16ProMax: base09)
---| '"yellow"' # Classes, Markup Bold, Search Text Background (Raw Base16ProMax: base0A)
---| '"green"' # Strings, Inherited Class, Markup Code, Diff Insert
---| '"cyan"' # Support, Regular Expressions, Escape Characters, Markup Quotes (Raw Base16ProMax: base0C)
---| '"blue"' # Functions, Methods, Attribute IDs, Headings (Raw Base16ProMax: base0D)
---| '"purple"' # Keywords, Storage, Selector, Markup Italic, Diff Changed (Raw Base16ProMax: base0E)
---| '"brown"' # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?> (Raw Base16ProMax: base0F)

-- ------------------------------------------------------------------
-- Utility
-- ------------------------------------------------------------------

---@private
---Convert a color name to RGB values
---@param hex string
---@return {r: integer, g: integer, b: integer}|nil rgb The RGB values, or nil if not a valid hex color
function U.hex_to_rgb(hex)
  if hex == "NONE" then
    return nil
  end

  if #hex ~= 7 or hex:sub(1, 1) ~= "#" then
    return nil
  end

  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  if not r or not g or not b then
    return nil
  end

  return { r = r, g = g, b = b }
end

---@private
---Build cterm colors
---@return table<number, { r: integer, g: integer, b: integer }>
function U.build_cterm_colors()
  local cterm_palette = {}

  local ansi = {
    { 0, 0, 0 },
    { 128, 0, 0 },
    { 0, 128, 0 },
    { 128, 128, 0 },
    { 0, 0, 128 },
    { 128, 0, 128 },
    { 0, 128, 128 },
    { 192, 192, 192 },
    { 128, 128, 128 },
    { 255, 0, 0 },
    { 0, 255, 0 },
    { 255, 255, 0 },
    { 0, 0, 255 },
    { 255, 0, 255 },
    { 0, 255, 255 },
    { 255, 255, 255 },
  }
  for i, rgb in ipairs(ansi) do
    cterm_palette[i - 1] = { r = rgb[1], g = rgb[2], b = rgb[3] }
  end

  -- 6×6×6 color cube (index 16–231)
  local index = 16
  for r = 0, 5 do
    for g = 0, 5 do
      for b = 0, 5 do
        local function level(v)
          return v == 0 and 0 or v * 40 + 55
        end
        cterm_palette[index] = { r = level(r), g = level(g), b = level(b) }
        index = index + 1
      end
    end
  end

  -- Grayscale ramp (index 232–255)
  for i = 0, 23 do
    local level = 8 + i * 10
    cterm_palette[index] = { r = level, g = level, b = level }
    index = index + 1
  end

  return cterm_palette
end

---@private
---Get the rgb to cterm256 table
---@return table<number, { r: integer, g: integer, b: integer }>
function U.get_rgb_to_cterm()
  if not _cterm_cache then
    _cterm_cache = U.build_cterm_colors()
  end
  return _cterm_cache
end

---Find the nearest cterm256 color index by Manhattan distance
---@param rgb {r: integer, g: integer, b: integer}
---@return integer|nil
function U.get_nearest_cterm(rgb)
  local nearest_id = nil
  local nearest_distance = math.huge

  for id, c in pairs(U.get_rgb_to_cterm()) do
    local distance = math.abs(rgb.r - c.r) + math.abs(rgb.g - c.g) + math.abs(rgb.b - c.b)
    if distance < nearest_distance then
      nearest_id, nearest_distance = id, distance
    end
  end
  return nearest_id
end

---@private
---Convert a hex color to a cterm256 color
---@param hex string The hex color
---@return integer|"NONE" cterm256 The cterm256 color
function U.hex_to_cterm256(hex)
  if hex == "NONE" then
    return "NONE"
  end

  if _hex_to_cterm_cache[hex] then
    return _hex_to_cterm_cache[hex]
  end

  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  if not r or not g or not b then
    _hex_to_cterm_cache[hex] = "NONE"
    return "NONE"
  end

  local nearest = U.get_nearest_cterm({ r = r, g = g, b = b }) or "NONE"

  _hex_to_cterm_cache[hex] = nearest

  return nearest
end

---@private
---@param fg string Foreground color
---@param bg string Background color
---@param alpha number Between 0 (background) and 1 (foreground)
---@return string blended_color The blended color as hex
function U.blend(fg, bg, alpha)
  local cache_key = fg .. bg .. alpha

  if not _blend_cache then
    _blend_cache = {}
  end

  if _blend_cache[cache_key] then
    return _blend_cache[cache_key]
  end

  local fg_rgb = U.hex_to_rgb(fg)
  local bg_rgb = U.hex_to_rgb(bg)

  if not fg_rgb or not bg_rgb then
    _blend_cache[cache_key] = "NONE"
    return "NONE"
  end

  local function blend_channel(fg_val, bg_val)
    local result = alpha * fg_val + (1 - alpha) * bg_val
    return math.floor(math.min(math.max(0, result), 255) + 0.5)
  end

  local result = string.format(
    "#%02X%02X%02X",
    blend_channel(fg_rgb.r, bg_rgb.r),
    blend_channel(fg_rgb.g, bg_rgb.g),
    blend_channel(fg_rgb.b, bg_rgb.b)
  )

  _blend_cache[cache_key] = result
  return result
end

---@private
---Check if a plugin is enabled in config
---@param name string The plugin name
function U.has_plugin(name)
  local plugin = M.config.plugins[name]

  if plugin == nil then
    return M.config.plugins.enable_all or false
  end

  return plugin
end

---@private
---Add semantic aliases to the raw colors
---@param raw_colors table<Base16ProMax.Group.Raw, string>
---@return table<Base16ProMax.Group.Alias, string>
function U.add_semantic_palette(raw_colors)
  return setmetatable({}, {
    __index = function(_, k)
      -- Exact match in the raw palette?
      local v = raw_colors[k]
      if v then
        return v
      end

      -- Semantic alias
      local canonical = base16_alias_map[k]
      if canonical then
        return raw_colors[canonical]
      end

      return nil
    end,
  })
end

---@private
---Consistent transparency handling
---@param normal_bg string The normal background color
---@param transparent_override? string The transparent override color
---@return string The background color
function U.get_bg(normal_bg, transparent_override)
  if M.config.styles.transparency then
    return transparent_override or "NONE"
  end
  return normal_bg
end

---@private
---Get a color from the color groups
---@param group string The color group (e.g., "syntax", "states")
---@param key string The color key within the group
---@param c table<Base16ProMax.Group.Alias, string> The semantic color palette
---@return string color The resolved color
function U.get_group_color(group, key, c)
  local color_group = M.config.color_groups[group]
  if not color_group or not color_group[key] then
    return c.fg -- fallback
  end

  local color_value = color_group[key]
  if type(color_value) == "function" then
    local function_refs = {
      blend_fn = U.blend,
      colors = c,
    }
    return color_value(function_refs)
  else
    return c[color_value]
  end
end

---@private
---Check if a value is a valid hex color
---@param color string The color value to validate
---@return boolean valid True if valid hex color
---@return string? error Error message if invalid
function U.is_valid_hex_color(color)
  if type(color) ~= "string" then
    return false, "must be a string"
  end

  -- Allow "NONE" for transparency
  if color == "NONE" then
    return true
  end

  -- Check hex color format
  if not color:match("^#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
    return false, "must be a valid hex color (e.g., #ffffff) or 'NONE'"
  end

  return true
end

---@private
---Validate blend value
---@param blend_value number The blend value to validate
---@return boolean valid True if valid
---@return string? error Error message if invalid
function U.is_valid_blend(blend_value)
  if type(blend_value) ~= "number" then
    return false, "must be a number"
  end

  if blend_value < 0 or blend_value > 100 then
    return false, "must be between 0 and 100"
  end

  return true
end

---@private
---Validate plugin name format
---@param plugin_name string The plugin name to validate
---@return boolean valid True if valid
---@return string? error Error message if invalid
function U.is_valid_plugin_name(plugin_name)
  if type(plugin_name) ~= "string" then
    return false, "must be a string"
  end

  -- Check if it matches expected plugin naming convention
  if not plugin_name:match("^[a-zA-Z0-9_][a-zA-Z0-9_]*$") then
    return false, "must contain only alphanumeric characters and underscores"
  end

  return true
end

---@private
---Validate color group color value (can be string or function)
---@param color Base16ProMax.Config.ColorGroups.Color The color value to validate
---@param group_name string The group name for error context
---@param key_name string The key name for error context
---@return boolean valid True if valid
---@return string? error Error message if invalid
function U.is_valid_color_group_color(color, group_name, key_name)
  local base16_aliases = _base16_aliases or U.get_base16_aliases()
  local base16_raw = _base16_raw or U.get_base16_raw()

  if type(color) == "string" then
    -- Check if it's a known alias
    for _, alias in ipairs(base16_aliases) do
      if color == alias then
        return true
      end
    end

    -- Check if it's a raw base16 color
    for _, raw in ipairs(base16_raw) do
      if color == raw then
        return true
      end
    end

    -- Check if it's a hex color
    local valid, err = U.is_valid_hex_color(color)
    if not valid then
      return false, string.format("in %s.%s: %s", group_name, key_name, err)
    end

    return true
  elseif type(color) == "function" then
    return true -- Functions are validated at runtime
  else
    return false, string.format("in %s.%s: must be a string (color alias/hex) or function", group_name, key_name)
  end
end

---Get array of all base16 semantic aliases
---@return Base16ProMax.Group.Alias[]
function U.get_base16_aliases()
  if not _base16_aliases then
    _base16_aliases = vim.tbl_keys(base16_alias_map)
    table.sort(_base16_aliases) -- For consistent ordering
  end
  return _base16_aliases
end

---Get array of all base16 raw color names
---@return Base16ProMax.Group.Raw[]
function U.get_base16_raw()
  if not _base16_raw then
    -- Create sorted list of unique raw values
    local raw_set = {}
    for _, raw_color in pairs(base16_alias_map) do
      raw_set[raw_color] = true
    end

    _base16_raw = vim.tbl_keys(raw_set)
    table.sort(_base16_raw) -- For consistent ordering
  end
  return _base16_raw
end

---Check if a color name is a valid base16 alias
---@param color_name string
---@return boolean
function U.is_base16_alias(color_name)
  return base16_alias_map[color_name] ~= nil
end

---Check if a color name is a valid base16 raw color
---@param color_name string
---@return boolean
function U.is_base16_raw(color_name)
  for _, raw_color in pairs(base16_alias_map) do
    if raw_color == color_name then
      return true
    end
  end
  return false
end

---Check if a color name is any valid base16 reference (alias or raw)
---@param color_name string
---@return boolean
function U.is_valid_base16_color(color_name)
  return U.is_base16_alias(color_name) or U.is_base16_raw(color_name)
end

---Get the raw color for an alias, or return the input if it's already raw
---@param color_name string
---@return string|nil
function U.resolve_color_name(color_name)
  -- If it's an alias, return the raw color
  if base16_alias_map[color_name] then
    return base16_alias_map[color_name]
  end

  -- If it's already a raw color, return it
  if U.is_base16_raw(color_name) then
    return color_name
  end

  -- Not a base16 color
  return nil
end

-- ------------------------------------------------------------------
-- Validators
-- ------------------------------------------------------------------

---Validate colors configuration
---@param colors table<Base16ProMax.Group.Raw, string> Colors configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function V.validate_colors(colors)
  local errors = {}

  if not colors or type(colors) ~= "table" then
    errors.colors = "must be a table"
    return false, errors
  end

  local required_colors = _base16_raw or U.get_base16_raw()

  -- Check for missing colors
  for _, color_key in ipairs(required_colors) do
    if not colors[color_key] then
      errors["colors." .. color_key] = "required base16 color is missing"
    else
      local valid, err = U.is_valid_hex_color(colors[color_key])
      if not valid then
        errors["colors." .. color_key] = err
      end
    end
  end

  -- Check for unexpected colors
  for color_key, _ in pairs(colors) do
    local found = false
    for _, required in ipairs(required_colors) do
      if color_key == required then
        found = true
        break
      end
    end
    if not found then
      errors["colors." .. color_key] = "unknown color key (expected base00-base0F)"
    end
  end

  return next(errors) == nil, errors
end

---Validate styles configuration
---@param styles Base16ProMax.Config.Styles Styles configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function V.validate_styles(styles)
  local errors = {}

  if not styles then
    return true, errors -- styles is optional
  end

  if type(styles) ~= "table" then
    errors.styles = "must be a table"
    return false, errors
  end

  -- Validate boolean style options
  local boolean_options = { "italic", "bold", "transparency", "dim_inactive_windows", "use_cterm" }
  for _, option in ipairs(boolean_options) do
    if styles[option] ~= nil and type(styles[option]) ~= "boolean" then
      errors["styles." .. option] = "must be a boolean"
    end
  end

  -- Validate blends
  if styles.blends then
    if type(styles.blends) ~= "table" then
      errors["styles.blends"] = "must be a table"
    else
      local blend_keys = { "subtle", "medium", "strong", "super" }
      for _, key in ipairs(blend_keys) do
        if styles.blends[key] ~= nil then
          local valid, err = U.is_valid_blend(styles.blends[key])
          if not valid then
            errors["styles.blends." .. key] = err
          end
        end
      end

      -- Check for unexpected blend keys
      for key, _ in pairs(styles.blends) do
        local found = false
        for _, expected in ipairs(blend_keys) do
          if key == expected then
            found = true
            break
          end
        end
        if not found then
          errors["styles.blends." .. key] = "unknown blend key (expected: subtle, medium, strong, super)"
        end
      end
    end
  end

  -- Check for unexpected style keys
  local valid_keys = { "italic", "bold", "transparency", "dim_inactive_windows", "blends", "use_cterm" }
  for key, _ in pairs(styles) do
    local found = false
    for _, valid_key in ipairs(valid_keys) do
      if key == valid_key then
        found = true
        break
      end
    end
    if not found then
      errors["styles." .. key] = "unknown style option"
    end
  end

  return next(errors) == nil, errors
end

---Validate setup_globals configuration
---@param setup_globals Base16ProMax.Config.SetupGlobals Setup globals configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function V.validate_setup_globals(setup_globals)
  local errors = {}

  if not setup_globals then
    return true, errors -- setup_globals is optional
  end

  if type(setup_globals) ~= "table" then
    errors.setup_globals = "must be a table"
    return false, errors
  end

  -- Validate boolean setup_globals options
  local boolean_options = { "terminal_colors", "base16_gui_colors" }
  for _, option in ipairs(boolean_options) do
    if setup_globals[option] ~= nil and type(setup_globals[option]) ~= "boolean" then
      errors["setup_globals." .. option] = "must be a boolean"
    end
  end

  return next(errors) == nil, errors
end

---Validate plugins configuration
---@param plugins Base16ProMax.Config.Plugins Plugins configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function V.validate_plugins(plugins)
  local errors = {}

  if not plugins then
    return true, errors -- plugins is optional
  end

  if type(plugins) ~= "table" then
    errors.plugins = "must be a table"
    return false, errors
  end

  -- Validate known plugin options
  local known_plugins = {
    "enable_all",
    "nvim_mini_mini_icons",
    "nvim_mini_mini_diff",
    "nvim_mini_mini_files",
    "nvim_mini_mini_pick",
    "meandering_programmer_render_markdown_nvim",
    "y3owk1n_undo_glow_nvim",
    "y3owk1n_time_machine_nvim",
    "saghen_blink_cmp",
    "magicduck_grug_far_nvim",
    "folke_which_key_nvim",
    "folke_flash_nvim",
    "lewis6991_gitsigns_nvim",
  }

  for key, value in pairs(plugins) do
    -- Validate plugin name format
    local valid_name, name_err = U.is_valid_plugin_name(key)
    if not valid_name then
      errors["plugins." .. key] = "invalid plugin name: " .. name_err
    end

    -- Validate boolean value
    if type(value) ~= "boolean" then
      errors["plugins." .. key] = "must be a boolean"
    end

    -- Warn about unknown plugins (not an error, just informational)
    local is_known = false
    for _, known in ipairs(known_plugins) do
      if key == known then
        is_known = true
        break
      end
    end
    if not is_known and key ~= "enable_all" then
      -- This is just a warning, not an error
      vim.notify("Base16ProMax: Unknown plugin: " .. key, vim.log.levels.WARN)
    end
  end

  return next(errors) == nil, errors
end

---Validate color groups configuration
---@param color_groups Base16ProMax.Config.ColorGroups Color groups configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function V.validate_color_groups(color_groups)
  local errors = {}

  if not color_groups then
    return true, errors -- color_groups is optional
  end

  if type(color_groups) ~= "table" then
    errors.color_groups = "must be a table"
    return false, errors
  end

  local group_schemas = {
    backgrounds = { "normal", "dim", "light", "selection", "cursor_line", "cursor_column" },
    foregrounds = { "normal", "dim", "dark", "light", "bright", "comment", "line_number" },
    syntax = {
      "variable",
      "constant",
      "string",
      "number",
      "boolean",
      "keyword",
      "function_name",
      "type",
      "comment",
      "operator",
      "delimiter",
    },
    states = { "error", "warning", "info", "hint", "success" },
    diff = { "added", "removed", "changed", "text" },
    search = { "match", "current", "incremental" },
  }

  for group_name, group_config in pairs(color_groups) do
    if not group_schemas[group_name] then
      errors["color_groups." .. group_name] = "unknown color group"
    else
      if type(group_config) ~= "table" then
        errors["color_groups." .. group_name] = "must be a table"
      else
        -- Validate keys within the group
        for key, value in pairs(group_config) do
          local found = false
          for _, valid_key in ipairs(group_schemas[group_name]) do
            if key == valid_key then
              found = true
              break
            end
          end

          if not found then
            errors["color_groups." .. group_name .. "." .. key] = "unknown color key"
          else
            local valid, err = U.is_valid_color_group_color(value, group_name, key)
            if not valid then
              errors["color_groups." .. group_name .. "." .. key] = err
            end
          end
        end
      end
    end
  end

  return next(errors) == nil, errors
end

---Validate highlight groups configuration
---@param highlight_groups Base16ProMax.Config.HighlightGroups.Table|Base16ProMax.Config.HighlightGroups.Function Highlight groups configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function V.validate_highlight_groups(highlight_groups)
  local errors = {}

  if not highlight_groups then
    return true, errors -- highlight_groups is optional
  end

  if not (type(highlight_groups) == "table" or type(highlight_groups) == "function") then
    errors.highlight_groups = "must be a table / function"
    return false, errors
  end

  if type(highlight_groups) == "table" then
    for group_name, highlight in pairs(highlight_groups) do
      if type(group_name) ~= "string" then
        errors["highlight_groups.<invalid_key>"] = "highlight group names must be strings"
        goto continue
      end

      if type(highlight) ~= "table" then
        errors["highlight_groups." .. group_name] = "must be a table"
        goto continue
      end

      -- Validate highlight attributes
      for attr, value in pairs(highlight) do
        if attr == "fg" or attr == "bg" or attr == "sp" then
          if type(value) ~= "string" then
            errors["highlight_groups." .. group_name .. "." .. attr] = "color attributes must be strings"
          else
            local base16_aliases = _base16_aliases or U.get_base16_aliases()
            local base16_raw = _base16_raw or U.get_base16_raw()
            -- Check if it's a known base16 alias
            local is_alias = false
            for _, alias in ipairs(base16_aliases) do
              if value == alias then
                is_alias = true
                break
              end
            end

            -- Check if it's a raw base16 color
            local is_raw = false
            if not is_alias then
              for _, raw in ipairs(base16_raw) do
                if value == raw then
                  is_raw = true
                  break
                end
              end
            end

            -- If it's not an alias or raw color, validate as hex
            if not is_alias and not is_raw then
              local valid, err = U.is_valid_hex_color(value)
              if not valid then
                errors["highlight_groups." .. group_name .. "." .. attr] = err
              end
            end
          end
        elseif attr == "blend" then
          if type(value) ~= "number" or value < 0 or value > 100 then
            errors["highlight_groups." .. group_name .. "." .. attr] = "must be a number between 0 and 100"
          end
        elseif attr == "link" then
          if type(value) ~= "string" then
            errors["highlight_groups." .. group_name .. "." .. attr] = "must be a string"
          end
        else
          -- Boolean attributes (bold, italic, underline, etc.)
          local boolean_attrs = {
            "bold",
            "italic",
            "underline",
            "undercurl",
            "underdouble",
            "underdotted",
            "underdashed",
            "strikethrough",
            "reverse",
            "standout",
            "nocombine",
          }
          local is_boolean_attr = false
          for _, bool_attr in ipairs(boolean_attrs) do
            if attr == bool_attr then
              is_boolean_attr = true
              break
            end
          end

          if is_boolean_attr then
            if type(value) ~= "boolean" then
              errors["highlight_groups." .. group_name .. "." .. attr] = "must be a boolean"
            end
          else
            errors["highlight_groups." .. group_name .. "." .. attr] = "unknown highlight attribute"
          end
        end
      end

      ::continue::
    end
  end

  return next(errors) == nil, errors
end

---Validate before_highlight callback
---@param before_highlight function? The callback function
---@return boolean valid True if valid
---@return string? error Error message if invalid
function V.validate_before_highlight(before_highlight)
  if before_highlight == nil then
    return true -- optional
  end

  if type(before_highlight) ~= "function" then
    return false, "must be a function"
  end

  return true
end

---Validate entire configuration
---@param config Base16ProMax.Config The configuration to validate
---@return boolean valid True if all validation passes
---@return table<string, string> errors Map of error keys to messages
---@return table<string, string> warnings Map of warning keys to messages
function V.validate_config(config)
  local errors = {}
  local warnings = {}

  if not config or type(config) ~= "table" then
    errors.config = "configuration must be a table"
    return false, errors, warnings
  end

  -- Validate each section
  local sections = {
    { key = "colors", validator = V.validate_colors },
    { key = "styles", validator = V.validate_styles },
    { key = "plugins", validator = V.validate_plugins },
    { key = "setup_globals", validator = V.validate_setup_globals },
    { key = "color_groups", validator = V.validate_color_groups },
    { key = "highlight_groups", validator = V.validate_highlight_groups },
  }

  for _, section in ipairs(sections) do
    local valid, section_errors = section.validator(config[section.key])
    if not valid then
      for key, message in pairs(section_errors) do
        errors[key] = message
      end
    end
  end

  -- Validate before_highlight callback
  local valid, err = V.validate_before_highlight(config.before_highlight)
  if not valid then
    errors.before_highlight = err
  end

  -- Check for unknown top-level keys
  local valid_keys =
    { "colors", "styles", "plugins", "setup_globals", "color_groups", "highlight_groups", "before_highlight" }
  for key, _ in pairs(config) do
    local found = false
    for _, valid_key in ipairs(valid_keys) do
      if key == valid_key then
        found = true
        break
      end
    end
    if not found then
      warnings["config." .. key] = "unknown configuration key (will be ignored)"
    end
  end

  return next(errors) == nil, errors, warnings
end

---Format validation errors for display
---@param errors table<string, string> Map of error keys to messages
---@param warnings? table<string, string> Map of warning keys to messages
---@return string formatted_message The formatted error message
function V.format_errors(errors, warnings)
  local lines = {}

  if next(errors) then
    table.insert(lines, "Base16ProMax Configuration Errors:")
    for key, message in pairs(errors) do
      table.insert(lines, "  • " .. key .. ": " .. message)
    end
  end

  if warnings and next(warnings) then
    if next(errors) then
      table.insert(lines, "")
    end
    table.insert(lines, "Base16ProMax Configuration Warnings:")
    for key, message in pairs(warnings) do
      table.insert(lines, "  • " .. key .. ": " .. message)
    end
  end

  return table.concat(lines, "\n")
end

-- ------------------------------------------------------------------
-- Highlight Setup Functions
-- ------------------------------------------------------------------

---@private
---Setup editor highlights (UI elements)
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_editor_hl(highlights, c)
  -- Normal and floating windows
  highlights.Normal = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.NormalFloat = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.NormalNC = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = M.config.styles.dim_inactive_windows and U.get_group_color("backgrounds", "dim", c)
      or U.get_bg(U.get_group_color("backgrounds", "normal", c)),
    blend = M.config.styles.dim_inactive_windows and M.config.styles.blends.super or nil,
  }
  highlights.NormalSB = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = U.get_group_color("backgrounds", "normal", c),
  }

  -- Cursor and lines
  highlights.Cursor = {
    fg = U.get_group_color("backgrounds", "normal", c),
    bg = U.get_group_color("foregrounds", "normal", c),
    bold = M.config.styles.bold,
  }
  highlights.lCursor = { link = "Cursor" }
  highlights.CursorIM = { link = "Cursor" }
  highlights.CursorLine = { bg = U.get_group_color("backgrounds", "cursor_line", c) }
  highlights.CursorColumn = { bg = U.get_bg(U.get_group_color("backgrounds", "cursor_column", c)) }
  highlights.CursorLineNr = {
    fg = U.get_group_color("syntax", "constant", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "cursor_line", c)),
    bold = M.config.styles.bold,
  }
  highlights.LineNr = { fg = U.get_group_color("foregrounds", "line_number", c) }
  highlights.SignColumn = { fg = U.get_group_color("foregrounds", "dim", c) }
  highlights.SignColumnSB = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.ColorColumn = { bg = U.get_bg(U.get_group_color("backgrounds", "dim", c)) }

  -- Window separators
  highlights.VertSplit = { fg = U.get_group_color("foregrounds", "dim", c) }
  highlights.WinSeparator = { fg = U.get_group_color("foregrounds", "dim", c) }
  highlights.WinBar = {
    fg = U.get_group_color("foregrounds", "dark", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "light", c)),
  }
  highlights.WinBarNC = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "dim", c)),
  }

  -- Folding and concealing
  highlights.Folded = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "dim", c)),
  }
  highlights.FoldColumn = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.Conceal = { fg = U.get_group_color("foregrounds", "dim", c) }

  -- Visual selection
  highlights.Visual = { bg = U.get_group_color("backgrounds", "selection", c) }
  highlights.VisualNOS = { link = "Visual" }
  highlights.MatchParen = {
    bg = U.get_group_color("backgrounds", "selection", c),
    bold = M.config.styles.bold,
  }

  -- Search
  highlights.Search = {
    fg = U.get_group_color("backgrounds", "normal", c),
    bg = U.get_group_color("search", "match", c),
    bold = M.config.styles.bold,
  }
  highlights.CurSearch = {
    fg = U.get_group_color("backgrounds", "normal", c),
    bg = U.get_group_color("search", "current", c),
    bold = M.config.styles.bold,
  }
  highlights.IncSearch = { link = "CurSearch" }
  highlights.Substitute = { link = "IncSearch" }
end

---@private
---Setup popup menu highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_popup_hl(highlights, c)
  highlights.Pmenu = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.PmenuSel = {
    bg = U.get_group_color("backgrounds", "selection", c),
    bold = M.config.styles.bold,
  }
  highlights.PmenuSbar = { bg = U.get_group_color("backgrounds", "light", c) }
  highlights.PmenuThumb = { bg = U.get_group_color("foregrounds", "dark", c) }
  highlights.PmenuKind = {
    fg = U.get_group_color("syntax", "keyword", c),
    bold = M.config.styles.bold,
  }
  highlights.PmenuKindSel = {
    fg = U.get_group_color("syntax", "keyword", c),
    bg = U.blend(U.get_group_color("syntax", "function_name", c), U.get_group_color("backgrounds", "normal", c), 0.3),
    bold = M.config.styles.bold,
  }
  highlights.PmenuExtra = { fg = U.get_group_color("foregrounds", "dim", c) }
  highlights.PmenuExtraSel = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.blend(U.get_group_color("syntax", "function_name", c), U.get_group_color("backgrounds", "normal", c), 0.3),
  }
end

---@private
---Setup status and tab line highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_statusline_hl(highlights, c)
  -- Tabline
  highlights.TabLine = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "dim", c)),
  }
  highlights.TabLineFill = { bg = U.get_bg(U.get_group_color("backgrounds", "dim", c)) }
  highlights.TabLineSel = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = U.get_group_color("backgrounds", "light", c),
    bold = M.config.styles.bold,
  }

  -- Statusline
  highlights.StatusLine = {
    fg = U.get_group_color("foregrounds", "dark", c),
    bg = U.get_group_color("backgrounds", "dim", c),
  }
  highlights.StatusLineNC = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_group_color("backgrounds", "dim", c),
  }
end

---@private
---Setup message highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_message_hl(highlights, c)
  highlights.ErrorMsg = {
    fg = U.get_group_color("states", "error", c),
    bold = M.config.styles.bold,
  }
  highlights.WarningMsg = {
    fg = U.get_group_color("states", "warning", c),
    bold = M.config.styles.bold,
  }
  highlights.MoreMsg = { fg = U.get_group_color("states", "success", c) }
  highlights.ModeMsg = { fg = U.get_group_color("states", "success", c) }
  highlights.Question = { fg = U.get_group_color("states", "info", c) }
  highlights.NvimInternalError = { link = "ErrorMsg" }
end

---@private
---Setup diff highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_diff_hl(highlights, c)
  highlights.DiffAdd = { fg = U.get_group_color("diff", "added", c) }
  highlights.DiffChange = { fg = U.get_group_color("diff", "changed", c) }
  highlights.DiffDelete = { fg = U.get_group_color("diff", "removed", c) }
  highlights.DiffText = { fg = U.get_group_color("diff", "text", c) }
end

---@private
---Setup spelling highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_spelling_hl(highlights, c)
  highlights.SpellBad = { sp = U.get_group_color("states", "error", c), undercurl = true }
  highlights.SpellCap = { sp = U.get_group_color("states", "info", c), undercurl = true }
  highlights.SpellLocal = { sp = U.get_group_color("syntax", "operator", c), undercurl = true }
  highlights.SpellRare = { sp = U.get_group_color("states", "hint", c), undercurl = true }
end

---@private
---Setup syntax highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_syntax_hl(highlights, c)
  -- Comments
  highlights.Comment = {
    fg = U.get_group_color("syntax", "comment", c),
    italic = M.config.styles.italic,
  }

  -- Constants
  highlights.Constant = { fg = U.get_group_color("syntax", "constant", c), bold = M.config.styles.bold }
  highlights.String = { fg = U.get_group_color("syntax", "string", c) }
  highlights.Character = { fg = U.get_group_color("syntax", "constant", c) }
  highlights.Number = { fg = U.get_group_color("syntax", "number", c) }
  highlights.Boolean = { fg = U.get_group_color("syntax", "boolean", c) }
  highlights.Float = { fg = U.get_group_color("syntax", "number", c) }

  -- Identifiers
  highlights.Identifier = { fg = U.get_group_color("syntax", "variable", c) }
  highlights.Function = {
    fg = U.get_group_color("syntax", "function_name", c),
    bold = M.config.styles.bold,
  }

  -- Keywords and statements
  highlights.Statement = { fg = U.get_group_color("syntax", "function_name", c) }
  highlights.Conditional = { fg = U.get_group_color("syntax", "keyword", c) }
  highlights.Repeat = { fg = U.get_group_color("syntax", "keyword", c) }
  highlights.Label = { fg = U.get_group_color("syntax", "operator", c) }
  highlights.Operator = { fg = U.get_group_color("syntax", "operator", c) }
  highlights.Keyword = {
    fg = U.get_group_color("syntax", "keyword", c),
    bold = M.config.styles.bold,
  }
  highlights.Exception = { fg = U.get_group_color("states", "error", c) }

  -- Preprocessor
  highlights.PreProc = { link = "PreCondit" }
  highlights.Include = { fg = U.get_group_color("syntax", "function_name", c), italic = M.config.styles.italic }
  highlights.Define = { fg = U.get_group_color("syntax", "keyword", c) }
  highlights.Macro = { fg = U.get_group_color("states", "error", c) }
  highlights.PreCondit = { fg = U.get_group_color("syntax", "keyword", c), italic = M.config.styles.italic }

  -- Types
  highlights.Type = {
    fg = U.get_group_color("syntax", "type", c),
    bold = M.config.styles.bold,
  }
  highlights.StorageClass = { fg = U.get_group_color("syntax", "type", c) }
  highlights.Structure = { fg = U.get_group_color("syntax", "operator", c) }
  highlights.Typedef = { link = "Type" }

  -- Specials
  highlights.Special = { fg = U.get_group_color("syntax", "operator", c) }
  highlights.SpecialChar = { link = "Special" }
  highlights.Tag = { fg = U.get_group_color("syntax", "operator", c) }
  highlights.Delimiter = { fg = U.get_group_color("syntax", "delimiter", c) }
  highlights.SpecialComment = { link = "Special" }
  highlights.Debug = { fg = U.get_group_color("states", "error", c) }

  -- Misc
  highlights.Underlined = { underline = true }
  highlights.Bold = { bold = M.config.styles.bold }
  highlights.Italic = { italic = M.config.styles.italic }
  highlights.Ignore = { fg = U.get_group_color("foregrounds", "dim", c) }
  highlights.Error = {
    fg = U.get_group_color("states", "error", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.Todo = {
    fg = U.get_group_color("syntax", "type", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "dim", c)),
  }

  -- Health check colors
  highlights.healthError = { fg = U.get_group_color("states", "error", c) }
  highlights.healthSuccess = { fg = U.get_group_color("states", "success", c) }
  highlights.healthWarning = { fg = U.get_group_color("states", "warning", c) }
end

---@private
---Setup treesitter highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_treesitter_hl(highlights, c)
  -- Variables
  highlights["@variable"] = { fg = U.get_group_color("syntax", "variable", c) }
  highlights["@variable.builtin"] = {
    fg = U.get_group_color("states", "error", c),
    bold = M.config.styles.bold,
    italic = M.config.styles.italic,
  }
  highlights["@variable.parameter"] =
    { fg = U.get_group_color("syntax", "constant", c), italic = M.config.styles.italic }
  highlights["@variable.parameter.builtin"] = {
    fg = U.get_group_color("syntax", "keyword", c),
    bold = M.config.styles.bold,
  }
  highlights["@variable.member"] = { fg = U.get_group_color("syntax", "operator", c) }

  -- Constants
  highlights["@constant"] = {
    fg = U.get_group_color("syntax", "constant", c),
    bold = M.config.styles.bold,
  }
  highlights["@constant.builtin"] = {
    fg = U.get_group_color("states", "error", c),
    bold = M.config.styles.bold,
  }
  highlights["@constant.macro"] = { fg = U.get_group_color("syntax", "constant", c) }

  -- Modules and labels
  highlights["@module"] = { fg = U.get_group_color("syntax", "variable", c), bold = M.config.styles.bold }
  highlights["@module.builtin"] = {
    fg = U.get_group_color("syntax", "variable", c),
    bold = M.config.styles.bold,
  }
  highlights["@label"] = { link = "Label" }

  -- Strings
  highlights["@string"] = { link = "String" }
  highlights["@string.regexp"] = { fg = U.get_group_color("syntax", "keyword", c) }
  highlights["@string.escape"] = { fg = U.get_group_color("syntax", "function_name", c) }
  highlights["@string.special"] = { link = "String" }
  highlights["@string.special.symbol"] = { link = "Identifier" }
  highlights["@string.special.url"] = { fg = U.get_group_color("syntax", "keyword", c) }

  -- Numbers and characters
  highlights["@character"] = { link = "Character" }
  highlights["@character.special"] = { link = "Character" }
  highlights["@boolean"] = { link = "Boolean" }
  highlights["@number"] = { link = "Number" }
  highlights["@number.float"] = { link = "Number" }
  highlights["@float"] = { link = "Number" }

  -- Types
  highlights["@type"] = { fg = U.get_group_color("syntax", "constant", c) }
  highlights["@type.builtin"] = {
    fg = U.get_group_color("syntax", "constant", c),
    bold = M.config.styles.bold,
    italic = M.config.styles.italic,
  }
  highlights["@type.definition"] = { link = "Type" }

  -- Attributes and properties
  highlights["@attribute"] = { fg = U.get_group_color("syntax", "type", c), italic = M.config.styles.italic }
  highlights["@attribute.builtin"] = {
    fg = U.get_group_color("syntax", "type", c),
    bold = M.config.styles.bold,
  }
  highlights["@property"] = { fg = U.get_group_color("syntax", "operator", c) }

  -- Functions
  highlights["@function"] = { link = "Function" }
  highlights["@function.builtin"] = {
    fg = U.get_group_color("syntax", "operator", c),
    bold = M.config.styles.bold,
  }
  highlights["@function.call"] = { link = "Function" }
  highlights["@function.macro"] = { link = "Function" }
  highlights["@function.method"] = { link = "Function" }
  highlights["@function.method.call"] = { link = "Function" }

  -- Operators and constructors
  highlights["@constructor"] = { fg = U.get_group_color("syntax", "comment", c) }
  highlights["@operator"] = { link = "Operator" }

  -- Keywords (comprehensive mapping)
  highlights["@keyword"] = { link = "Keyword" }
  highlights["@keyword.modifier"] = { link = "Function" }
  highlights["@keyword.type"] = { link = "Function" }
  highlights["@keyword.coroutine"] = { link = "Function" }
  highlights["@keyword.function"] = {
    fg = U.get_group_color("syntax", "keyword", c),
    bold = M.config.styles.bold,
  }
  highlights["@keyword.operator"] = { fg = U.get_group_color("syntax", "keyword", c) }
  highlights["@keyword.import"] = { link = "Include" }
  highlights["@keyword.repeat"] = { link = "Repeat" }
  highlights["@keyword.return"] = {
    fg = U.get_group_color("states", "error", c),
    bold = M.config.styles.bold,
  }
  highlights["@keyword.debug"] = { link = "Exception" }
  highlights["@keyword.exception"] = { link = "Exception" }
  highlights["@keyword.conditional"] = { link = "Conditional" }
  highlights["@keyword.conditional.ternary"] = { link = "Operator" }
  highlights["@keyword.directive"] = { link = "PreProc" }
  highlights["@keyword.directive.define"] = { link = "Define" }
  highlights["@keyword.export"] = {
    fg = U.get_group_color("syntax", "function_name", c),
    italic = M.config.styles.italic,
  }

  -- Punctuation
  highlights["@punctuation.delimiter.regex"] = { link = "@string.regexp" }
  highlights["@punctuation.delimiter"] = { link = "Delimiter" }
  highlights["@punctuation.bracket"] = { link = "@constructor" }
  highlights["@punctuation.special"] = { link = "Special" }

  -- Comments with semantic highlighting
  highlights["@comment"] = { link = "Comment" }
  highlights["@comment.documentation"] = { link = "Comment" }
  highlights["@comment.todo"] = {
    fg = U.get_group_color("syntax", "type", c),
    bg = U.blend(U.get_group_color("syntax", "type", c), U.get_group_color("backgrounds", "normal", c), 0.1),
    bold = M.config.styles.bold,
  }
  highlights["@comment.note"] = {
    fg = U.get_group_color("states", "info", c),
    bg = U.blend(U.get_group_color("states", "info", c), U.get_group_color("backgrounds", "normal", c), 0.1),
    bold = M.config.styles.bold,
  }
  highlights["@comment.warning"] = {
    fg = U.get_group_color("states", "warning", c),
    bg = U.blend(U.get_group_color("states", "warning", c), U.get_group_color("backgrounds", "normal", c), 0.1),
    bold = M.config.styles.bold,
  }
  highlights["@comment.error"] = {
    fg = U.get_group_color("states", "error", c),
    bg = U.blend(U.get_group_color("states", "error", c), U.get_group_color("backgrounds", "normal", c), 0.1),
    bold = M.config.styles.bold,
  }

  -- LSP semantic tokens
  highlights["@lsp.type.comment"] = {}
  highlights["@lsp.type.comment.c"] = { link = "@comment" }
  highlights["@lsp.type.comment.cpp"] = { link = "@comment" }
  highlights["@lsp.type.enum"] = { link = "@type" }
  highlights["@lsp.type.interface"] = { link = "@type" }
  highlights["@lsp.type.keyword"] = { link = "@keyword" }
  highlights["@lsp.type.namespace"] = { link = "@module" }
  highlights["@lsp.type.namespace.python"] = { link = "@variable" }
  highlights["@lsp.type.parameter"] = { link = "@variable.parameter" }
  highlights["@lsp.type.property"] = { link = "@property" }
  highlights["@lsp.type.variable"] = {} -- defer to treesitter for regular variables
  highlights["@lsp.type.variable.svelte"] = { link = "@variable" }
  highlights["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" }
  highlights["@lsp.typemod.operator.injected"] = { link = "@operator" }
  highlights["@lsp.typemod.string.injected"] = { link = "@string" }
  highlights["@lsp.typemod.variable.constant"] = { link = "@constant" }
  highlights["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" }
  highlights["@lsp.typemod.variable.injected"] = { link = "@variable" }
end

---@private
---Setup markdown highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_markdown_hl(highlights, c)
  -- Markdown headings with consistent color progression
  local heading_colors = {
    U.get_group_color("states", "error", c), -- H1: red
    U.get_group_color("syntax", "constant", c), -- H2: orange
    U.get_group_color("syntax", "type", c), -- H3: yellow
    U.get_group_color("states", "success", c), -- H4: green
    U.get_group_color("syntax", "operator", c), -- H5: cyan
    U.get_group_color("states", "info", c), -- H6: blue
  }

  for i = 1, 6 do
    highlights["markdownH" .. i] = {
      fg = heading_colors[i],
      bold = M.config.styles.bold,
    }
    highlights["markdownH" .. i .. "Delimiter"] = {
      fg = heading_colors[i],
      bold = M.config.styles.bold,
    }
    highlights["@markup.heading." .. i .. ".markdown"] = { link = "markdownH" .. i }
    highlights["@markup.heading." .. i .. ".marker.markdown"] = { link = "markdownH" .. i .. "Delimiter" }
  end

  -- Markdown links and formatting
  highlights.markdownLinkText = { link = "markdownUrl" }
  highlights.markdownUrl = {
    fg = U.get_group_color("syntax", "keyword", c),
    sp = U.get_group_color("syntax", "keyword", c),
    underline = true,
  }

  -- Markup elements
  highlights["@markup.strong"] = { bold = M.config.styles.bold }
  highlights["@markup.italic"] = { italic = M.config.styles.italic }
  highlights["@markup.strikethrough"] = { strikethrough = true }
  highlights["@markup.underline"] = { underline = true }
  highlights["@markup.heading"] = {
    fg = U.get_group_color("syntax", "operator", c),
    bold = M.config.styles.bold,
  }
  highlights["@markup.quote"] = { fg = U.get_group_color("syntax", "comment", c) }
  highlights["@markup.list"] = { fg = U.get_group_color("states", "error", c) }
  highlights["@markup.link"] = {
    fg = U.get_group_color("syntax", "keyword", c),
    underline = true,
  }
  highlights["@markup.raw"] = { fg = U.get_group_color("syntax", "string", c) }

  -- Diff markup
  highlights["@diff.plus"] = { fg = U.get_group_color("diff", "added", c) }
  highlights["@diff.minus"] = { fg = U.get_group_color("diff", "removed", c) }
  highlights["@diff.delta"] = { fg = U.get_group_color("states", "hint", c) }

  -- Tags
  highlights["@tag"] = { link = "Tag" }
  highlights["@tag.attribute"] = { fg = U.get_group_color("syntax", "keyword", c) }
  highlights["@tag.delimiter"] = { fg = U.get_group_color("syntax", "delimiter", c) }
end

---@private
---Setup diagnostics highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_diagnostics_hl(highlights, c)
  -- Diagnostic messages
  highlights.DiagnosticError = {
    fg = U.get_group_color("states", "error", c),
    bold = M.config.styles.bold,
  }
  highlights.DiagnosticWarn = {
    fg = U.get_group_color("states", "warning", c),
    bold = M.config.styles.bold,
  }
  highlights.DiagnosticInfo = {
    fg = U.get_group_color("states", "info", c),
    bold = M.config.styles.bold,
  }
  highlights.DiagnosticHint = {
    fg = U.get_group_color("states", "hint", c),
    bold = M.config.styles.bold,
  }
  highlights.DiagnosticDeprecated = {
    fg = U.get_group_color("foregrounds", "deprecated", c),
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
    sp = U.get_group_color("states", "error", c),
    undercurl = true,
  }
  highlights.DiagnosticUnderlineWarn = {
    sp = U.get_group_color("states", "warning", c),
    undercurl = true,
  }
  highlights.DiagnosticUnderlineInfo = {
    sp = U.get_group_color("states", "info", c),
    undercurl = true,
  }
  highlights.DiagnosticUnderlineHint = {
    sp = U.get_group_color("states", "hint", c),
    undercurl = true,
  }

  -- Diagnostic virtual text
  highlights.DiagnosticVirtualTextError = {
    fg = U.get_group_color("states", "error", c),
    bg = U.get_group_color("states", "error", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextWarn = {
    fg = U.get_group_color("states", "warning", c),
    bg = U.get_group_color("states", "warning", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextInfo = {
    fg = U.get_group_color("states", "info", c),
    bg = U.get_group_color("states", "info", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextHint = {
    fg = U.get_group_color("states", "hint", c),
    bg = U.get_group_color("states", "hint", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualTextOk = {
    fg = U.get_group_color("states", "success", c),
    bg = U.get_group_color("states", "success", c),
    blend = M.config.styles.blends.subtle,
  }

  -- Diagnostic virtual line
  highlights.DiagnosticVirtualLinesError = {
    fg = U.get_group_color("states", "error", c),
    bg = U.get_group_color("states", "error", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesWarn = {
    fg = U.get_group_color("states", "warning", c),
    bg = U.get_group_color("states", "warning", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesInfo = {
    fg = U.get_group_color("states", "info", c),
    bg = U.get_group_color("states", "info", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesHint = {
    fg = U.get_group_color("states", "hint", c),
    bg = U.get_group_color("states", "hint", c),
    blend = M.config.styles.blends.subtle,
  }
  highlights.DiagnosticVirtualLinesOk = {
    fg = U.get_group_color("states", "success", c),
    bg = U.get_group_color("states", "success", c),
    blend = M.config.styles.blends.subtle,
  }
end

---@private
---Setup LSP highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_lsp_hl(highlights, c)
  highlights.LspReferenceText = { bg = U.get_group_color("backgrounds", "light", c) }
  highlights.LspReferenceRead = { bg = U.get_group_color("backgrounds", "light", c) }
  highlights.LspReferenceWrite = { bg = U.get_group_color("backgrounds", "light", c) }
end

---@private
---Setup terminal highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_terminal_hl(highlights, c)
  highlights.Terminal = {
    fg = U.get_group_color("foregrounds", "normal", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.TermCursor = {
    fg = U.get_group_color("backgrounds", "normal", c),
    bg = U.get_group_color("states", "success", c),
  }
  highlights.TermCursorNC = {
    fg = U.get_group_color("backgrounds", "normal", c),
    bg = U.get_group_color("foregrounds", "dim", c),
  }
end

---@private
---Setup floating window highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_float_hl(highlights, c)
  highlights.FloatBorder = {
    fg = U.get_group_color("foregrounds", "dim", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
  }
  highlights.FloatShadow = { bg = U.get_group_color("backgrounds", "light", c) }
  highlights.FloatTitle = {
    fg = U.get_group_color("syntax", "operator", c),
    bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
    bold = M.config.styles.bold,
    italic = M.config.styles.italic,
  }
  highlights.FloatShadowThrough = { link = "FloatShadow" }
  highlights.WildMenu = { link = "IncSearch" }
  highlights.Directory = {
    fg = U.get_group_color("syntax", "operator", c),
    bold = M.config.styles.bold,
  }
  highlights.Title = {
    fg = U.get_group_color("syntax", "operator", c),
    bold = M.config.styles.bold,
  }
end

---@private
---Setup plugin highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_plugins_hl(highlights, c)
  -- Mini Icons - `https://github.com/nvim-mini/mini.icons`
  if U.has_plugin("nvim_mini_mini_icons") then
    highlights.MiniIconsAzure = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.MiniIconsBlue = { fg = U.get_group_color("states", "info", c) }
    highlights.MiniIconsCyan = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.MiniIconsGreen = { fg = U.get_group_color("states", "success", c) }
    highlights.MiniIconsGrey = { fg = U.get_group_color("foregrounds", "dim", c) }
    highlights.MiniIconsOrange = { fg = U.get_group_color("states", "warning", c) }
    highlights.MiniIconsPurple = { fg = U.get_group_color("states", "hint", c) }
    highlights.MiniIconsRed = { fg = U.get_group_color("states", "error", c) }
    highlights.MiniIconsYellow = { fg = U.get_group_color("syntax", "type", c) }
  end

  -- Mini Diff - `https://github.com/nvim-mini/mini.diff`
  if U.has_plugin("nvim_mini_mini_diff") then
    highlights.MiniDiffAdd = { link = "DiffAdd" }
    highlights.MiniDiffChange = { link = "DiffChange" }
    highlights.MiniDiffDelete = { link = "DiffDelete" }
    highlights.MiniDiffSignAdd = { link = "DiffAdd" }
    highlights.MiniDiffSignChange = { link = "DiffChange" }
    highlights.MiniDiffSignDelete = { link = "DiffDelete" }
  end

  -- Mini Files - `https://github.com/nvim-mini/mini.files`
  if U.has_plugin("nvim_mini_mini_files") then
    highlights.MiniFilesBorder = { link = "FloatBorder" }
    highlights.MiniFilesBorderModified = {
      fg = U.get_group_color("states", "warning", c),
      bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
    }
    highlights.MiniFilesCursorLine = { link = "CursorLine" }
    highlights.MiniFilesDirectory = { link = "Directory" }
    highlights.MiniFilesFile = { fg = U.get_group_color("foregrounds", "normal", c) }
    highlights.MiniFilesNormal = { link = "NormalFloat" }
    highlights.MiniFilesTitle = { link = "FloatTitle" }
  end

  -- Mini Pick - `https://github.com/nvim-mini/mini.pick`
  if U.has_plugin("nvim_mini_mini_pick") then
    highlights.MiniPickBorder = { link = "FloatBorder" }
    highlights.MiniPickBorderBusy = {
      fg = U.get_group_color("states", "warning", c),
      bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
    }
    highlights.MiniPickBorderText = { bg = U.get_group_color("foregrounds", "dim", c) }
    highlights.MiniPickIconDirectory = { link = "Directory" }
    highlights.MiniPickIconFile = { link = "MiniPickNormal" }
    highlights.MiniPickHeader = {
      fg = U.get_group_color("states", "hint", c),
      bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
    }
    highlights.MiniPickMatchCurrent = { link = "CursorLine" }
    highlights.MiniPickMatchMarked = { link = "Visual" }
    highlights.MiniPickMatchRanges = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.MiniPickNormal = { link = "NormalFloat" }
    highlights.MiniPickPreviewLine = { link = "CursorLine" }
    highlights.MiniPickPreviewRegion = { link = "IncSearch" }
    highlights.MiniPickPrompt = {
      bg = U.get_bg(U.get_group_color("backgrounds", "normal", c)),
      bold = M.config.styles.bold,
    }
  end

  -- Render Markdown - `https://github.com/MeanderingProgrammer/render-markdown.nvim`
  if U.has_plugin("meandering_programmer_render_markdown_nvim") then
    local heading_colors = {
      U.get_group_color("states", "error", c), -- H1: red
      U.get_group_color("syntax", "constant", c), -- H2: orange
      U.get_group_color("syntax", "type", c), -- H3: yellow
      U.get_group_color("states", "success", c), -- H4: green
      U.get_group_color("syntax", "operator", c), -- H5: cyan
      U.get_group_color("states", "info", c), -- H6: blue
    }

    for i = 1, 6 do
      highlights["RenderMarkdownH" .. i .. "Bg"] = {
        bg = heading_colors[i],
        blend = M.config.styles.blends.medium,
      }
    end

    highlights.RenderMarkdownBullet = { fg = U.get_group_color("syntax", "constant", c) }
    highlights.RenderMarkdownChecked = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.RenderMarkdownUnchecked = { fg = U.get_group_color("foregrounds", "dim", c) }
    highlights.RenderMarkdownCode = { bg = U.get_group_color("backgrounds", "dim", c) }
    highlights.RenderMarkdownCodeInline = {
      bg = U.get_group_color("backgrounds", "dim", c),
      fg = U.get_group_color("foregrounds", "normal", c),
    }
    highlights.RenderMarkdownQuote = { fg = U.get_group_color("foregrounds", "dim", c) }
    highlights.RenderMarkdownTableFill = { link = "Conceal" }
    highlights.RenderMarkdownTableHead = { fg = U.get_group_color("foregrounds", "dim", c) }
    highlights.RenderMarkdownTableRow = { fg = U.get_group_color("foregrounds", "dim", c) }
  end

  -- Undo Glow - `https://github.com/y3owk1n/undo-glow.nvim`
  if U.has_plugin("y3owk1n_undo_glow_nvim") then
    highlights.UgUndo = {
      bg = U.get_group_color("states", "error", c),
      blend = M.config.styles.blends.strong,
    }
    highlights.UgRedo = {
      bg = U.get_group_color("states", "success", c),
      blend = M.config.styles.blends.strong,
    }
    highlights.UgYank = {
      bg = U.get_group_color("syntax", "constant", c),
      blend = M.config.styles.blends.strong,
    }
    highlights.UgPaste = {
      bg = U.get_group_color("syntax", "operator", c),
      blend = M.config.styles.blends.strong,
    }
    highlights.UgSearch = {
      bg = U.get_group_color("states", "info", c),
      blend = M.config.styles.blends.strong,
    }
    highlights.UgComment = {
      bg = U.get_group_color("syntax", "type", c),
      blend = M.config.styles.blends.strong,
    }
    highlights.UgCursor = { bg = U.get_group_color("backgrounds", "light", c) }
  end

  -- Time Machine - `https://github.com/y3owk1n/time-machine.nvim`
  if U.has_plugin("y3owk1n_time_machine_nvim") then
    highlights.TimeMachineNormal = {
      link = "Normal",
    }
    highlights.TimeMachineBorder = {
      link = "FloatBorder",
    }
    highlights.TimeMachineCurrent = {
      bg = U.get_group_color("states", "info", c),
      blend = M.config.styles.blends.medium,
    }
    highlights.TimeMachineTimeline = {
      fg = U.get_group_color("states", "info", c),
    }
    highlights.TimeMachineTimelineAlt = {
      fg = U.get_group_color("foregrounds", "dark", c),
    }
    highlights.TimeMachineKeymap = {
      fg = U.get_group_color("states", "hint", c),
    }
    highlights.TimeMachineSeq = {
      fg = U.get_group_color("states", "error", c),
    }
    highlights.TimeMachineTag = {
      fg = U.get_group_color("states", "warning", c),
    }
    highlights.TimeMachineInfo = {
      fg = U.get_group_color("foregrounds", "dark", c),
    }
  end

  -- Blink Cmp - `https://github.com/saghen/blink.cmp`
  if U.has_plugin("saghen_blink_cmp") then
    highlights.BlinkCmpDoc = { link = "Normal" }
    highlights.BlinkCmpDocSeparator = { fg = U.get_group_color("foregrounds", "dim", c) }
    highlights.BlinkCmpDocBorder = { link = "FloatBorder" }
    highlights.BlinkCmpGhostText = { link = "Comment" }
    highlights.BlinkCmpLabel = { link = "Comment" }
    highlights.BlinkCmpLabelDeprecated = { fg = U.get_group_color("syntax", "deprecated", c), strikethrough = true }
    highlights.BlinkCmpLabelMatch = {
      fg = U.get_group_color("foregrounds", "normal", c),
      bold = M.config.styles.bold,
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
        fg = U.get_group_color(group_name, color_name, c),
      }
    end

    highlights.BlinkCmpMenuBorder = { link = "FloatBorder" }
  end

  -- Grug Far - `https://github.com/MagicDuck/grug-far.nvim`
  if U.has_plugin("magicduck_grug_far_nvim") then
    highlights.GrugFarHelpHeader = { fg = U.get_group_color("states", "info", c) }
    highlights.GrugFarHelpHeaderKey = { fg = U.get_group_color("syntax", "constant", c) }
    highlights.GrugFarHelpWinActionKey = { fg = U.get_group_color("syntax", "constant", c) }
    highlights.GrugFarHelpWinActionPrefix = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.GrugFarHelpWinActionText = { fg = U.get_group_color("states", "info", c) }
    highlights.GrugFarHelpWinHeader = { link = "FloatTitle" }
    highlights.GrugFarInputLabel = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.GrugFarInputPlaceholder = { link = "Comment" }
    highlights.GrugFarResultsActionMessage = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.GrugFarResultsChangeIndicator = { fg = U.get_group_color("diff", "changed", c) }
    highlights.GrugFarResultsRemoveIndicator = { fg = U.get_group_color("diff", "removed", c) }
    highlights.GrugFarResultsAddIndicator = { fg = U.get_group_color("diff", "added", c) }
    highlights.GrugFarResultsHeader = { fg = U.get_group_color("states", "info", c) }
    highlights.GrugFarResultsLineNo = { fg = U.get_group_color("states", "hint", c) }
    highlights.GrugFarResultsLineColumn = { link = "GrugFarResultsLineNo" }
    highlights.GrugFarResultsMatch = { link = "IncSearch" }
    highlights.GrugFarResultsPath = { fg = U.get_group_color("syntax", "operator", c) }
    highlights.GrugFarResultsStats = { fg = U.get_group_color("states", "hint", c) }
  end

  -- Which Key - `https://github.com/folke/which-key.nvim`
  if U.has_plugin("folke_which_key_nvim") then
    highlights.WhichKey = {
      fg = U.get_group_color("states", "info", c),
      bold = M.config.styles.bold,
    }
    highlights.WhichKeyBorder = { link = "FloatBorder" }
    highlights.WhichKeyDesc = { fg = U.get_group_color("foregrounds", "normal", c) }
    highlights.WhichKeyFloat = { link = "NormalFloat" }
    highlights.WhichKeyGroup = {
      fg = U.get_group_color("states", "hint", c),
      bold = M.config.styles.bold,
    }
    highlights.WhichKeyIcon = { fg = U.get_group_color("states", "info", c) }

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
    highlights.WhichKeySeparator = { fg = U.get_group_color("foregrounds", "dim", c) }
    highlights.WhichKeyTitle = { link = "FloatTitle" }
    highlights.WhichKeyValue = { fg = U.get_group_color("syntax", "constant", c) }
  end

  -- Flash - `https://github.com/folke/flash.nvim`
  if U.has_plugin("folke_flash_nvim") then
    highlights.FlashLabel = {
      fg = U.get_group_color("backgrounds", "normal", c),
      bg = U.get_group_color("states", "error", c),
    }
  end

  -- Gitsigns - `https://github.com/lewis6991/gitsigns.nvim`
  if U.has_plugin("lewis6991_gitsigns_nvim") then
    highlights.GitSignsAdd = { fg = U.get_group_color("git", "added", c) }
    highlights.GitSignsChange = { fg = U.get_group_color("git", "changed", c) }
    highlights.GitSignsDelete = { fg = U.get_group_color("git", "removed", c) }
    highlights.GitSignsUntracked = { fg = U.get_group_color("git", "untracked", c) }

    highlights.GitSignsAddLn = { link = "GitSignsAdd" }
    highlights.GitSignsChangeLn = { link = "GitSignsChange" }
    highlights.GitSignsDeleteLn = { link = "GitSignsDelete" }
    highlights.GitSignsUntrackedLn = { link = "GitSignsUntracked" }

    highlights.GitSignsAddInline = { link = "GitSignsAdd" }
    highlights.GitSignsChangeInline = { link = "GitSignsChange" }
    highlights.GitSignsDeleteInline = { link = "GitSignsDelete" }
    highlights.GitSignsUntrackedInline = { link = "GitSignsUntracked" }
  end
end

---@private
---Pre-compute highlights
---@param c table<Base16ProMax.Group.Alias, string>
---@return table<string, vim.api.keyset.highlight>
local function compute_highlights(c)
  if _computed_highlights_cache then
    return _computed_highlights_cache
  end

  ---@type table<string, vim.api.keyset.highlight>
  local highlights = {}

  -- Apply highlights in logical groups
  setup_editor_hl(highlights, c)
  setup_popup_hl(highlights, c)
  setup_statusline_hl(highlights, c)
  setup_message_hl(highlights, c)
  setup_diff_hl(highlights, c)
  setup_spelling_hl(highlights, c)
  setup_syntax_hl(highlights, c)
  setup_treesitter_hl(highlights, c)
  setup_markdown_hl(highlights, c)
  setup_diagnostics_hl(highlights, c)
  setup_lsp_hl(highlights, c)
  setup_terminal_hl(highlights, c)
  setup_float_hl(highlights, c)
  setup_plugins_hl(highlights, c)

  _computed_highlights_cache = highlights

  return highlights
end

---@private
---Apply all highlights
---@return nil
local function apply_highlights()
  local raw = M.config.colors or {}

  -- Validate that all required colors are provided
  local required_colors = _base16_raw or U.get_base16_raw()

  for _, color in ipairs(required_colors) do
    if not raw[color] then
      error("Missing color: " .. color .. ". Please provide all base16 colors in setup()")
    end
  end

  local c = U.add_semantic_palette(raw)

  local highlights = compute_highlights(c)

  -- Apply custom highlights from user configuration
  local highlight_groups = M.config.highlight_groups

  if type(M.config.highlight_groups) == "function" then
    local function_refs = {
      get_group_color_fn = U.get_group_color,
      get_bg_fn = U.get_bg,
      blend_fn = U.blend,
      styles_config = M.config.styles,
      colors = c,
    }

    highlight_groups = M.config.highlight_groups(function_refs)
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  if highlight_groups and next(highlight_groups) then
    ---@diagnostic disable-next-line: param-type-mismatch
    for group, highlight in pairs(highlight_groups) do
      local existing = highlights[group] or {}

      -- Handle link references
      while existing.link do
        existing = highlights[existing.link] or {}
      end

      -- Parse colors if they reference base16 colors
      local parsed = {}
      for key, value in pairs(highlight) do
        if key == "fg" or key == "bg" or key == "sp" then
          -- Allow referencing base16 colors like "red" or "base08"
          if type(value) == "string" and value:match("^base[0-9A-F][0-9A-F]$") then
            parsed[key] = raw[value]
          elseif type(value) == "string" and c[value] then
            parsed[key] = c[value] -- red, cyan, bg, fg, …
          else
            parsed[key] = value -- plain "#rrggbb" or whatever
          end
        else
          parsed[key] = value
        end
      end

      highlights[group] = parsed
    end
  end

  local before_highlight_fn = M.config.before_highlight

  -- Apply all highlights with blend processing
  for group, opts in pairs(highlights) do
    -- Call before_highlight hook if provided
    if before_highlight_fn then
      before_highlight_fn(group, opts, c)
    end

    -- Process blend values
    if opts.blend ~= nil and (opts.blend >= 0 and opts.blend <= 100) and opts.bg ~= nil then
      local bg_hex = c[opts.bg] or opts.bg
      ---@diagnostic disable-next-line: param-type-mismatch
      opts.bg = U.blend(bg_hex, opts.blend_on or c.bg, opts.blend / 100)
    end

    opts.blend = nil
    ---@diagnostic disable-next-line: inject-field
    opts.blend_on = nil

    ---@diagnostic disable-next-line: undefined-field
    if opts._nvim_blend ~= nil then
      ---@diagnostic disable-next-line: undefined-field
      opts.blend = opts._nvim_blend
    end

    if M.config.styles.use_cterm then
      if opts.fg then
        ---@diagnostic disable-next-line: param-type-mismatch
        opts.ctermfg = U.hex_to_cterm256(opts.fg)
      end
      if opts.bg then
        ---@diagnostic disable-next-line: param-type-mismatch
        opts.ctermbg = U.hex_to_cterm256(opts.bg)
      end
    end

    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- ------------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------------

---@type Base16ProMax.Config
M.config = {}

---@type Base16ProMax.Config
local default_config = {
  colors = {},
  highlight_groups = {},
  before_highlight = nil,
  styles = {
    italic = false,
    bold = false,
    transparency = false,
    use_cterm = false,
    dim_inactive_windows = false,
    blends = {
      subtle = 10,
      medium = 15,
      strong = 25,
      super = 50,
    },
  },
  plugins = {
    enable_all = false,
  },
  setup_globals = {
    terminal_colors = false,
    base16_gui_colors = false,
  },
  color_groups = {
    -- Background variations
    backgrounds = {
      normal = "bg",
      dim = "bg_dim",
      light = "bg_light",
      selection = "bg_light",
      cursor_line = function(function_refs)
        return function_refs.blend_fn(function_refs.colors.bg_light, function_refs.colors.bg, 0.6)
      end,
      cursor_column = function(function_refs)
        return function_refs.blend_fn(function_refs.colors.bg_dim, function_refs.colors.bg, 0.3)
      end,
    },

    -- Foreground variations
    foregrounds = {
      normal = "fg",
      dim = "fg_dim",
      dark = "fg_dark",
      light = "fg_light",
      bright = "fg_bright",
      comment = "fg_dark",
      line_number = function(function_refs)
        return function_refs.blend_fn(function_refs.colors.fg_dim, function_refs.colors.bg, 0.7)
      end,
    },

    -- Semantic colors for syntax
    syntax = {
      variable = "fg",
      constant = "orange",
      string = "green",
      number = "orange",
      boolean = "orange",
      keyword = "purple",
      function_name = "blue",
      type = "yellow",
      comment = "fg_dark",
      operator = "cyan",
      delimiter = "fg_dark",
      deprecated = "brown",
    },

    -- UI state colors
    states = {
      error = "red",
      warning = "yellow",
      info = "blue",
      hint = "cyan",
      success = "green",
    },

    -- Diff colors
    diff = {
      added = "green",
      removed = "red",
      changed = "orange",
      text = "blue",
    },

    -- Git colors
    git = {
      added = "green",
      removed = "red",
      changed = "orange",
      untracked = "brown",
    },

    -- Search and selection
    search = {
      match = "yellow",
      current = "orange",
      incremental = "orange",
    },
  },
}

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
--- - colors: *Required* - the 16 Base 16 hex codes
--- - highlight_groups: *Optional* - additional highlight groups to set
--- - before_highlight: *Optional* - callback to run before setting highlight groups
--- - styles: *Optional* - styling options
--- - plugins: *Optional* - enable/disable plugins
--- - setup_globals: *Optional* - setup vim.g globals
--- - color_groups: *Optional* - semantic color groups
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

  U.get_base16_aliases() -- Ensure base16 aliases are loaded
  U.get_base16_raw() -- Ensure base16 raw colors are loaded

  local valid, errors, warnings = V.validate_config(user_config or {})

  if warnings and next(warnings) then
    local warning_msg = V.format_errors({}, warnings)
    vim.notify(warning_msg, vim.log.levels.WARN)
  end

  if not valid then
    local error_msg = V.format_errors(errors, {})

    -- Show detailed error message
    vim.notify("base16-pro-max.nvim setup failed:\n" .. error_msg, vim.log.levels.ERROR)

    -- Don't proceed with invalid configuration
    error("base16-pro-max.nvim: Invalid configuration. See above for details.")
  end

  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})

  -- Additional runtime validation that can only be done after merging
  local runtime_errors = {}

  -- Validate that colors are provided
  if not next(M.config.colors) then
    runtime_errors["colors"] = "No colors provided. At least base00-base0F are required."
  end

  -- Validate color group functions at runtime (if possible)
  if M.config.color_groups then
    local test_colors = U.add_semantic_palette(M.config.colors or {})

    for group_name, group_config in pairs(M.config.color_groups) do
      if type(group_config) == "table" then
        for key, color_value in pairs(group_config) do
          if type(color_value) == "function" then
            local function_refs = {
              blend_fn = U.blend,
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
    local error_msg = V.format_errors(runtime_errors, {})
    vim.notify("base16-pro-max.nvim runtime validation failed:\n" .. error_msg, vim.log.levels.ERROR)
    error("base16-pro-max.nvim: Runtime validation failed. See above for details.")
  end

  if M.config.setup_globals.terminal_colors then
    vim.g.terminal_color_0 = M.config.colors.base00
    vim.g.terminal_color_1 = M.config.colors.base08
    vim.g.terminal_color_2 = M.config.colors.base0B
    vim.g.terminal_color_3 = M.config.colors.base0A
    vim.g.terminal_color_4 = M.config.colors.base0D
    vim.g.terminal_color_5 = M.config.colors.base0E
    vim.g.terminal_color_6 = M.config.colors.base0C
    vim.g.terminal_color_7 = M.config.colors.base05
    vim.g.terminal_color_8 = M.config.colors.base03
    vim.g.terminal_color_9 = M.config.colors.base09
    vim.g.terminal_color_10 = M.config.colors.base01
    vim.g.terminal_color_11 = M.config.colors.base02
    vim.g.terminal_color_12 = M.config.colors.base04
    vim.g.terminal_color_13 = M.config.colors.base06
    vim.g.terminal_color_14 = M.config.colors.base0F
    vim.g.terminal_color_15 = M.config.colors.base07
  end

  if M.config.setup_globals.base16_gui_colors then
    vim.g.base16_gui00 = M.config.colors.base00
    vim.g.base16_gui01 = M.config.colors.base01
    vim.g.base16_gui02 = M.config.colors.base02
    vim.g.base16_gui03 = M.config.colors.base03
    vim.g.base16_gui04 = M.config.colors.base04
    vim.g.base16_gui05 = M.config.colors.base05
    vim.g.base16_gui06 = M.config.colors.base06
    vim.g.base16_gui07 = M.config.colors.base07
    vim.g.base16_gui08 = M.config.colors.base08
    vim.g.base16_gui09 = M.config.colors.base09
    vim.g.base16_gui0A = M.config.colors.base0A
    vim.g.base16_gui0B = M.config.colors.base0B
    vim.g.base16_gui0C = M.config.colors.base0C
    vim.g.base16_gui0D = M.config.colors.base0D
    vim.g.base16_gui0E = M.config.colors.base0E
    vim.g.base16_gui0F = M.config.colors.base0F
  end

  did_setup = true

  M._invalidate_cache()
end

---@mod base16-pro-max.api API

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
  apply_highlights()
end

---Re-apply highlights (for benchmarking only)
function M._reapply_highlights()
  apply_highlights()
end

---Get the semantic color palette
---@return table<Base16ProMax.Group.Alias, string>|nil colors The semantic color palette, or nil if not set up
function M.colors()
  if not did_setup then
    vim.notify("base16-pro-max.nvim: Plugin not set up. Call setup() first.", vim.log.levels.ERROR)
    return nil
  end

  if not M.config.colors then
    vim.notify("base16-pro-max.nvim: No colors configured.", vim.log.levels.ERROR)
    return nil
  end

  -- Return cached colors if available
  if _color_cache then
    return _color_cache
  end

  -- Create and cache the semantic palette
  _color_cache = U.add_semantic_palette(M.config.colors)
  return _color_cache
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
  if not did_setup or not M.config.colors then
    return nil
  end

  -- Return a copy to prevent modification
  local raw = {}
  for k, v in pairs(M.config.colors) do
    raw[k] = v
  end
  return raw
end

---Get semantic color mapping
---@return table<Base16ProMax.Group.Alias, Base16ProMax.Group.Raw> mapping The semantic to raw color mapping
function M.color_mapping()
  return vim.deepcopy(base16_alias_map)
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
  return U.get_group_color(group, key, colors)
end

---Blend two colors together
---@param fg_color string Foreground color (hex)
---@param bg_color string Background color (hex)
---@param alpha number Alpha value between 0 (background) and 1 (foreground)
---@return string blended_color The blended color as hex
function M.blend_colors(fg_color, bg_color, alpha)
  return U.blend(fg_color, bg_color, alpha)
end

---Invalidate the color cache (useful when colors are updated)
---@private
function M._invalidate_cache()
  if not did_setup then
    return
  end

  _color_cache = nil
  _blend_cache = nil
  _cterm_cache = nil
  _hex_to_cterm_cache = {}
  _computed_highlights_cache = nil
end

---Validate color configuration
---@param colors table<Base16ProMax.Group.Raw, string> The colors to validate
---@return boolean valid True if all required colors are present
---@return string[] missing Array of missing color keys
function M.validate_colors(colors)
  local required_colors = _base16_raw or U.get_base16_raw()

  local missing = {}
  for _, color in ipairs(required_colors) do
    if not colors[color] then
      table.insert(missing, color)
    end
  end

  return #missing == 0, missing
end

return M
