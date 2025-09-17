local M = {}

local get_base16_aliases = require("base16-pro-max.lib.base16").get_base16_aliases
local get_base16_raw = require("base16-pro-max.lib.base16").get_base16_raw

---@private
---Check if a value is a valid hex color
---@param color string The color value to validate
---@return boolean valid True if valid hex color
---@return string? error Error message if invalid
local function is_valid_hex_color(color)
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
local function is_valid_blend(blend_value)
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
local function is_valid_plugin_name(plugin_name)
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
local function is_valid_color_group_color(color, group_name, key_name)
  local base16_aliases = get_base16_aliases()
  local base16_raw = get_base16_raw()

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
    local valid, err = is_valid_hex_color(color)
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

---Validate colors configuration
---@param colors table<Base16ProMax.Group.Raw, string> Colors configuration
---@return boolean valid True if valid
---@return table<string, string> errors Map of error keys to messages
function M.validate_colors(colors)
  local errors = {}

  if not colors or type(colors) ~= "table" then
    errors.colors = "must be a table"
    return false, errors
  end

  local required_colors = get_base16_raw()

  -- Check for missing colors
  for _, color_key in ipairs(required_colors) do
    if not colors[color_key] then
      errors["colors." .. color_key] = "required base16 color is missing"
    else
      local valid, err = is_valid_hex_color(colors[color_key])
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
function M.validate_styles(styles)
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
          local valid, err = is_valid_blend(styles.blends[key])
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
function M.validate_setup_globals(setup_globals)
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
function M.validate_plugins(plugins)
  local errors = {}

  if not plugins then
    return true, errors -- plugins is optional
  end

  if type(plugins) ~= "table" then
    errors.plugins = "must be a table"
    return false, errors
  end

  local plugin_map = require("base16-pro-max.plugins").plugin_map or {}

  -- Validate known plugin options
  ---@type string[]
  local known_plugins = vim.tbl_extend("force", { "enable_all" }, plugin_map)

  for key, value in pairs(plugins) do
    -- Validate plugin name format
    local valid_name, name_err = is_valid_plugin_name(key)
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
function M.validate_color_groups(color_groups)
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
    foregrounds = { "normal", "dim", "dark", "light", "bright", "comment", "line_number", "border" },
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
      "deprecated",
    },
    states = { "error", "warning", "info", "hint", "success" },
    diff = { "added", "removed", "changed", "text" },
    git = { "added", "removed", "changed", "untracked" },
    search = { "match", "current", "incremental" },
    markdown = { "heading1", "heading2", "heading3", "heading4", "heading5", "heading6" },
    modes = { "normal", "insert", "visual", "visual_line", "replace", "command", "other" },
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
            local valid, err = is_valid_color_group_color(value, group_name, key)
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
function M.validate_highlight_groups(highlight_groups)
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
            local base16_aliases = get_base16_aliases()
            local base16_raw = get_base16_raw()
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
              local valid, err = is_valid_hex_color(value)
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
function M.validate_before_highlight(before_highlight)
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
function M.validate_config(config)
  local errors = {}
  local warnings = {}

  if not config or type(config) ~= "table" then
    errors.config = "configuration must be a table"
    return false, errors, warnings
  end

  -- Validate each section
  local sections = {
    { key = "colors", validator = M.validate_colors },
    { key = "styles", validator = M.validate_styles },
    { key = "plugins", validator = M.validate_plugins },
    { key = "setup_globals", validator = M.validate_setup_globals },
    { key = "color_groups", validator = M.validate_color_groups },
    { key = "highlight_groups", validator = M.validate_highlight_groups },
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
  local valid, err = M.validate_before_highlight(config.before_highlight)
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
function M.format_errors(errors, warnings)
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

return M
