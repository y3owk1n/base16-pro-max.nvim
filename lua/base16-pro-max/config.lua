local M = {}

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

---Setup the config with deep merge
---@param user_config? Base16ProMax.Config
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

return M
