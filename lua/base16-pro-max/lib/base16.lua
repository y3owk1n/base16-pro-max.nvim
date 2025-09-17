local M = {}

---@type Base16ProMax.Group.Alias[]|nil
local _base16_aliases = nil

---@type Base16ProMax.Group.Raw[]|nil
local _base16_raw = nil

---Reference `https://github.com/tinted-theming/home/blob/main/styling.md`
---@type table<Base16ProMax.Group.Alias, Base16ProMax.Group.Raw>
M.base16_alias_map = {
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

---Check if a color name is a valid base16 alias
---@param color_name string
---@return boolean
local function is_base16_alias(color_name)
  return M.base16_alias_map[color_name] ~= nil
end

---Check if a color name is a valid base16 raw color
---@param color_name string
---@return boolean
local function is_base16_raw(color_name)
  for _, raw_color in pairs(M.base16_alias_map) do
    if raw_color == color_name then
      return true
    end
  end
  return false
end

---Get array of all base16 semantic aliases
---@return Base16ProMax.Group.Alias[]
function M.get_base16_aliases()
  if not _base16_aliases then
    _base16_aliases = vim.tbl_keys(M.base16_alias_map)
    table.sort(_base16_aliases) -- For consistent ordering
  end
  return _base16_aliases
end

---Get array of all base16 raw color names
---@return Base16ProMax.Group.Raw[]
function M.get_base16_raw()
  if not _base16_raw then
    -- Create sorted list of unique raw values
    local raw_set = {}
    for _, raw_color in pairs(M.base16_alias_map) do
      raw_set[raw_color] = true
    end

    _base16_raw = vim.tbl_keys(raw_set)
    table.sort(_base16_raw) -- For consistent ordering
  end
  return _base16_raw
end

---Check if a color name is any valid base16 reference (alias or raw)
---@param color_name string
---@return boolean
function M.is_valid_base16_color(color_name)
  return is_base16_alias(color_name) or is_base16_raw(color_name)
end

---Get the raw color for an alias, or return the input if it's already raw
---@param color_name string
---@return string|nil
function M.resolve_color_name(color_name)
  -- If it's an alias, return the raw color
  if M.base16_alias_map[color_name] then
    return M.base16_alias_map[color_name]
  end

  -- If it's already a raw color, return it
  if is_base16_raw(color_name) then
    return color_name
  end

  -- Not a base16 color
  return nil
end

return M
