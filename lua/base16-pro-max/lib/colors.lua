local base16_alias_map = require("base16-pro-max.lib.base16").base16_alias_map

local M = {}

---@type table<string, string>|nil
local _color_cache = nil

---@private
---Add semantic aliases to the raw colors
---@param raw_colors table<Base16ProMax.Group.Raw, string>
---@return table<Base16ProMax.Group.Alias, string>
function M.add_semantic_palette(raw_colors)
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
function M.get_bg(normal_bg, transparent_override)
  if require("base16-pro-max.config").config.styles.transparency then
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
function M.get_group_color(group, key, c)
  local color_group = require("base16-pro-max.config").config.color_groups[group]
  if not color_group or not color_group[key] then
    return c.fg -- fallback
  end

  local color_value = color_group[key]
  if type(color_value) == "function" then
    local function_refs = {
      blend_fn = require("base16-pro-max.utils.colors-manipulation").blend,
      colors = c,
    }
    return color_value(function_refs)
  else
    return c[color_value]
  end
end

function M.get_semantic_colors()
  local config = require("base16-pro-max.config").config

  -- Return cached colors if available
  if _color_cache then
    return _color_cache
  end

  -- Create and cache the semantic palette
  _color_cache = require("bas16-pro-max.lib.colors").add_semantic_palette(config.colors)
  return _color_cache
end

function M._invalidate_cache()
  _color_cache = nil
end

return M
