local M = {}

---@type table<number, { r: integer, g: integer, b: integer }>|nil
local _cterm_cache = nil

---@type table<string, integer|"NONE">
local _hex_to_cterm_cache = {}

---@private
---Build cterm colors
---@return table<number, { r: integer, g: integer, b: integer }>
local function build_cterm_colors()
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
local function get_rgb_to_cterm()
  if not _cterm_cache then
    _cterm_cache = build_cterm_colors()
  end
  return _cterm_cache
end

---Find the nearest cterm256 color index by Manhattan distance
---@param rgb {r: integer, g: integer, b: integer}
---@return integer|nil
function M.get_nearest_cterm(rgb)
  local nearest_id = nil
  local nearest_distance = math.huge

  for id, c in pairs(get_rgb_to_cterm()) do
    local distance = math.abs(rgb.r - c.r) + math.abs(rgb.g - c.g) + math.abs(rgb.b - c.b)
    if distance < nearest_distance then
      nearest_id, nearest_distance = id, distance
    end
  end
  return nearest_id
end

---Get a cterm256 color from a hex color
---@param hex string The hex color
---@return integer|"NONE"|nil cterm256 The cterm256 color
function M.get_cache(hex)
  if _hex_to_cterm_cache[hex] then
    return _hex_to_cterm_cache[hex]
  end
end

---Set a hex color to a cterm256 color
---@param hex string The hex color
---@param cterm256 integer|"NONE"|nil The cterm256 color
function M.set_cache(hex, cterm256)
  _hex_to_cterm_cache[hex] = cterm256
end

---Invalidate the cterm256 cache
function M._invalidate_cache()
  _cterm_cache = nil
  _hex_to_cterm_cache = {}
end

return M
