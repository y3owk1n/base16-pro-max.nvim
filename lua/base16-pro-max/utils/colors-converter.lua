local M = {}

---@private
---Convert a color name to RGB values
---@param hex string
---@return {r: integer, g: integer, b: integer}|nil rgb The RGB values, or nil if not a valid hex color
function M.hex_to_rgb(hex)
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
---Convert a hex color to a cterm256 color
---@param hex string The hex color
---@return integer|"NONE" cterm256 The cterm256 color
function M.hex_to_cterm256(hex)
  if hex == "NONE" then
    return "NONE"
  end

  local cterm = require("base16-pro-max.utils.cterm")

  local cterm_cache = cterm.get_cache(hex)

  if cterm_cache then
    return cterm_cache
  end

  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  if not r or not g or not b then
    cterm.set_cache(hex, "NONE")
    return "NONE"
  end

  local nearest = cterm.get_nearest_cterm({ r = r, g = g, b = b }) or "NONE"

  cterm.set_cache(hex, nearest)

  return nearest
end

return M
