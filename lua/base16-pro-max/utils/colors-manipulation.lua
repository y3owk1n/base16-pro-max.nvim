local M = {}

---@type table<string, string>|nil
local _blend_cache = nil

---@param fg string Foreground color
---@param bg string Background color
---@param alpha number Between 0 (background) and 1 (foreground)
---@return string blended_color The blended color as hex
function M.blend(fg, bg, alpha)
  local cache_key = fg .. bg .. alpha

  if not _blend_cache then
    _blend_cache = {}
  end

  if _blend_cache[cache_key] then
    return _blend_cache[cache_key]
  end

  local hex_to_rgb = require("base16-pro-max.utils.colors-converter").hex_to_rgb

  local fg_rgb = hex_to_rgb(fg)
  local bg_rgb = hex_to_rgb(bg)

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

---Invalidate the cache
function M._invalidate_cache()
  _blend_cache = nil
end

return M
