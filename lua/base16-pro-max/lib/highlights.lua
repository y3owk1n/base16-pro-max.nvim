local M = {}

---@type table<string, Base16ProMax.HighlightOpts>|nil
local _computed_highlights_cache = nil

local blend = require("base16-pro-max.utils.colors-manipulation").blend
local get_bg = require("base16-pro-max.lib.colors").get_bg
local get_group_color = require("base16-pro-max.lib.colors").get_group_color
local get_base16_raw = require("base16-pro-max.lib.base16").get_base16_raw

---@private
---Setup plugin highlights
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
local function setup_plugins_hl(highlights, c)
  local config = require("base16-pro-max.config").config

  local function_refs = {
    get_group_color_fn = get_group_color,
    get_bg_fn = get_bg,
    blend_fn = blend,
    styles_config = config.styles,
    colors = c,
  }

  require("base16-pro-max.plugins").setup(highlights, function_refs)
end

---@private
---Pre-compute highlights
---@param c table<Base16ProMax.Group.Alias, string>
---@return table<string, Base16ProMax.HighlightOpts>
local function compute_highlights(c)
  if _computed_highlights_cache then
    return _computed_highlights_cache
  end

  ---@type table<string, Base16ProMax.HighlightOpts>
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
function M.apply_highlights()
  local config = require("base16-pro-max.config").config

  local raw = config.colors or {}

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
  local highlight_groups = config.highlight_groups

  if type(config.highlight_groups) == "function" then
    local function_refs = {
      get_group_color_fn = get_group_color,
      get_bg_fn = get_bg,
      blend_fn = blend,
      styles_config = M.config.styles,
      colors = c,
    }

    highlight_groups = config.highlight_groups(function_refs)
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  if highlight_groups and next(highlight_groups) then
    ---@diagnostic disable-next-line: param-type-mismatch
    for group, highlight in pairs(highlight_groups) do
      local existing = highlights[group] or {}

      -- Handle link references
      ---@diagnostic disable-next-line: undefined-field
      while existing.link do
        ---@diagnostic disable-next-line: undefined-field
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

  local before_highlight_fn = config.before_highlight

  -- Apply all highlights with blend processing
  for group, opts in pairs(highlights) do
    -- Call before_highlight hook if provided
    if before_highlight_fn then
      before_highlight_fn(group, opts, c)
    end

    -- Process blend values
    ---@diagnostic disable-next-line: undefined-field
    if opts.blend ~= nil and (opts.blend >= 0 and opts.blend <= 100) and opts.bg ~= nil then
      ---@diagnostic disable-next-line: undefined-field
      local bg_hex = c[opts.bg] or opts.bg
      ---@diagnostic disable-next-line: inject-field,param-type-mismatch
      opts.bg = blend(bg_hex, opts.blend_on or c.bg, opts.blend / 100)
    end

    ---@diagnostic disable-next-line: inject-field
    opts.blend = nil
    ---@diagnostic disable-next-line: inject-field
    opts.blend_on = nil

    ---@diagnostic disable-next-line: undefined-field
    if opts._nvim_blend ~= nil then
      ---@diagnostic disable-next-line: inject-field
      opts.blend = opts._nvim_blend
    end

    if config.styles.use_cterm then
      local hex_to_cterm256 = require("base16-pro-max.utils.colors-converter").hex_to_cterm256
      ---@diagnostic disable-next-line: undefined-field
      if opts.fg then
        ---@diagnostic disable-next-line: inject-field
        opts.ctermfg = hex_to_cterm256(opts.fg)
      end
      ---@diagnostic disable-next-line: undefined-field
      if opts.bg then
        ---@diagnostic disable-next-line: inject-field
        opts.ctermbg = hex_to_cterm256(opts.bg)
      end
    end

    vim.api.nvim_set_hl(0, group, opts)
  end
end

function M._invalidate_cache()
  _computed_highlights_cache = nil
end

return M
