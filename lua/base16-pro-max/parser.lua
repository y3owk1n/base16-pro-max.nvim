---@mod base16-pro-max.parser YAML parser for base16-pro-max

---@brief [[
---# Module setup ~
---
---This module will be setup automatically if the module is required.
---There's no need to call `setup()` manually.
---
---# Usage ~
---
--->lua
---  local yaml_parser = require("base16-pro-max.parser")
---
---  -- Load from YAML file
---  local colors = yaml_parser.get_base16_colors("~/schemes/gruvbox.yaml")
---
---  -- Mix YAML colors with manual overrides
---  local colors = vim.tbl_extend("force",
---    yaml_parser.get_base16_colors("~/schemes/base.yaml"),
---    {
---      base08 = "#ff0000", -- Override red
---      base0B = "#00ff00", -- Override green
---    }
---  )
---
---  -- Conditional loading
---  local colors = {}
---  local condition = some_condition() -- e.g., vim.fn.filereadable
---  if condition then
---    colors = yaml_parser.get_base16_colors("~/schemes/custom.yaml")
---  else
---    -- Fallback to manual colors
---    colors = {
---      base00 = "#1f1f28", base01 = "#2a2a37", -- ...
---    }
---  end
---
---  require("base16-pro-max").setup({ colors = colors })
---<
---
---# Cache Management ~
---
---Cache is saved to `vim.fn.stdpath("cache") .. "/base16_cache"` with filename of `schemes_cache.lua`
---
--->lua
---  local yaml_parser = require("base16-pro-max.parser")
---
---  -- Clear all cached data
---  yaml_parser.clear_cache()
---
---  -- Get cache statistics
---  local stats = yaml_parser.get_cache_stats()
---  print(vim.inspect(stats))
---<
---
---@brief ]]

local M = {}

---@type table<string, table<string, string>>
local _scheme_cache = {}
---@type table<string, integer>
local _file_mtime_cache = {}

--Cache file location
local cache_dir = vim.fn.stdpath("cache") .. "/base16_cache"
local cache_file = cache_dir .. "/schemes_cache.lua"

---Ensure cache directory exists
---@return nil
local function ensure_cache_dir()
  vim.fn.mkdir(cache_dir, "p")
end

---Load persistent cache from disk
---@return boolean
local function load_persistent_cache()
  if vim.fn.filereadable(cache_file) == 1 then
    local success, cache_data = pcall(dofile, cache_file)
    if success and cache_data and type(cache_data) == "table" then
      _scheme_cache = cache_data.schemes or {}
      _file_mtime_cache = cache_data.mtimes or {}
      return true
    end
  end
  return false
end

---Save cache to disk as Lua code
---Generate Lua code manually for better performance than vim.inspect
local function save_persistent_cache()
  ensure_cache_dir()

  local lines = { "return {" }

  -- Add schemes
  table.insert(lines, "  schemes = {")
  for path, scheme in pairs(_scheme_cache) do
    table.insert(lines, string.format("    [%q] = {", path))
    for key, value in pairs(scheme) do
      table.insert(lines, string.format("      [%q] = %q,", key, value))
    end
    table.insert(lines, "    },")
  end
  table.insert(lines, "  },")

  -- Add mtimes
  table.insert(lines, "  mtimes = {")
  for path, mtime in pairs(_file_mtime_cache) do
    table.insert(lines, string.format("    [%q] = %d,", path, mtime))
  end
  table.insert(lines, "  },")

  table.insert(lines, "}")

  local success = pcall(function()
    vim.fn.writefile(lines, cache_file)
  end)

  return success
end

---Normalize a color string into "#rrggbb" form
---@param val string
---@return string
local function normalize_hex(val)
  val = val:gsub("^#", "")
  if val:match("^[0-9a-fA-F]+$") and #val == 6 then
    return "#" .. val:lower()
  end
  return val
end

---Check if file has been modified since last cache
---@param path string
---@return boolean
local function is_file_modified(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return false
  end

  local current_mtime = stat.mtime.sec
  local cached_mtime = _file_mtime_cache[path]

  if not cached_mtime or current_mtime > cached_mtime then
    _file_mtime_cache[path] = current_mtime
    return true
  end

  return false
end

---@private
---Parse Base16 YAML with persistent caching
---@param path string
---@return table
function M.parse_base16_yaml(path)
  local expanded_path = vim.fn.expand(path)

  -- Check if we have cached data and file hasn't changed
  if _scheme_cache[expanded_path] and not is_file_modified(expanded_path) then
    return _scheme_cache[expanded_path]
  end

  local stat = vim.uv.fs_stat(expanded_path)
  if not stat then
    _scheme_cache[expanded_path] = {}
    return {}
  end

  local fd = vim.uv.fs_open(expanded_path, "r", 438)
  if not fd then
    _scheme_cache[expanded_path] = {}
    return {}
  end

  local content = vim.uv.fs_read(fd, stat.size, 0)
  vim.uv.fs_close(fd)

  if not content then
    _scheme_cache[expanded_path] = {}
    return {}
  end

  local result = {}

  for line in content:gmatch("[^\r\n]+") do
    -- Fast check for meaningful lines
    local first_char = line:sub(1, 1)
    if
      first_char ~= "#" and first_char ~= " " and first_char ~= "\t"
      or (first_char == " " or first_char == "\t") and not line:match("^%s*#")
    then
      local key, val = line:match("^%s*([%w_]+):%s*[\"']?([^\"'%s][^\"'#]*)")
      if key and val then
        -- Quick trim without gsub when possible
        local trimmed = val:match("^%s*(.-)%s*$") or val
        result[key] = normalize_hex(trimmed)
      end
    end
  end

  _scheme_cache[expanded_path] = result

  -- Async save to avoid blocking
  if next(result) then
    vim.schedule(function()
      save_persistent_cache()
    end)
  end

  return result
end

---Get Base16 colors with optimized filtering
---@param path string
---@return table
function M.get_base16_colors(path)
  -- make sure its a yaml or yml file
  if not path:match("%.ya?ml$") then
    error("Only YAML/YML files are supported")
  end

  local scheme = M.parse_base16_yaml(path)
  local palette = {}

  -- Pre-compile pattern for better performance with many calls
  for k, v in pairs(scheme) do
    -- Fastest check: length first, then string comparison
    if #k == 6 and k:sub(1, 4) == "base" then
      local suffix = k:sub(5, 6)
      -- Validate it's a proper base16 key (base00-base0F)
      if suffix:match("^0[0-9a-fA-F]$") then
        palette[k] = v
      end
    end
  end

  return palette
end

---Clear all caches
---@return nil
function M.clear_cache()
  _scheme_cache = {}
  _file_mtime_cache = {}
  pcall(vim.fn.delete, cache_file)
end

---Get cache statistics
function M.get_cache_stats()
  return {
    cached_schemes = vim.tbl_count(_scheme_cache),
    cache_file_exists = vim.fn.filereadable(cache_file) == 1,
    cache_file_path = cache_file,
  }
end

---@private
---Initialize the module
---@return nil
function M.setup()
  load_persistent_cache()
end

-- Auto-initialize when module is loaded
M.setup()

---Save cache on VimLeavePre to ensure it persists
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    save_persistent_cache()
  end,
  desc = "Save Base16 scheme cache before exit",
})

return M
