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

local blend = require("base16-pro-max.utils.colors-manipulation").blend
local get_base16_aliases = require("base16-pro-max.lib.base16").get_base16_aliases
local get_base16_raw = require("base16-pro-max.lib.base16").get_base16_raw
local get_bg = require("base16-pro-max.lib.colors").get_bg
local get_group_color = require("base16-pro-max.lib.colors").get_group_color

local validator = require("base16-pro-max.validator")

-- ------------------------------------------------------------------
-- States & caches
-- ------------------------------------------------------------------

local did_setup = false

---@type table<string, string>|nil
local _color_cache = nil

---@type table<string, vim.api.keyset.highlight>|nil
local _computed_highlights_cache = nil

-- ------------------------------------------------------------------
-- Highlight Setup Functions
-- ------------------------------------------------------------------

---@private
---Setup plugin highlights
---@param highlights table<string, vim.api.keyset.highlight>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_plugins_hl(highlights, c)
  local function_refs = {
    get_group_color_fn = get_group_color,
    get_bg_fn = get_bg,
    blend_fn = blend,
    styles_config = M.config.styles,
    colors = c,
  }

  require("base16-pro-max.plugins").setup(highlights, function_refs)
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
  require("base16-pro-max.highlights.editor").setup(highlights, c)
  require("base16-pro-max.highlights.popup").setup(highlights, c)
  require("base16-pro-max.highlights.statusline").setup(highlights, c)
  require("base16-pro-max.highlights.message").setup(highlights, c)
  require("base16-pro-max.highlights.diff").setup(highlights, c)
  require("base16-pro-max.highlights.spelling").setup(highlights, c)
  require("base16-pro-max.highlights.syntax").setup(highlights, c)
  require("base16-pro-max.highlights.treesitter").setup(highlights, c)
  require("base16-pro-max.highlights.markdown").setup(highlights, c)
  require("base16-pro-max.highlights.diagnostic").setup(highlights, c)
  require("base16-pro-max.highlights.lsp").setup(highlights, c)
  require("base16-pro-max.highlights.terminal").setup(highlights, c)
  require("base16-pro-max.highlights.float").setup(highlights, c)

  -- Setup plugins
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
  local required_colors = get_base16_raw()

  for _, color in ipairs(required_colors) do
    if not raw[color] then
      error("Missing color: " .. color .. ". Please provide all base16 colors in setup()")
    end
  end

  local c = require("base16-pro-max.lib.colors").add_semantic_palette(raw)

  local highlights = compute_highlights(c)

  -- Apply custom highlights from user configuration
  local highlight_groups = M.config.highlight_groups

  if type(M.config.highlight_groups) == "function" then
    local function_refs = {
      get_group_color_fn = get_group_color,
      get_bg_fn = get_bg,
      blend_fn = blend,
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
      opts.bg = blend(bg_hex, opts.blend_on or c.bg, opts.blend / 100)
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
      local hex_to_cterm256 = require("base16-pro-max.utils.colors-converter").hex_to_cterm256
      if opts.fg then
        ---@diagnostic disable-next-line: param-type-mismatch
        opts.ctermfg = hex_to_cterm256(opts.fg)
      end
      if opts.bg then
        ---@diagnostic disable-next-line: param-type-mismatch
        opts.ctermbg = hex_to_cterm256(opts.bg)
      end
    end

    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- ------------------------------------------------------------------
-- Public API
-- ------------------------------------------------------------------

---@private
---@type Base16ProMax.Config
---@diagnostic disable-next-line: missing-fields
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
      border = "fg_dim",
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

    -- Markdown
    markdown = {
      heading1 = "red",
      heading2 = "orange",
      heading3 = "yellow",
      heading4 = "green",
      heading5 = "cyan",
      heading6 = "blue",
    },

    -- Modes
    modes = {
      normal = "blue",
      insert = "green",
      visual = "yellow",
      visual_line = "yellow",
      replace = "cyan",
      command = "red",
      other = "brown",
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

  get_base16_aliases() -- Ensure base16 aliases are loaded
  get_base16_raw() -- Ensure base16 raw colors are loaded

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

  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})

  -- Additional runtime validation that can only be done after merging
  local runtime_errors = {}

  -- Validate that colors are provided
  if not next(M.config.colors) then
    runtime_errors["colors"] = "No colors provided. At least base00-base0F are required."
  end

  -- Validate color group functions at runtime (if possible)
  if M.config.color_groups then
    local test_colors = require("base16-pro-max.lib.colors").add_semantic_palette(M.config.colors or {})

    for group_name, group_config in pairs(M.config.color_groups) do
      if type(group_config) == "table" then
        for key, color_value in pairs(group_config) do
          if type(color_value) == "function" then
            local function_refs = {
              blend_fn = blend,
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
  apply_highlights()
end

---@private
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
  _color_cache = require("bas16-pro-max.lib.colors").add_semantic_palette(M.config.colors)
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
  return get_group_color(group, key, colors)
end

---Invalidate the color cache (useful when colors are updated)
---@private
function M._invalidate_cache()
  if not did_setup then
    return
  end

  local cterm = require("base16-pro-max.utils.cterm")
  local manipulation = require("base16-pro-max.utils.colors-manipulation")

  cterm._invalidate_cache()
  manipulation._invalidate_cache()

  _color_cache = nil
  _computed_highlights_cache = nil
end

---Validate color configuration
---@param colors table<Base16ProMax.Group.Raw, string> The colors to validate
---@return boolean valid True if all required colors are present
---@return string[] missing Array of missing color keys
function M.validate_colors(colors)
  local required_colors = get_base16_raw()

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
