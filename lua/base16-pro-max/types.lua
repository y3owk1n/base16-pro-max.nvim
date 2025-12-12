local M = {}

---@mod base16-pro-max.types Types

---@class Base16ProMax.Config
---@field colors? table<Base16ProMax.Group.Raw, string> Colors to override
---@field styles? Base16ProMax.Config.Styles Styles to override
---@field highlight_groups? Base16ProMax.Config.HighlightGroups.Table|Base16ProMax.Config.HighlightGroups.Function  Additional highlight groups to set
---@field before_highlight? fun(group: string, opts: Base16ProMax.HighlightOpts, c: table<Base16ProMax.Group.Alias, string>): nil Callback to run before setting highlight groups
---@field plugins? Base16ProMax.Config.Plugins Enable/disable plugins
---@field color_groups? Base16ProMax.Config.ColorGroups Color groups to override
---@field setup_globals? Base16ProMax.Config.SetupGlobals Setup globals

---@class Base16ProMax.HighlightOpts
---@field fg? string Foreground color
---@field bg? string Background color
---@field sp? string Special color
---@field blend? number Blend value (0-100)
---@field bold? boolean Bold text
---@field italic? boolean Italic text
---@field underline? boolean Underline text
---@field undercurl? boolean Undercurl text
---@field underdouble? boolean Double underline text
---@field underdotted? boolean Dotted underline text
---@field underdashed? boolean Dashed underline text
---@field strikethrough? boolean Strikethrough text
---@field reverse? boolean Reverse video
---@field standout? boolean Standout mode
---@field link? string Link to another highlight group
---@field blend_on? string Background to blend on
---@field _nvim_blend? number Internal blend value
---@field ctermfg? number|"NONE" cterm foreground
---@field ctermbg? number|"NONE" cterm background

---@alias Base16ProMax.Config.HighlightGroups.Table table<string, Base16ProMax.HighlightOpts>
---@alias Base16ProMax.Config.HighlightGroups.Function fun(function_refs: Base16ProMax.Config.HighlightGroups.FunctionRefs): Base16ProMax.Config.HighlightGroups.Table

---@class Base16ProMax.Config.HighlightGroups.FunctionRefs
---@field get_group_color_fn fun(group: string, key: string, c: table<Base16ProMax.Group.Alias, string>): string
---@field get_bg_fn fun(bg: string): string
---@field blend_fn fun(fg: string, bg: string, alpha: number): string
---@field styles_config Base16ProMax.Config.Styles Styles configuration
---@field colors table<Base16ProMax.Group.Alias, string> Semantic color palette

---@class Base16ProMax.Config.SetupGlobals
---@field terminal_colors? boolean Set terminal colors
---@field base16_gui_colors? boolean Set base16 gui colors

---@class Base16ProMax.Config.ColorGroups
---@field backgrounds? Base16ProMax.Config.ColorGroups.Backgrounds Background colors
---@field foregrounds? Base16ProMax.Config.ColorGroups.Foregrounds Foreground colors
---@field syntax? Base16ProMax.Config.ColorGroups.Syntax Syntax colors
---@field states? Base16ProMax.Config.ColorGroups.States Semantic colors
---@field diff? Base16ProMax.Config.ColorGroups.Diff Diff colors
---@field git? Base16ProMax.Config.ColorGroups.Git Git colors
---@field search? Base16ProMax.Config.ColorGroups.Search Search colors
---@field markdown? Base16ProMax.Config.ColorGroups.Markdown Markdown colors
---@field modes? Base16ProMax.Config.ColorGroups.Modes Mode colors

---@alias Base16ProMax.Config.ColorGroups.Color string|Base16ProMax.Config.ColorGroups.Color.Function
---@alias Base16ProMax.Config.ColorGroups.Color.Function fun(function_refs: Base16ProMax.Config.ColorGroups.Color.FunctionRefs): string

---@class Base16ProMax.Config.ColorGroups.Color.FunctionRefs
---@field blend_fn fun(fg: string, bg: string, alpha: number): string Blend function
---@field colors table<Base16ProMax.Group.Alias, string> Semantic color palette

---@class Base16ProMax.Config.ColorGroups.Backgrounds
---@field normal? Base16ProMax.Config.ColorGroups.Color Normal background
---@field dim? Base16ProMax.Config.ColorGroups.Color Dim background
---@field light? Base16ProMax.Config.ColorGroups.Color Light background
---@field selection? Base16ProMax.Config.ColorGroups.Color Selection background
---@field cursor_line? Base16ProMax.Config.ColorGroups.Color Cursor line background
---@field cursor_column? Base16ProMax.Config.ColorGroups.Color Cursor column background

---@class Base16ProMax.Config.ColorGroups.Foregrounds
---@field normal? Base16ProMax.Config.ColorGroups.Color Normal foreground
---@field dim? Base16ProMax.Config.ColorGroups.Color Dim foreground
---@field dark? Base16ProMax.Config.ColorGroups.Color Dark foreground
---@field light? Base16ProMax.Config.ColorGroups.Color Light foreground
---@field bright? Base16ProMax.Config.ColorGroups.Color Bright foreground
---@field comment? Base16ProMax.Config.ColorGroups.Color Comment foreground
---@field line_number? Base16ProMax.Config.ColorGroups.Color Line number foreground
---@field border? Base16ProMax.Config.ColorGroups.Color Border

---@class Base16ProMax.Config.ColorGroups.Syntax
---@field variable? Base16ProMax.Config.ColorGroups.Color Variable foreground
---@field constant? Base16ProMax.Config.ColorGroups.Color Constant foreground
---@field string? Base16ProMax.Config.ColorGroups.Color String foreground
---@field number? Base16ProMax.Config.ColorGroups.Color Number foreground
---@field boolean? Base16ProMax.Config.ColorGroups.Color Boolean foreground
---@field keyword? Base16ProMax.Config.ColorGroups.Color Keyword foreground
---@field function_name? Base16ProMax.Config.ColorGroups.Color Function name foreground
---@field type? Base16ProMax.Config.ColorGroups.Color Type foreground
---@field comment? Base16ProMax.Config.ColorGroups.Color Comment foreground
---@field operator? Base16ProMax.Config.ColorGroups.Color Operator foreground
---@field delimiter? Base16ProMax.Config.ColorGroups.Color Delimiter foreground
---@field deprecated? Base16ProMax.Config.ColorGroups.Color Deprecated foreground

---@class Base16ProMax.Config.ColorGroups.States
---@field error? Base16ProMax.Config.ColorGroups.Color Error foreground
---@field warning? Base16ProMax.Config.ColorGroups.Color Warning foreground
---@field info? Base16ProMax.Config.ColorGroups.Color Info foreground
---@field hint? Base16ProMax.Config.ColorGroups.Color Hint foreground
---@field success? Base16ProMax.Config.ColorGroups.Color Success foreground

---@class Base16ProMax.Config.ColorGroups.Diff
---@field added? Base16ProMax.Config.ColorGroups.Color Added foreground
---@field removed? Base16ProMax.Config.ColorGroups.Color Removed foreground
---@field changed? Base16ProMax.Config.ColorGroups.Color Changed foreground
---@field text? Base16ProMax.Config.ColorGroups.Color Text foreground

---@class Base16ProMax.Config.ColorGroups.Git
---@field added? Base16ProMax.Config.ColorGroups.Color Added foreground
---@field removed? Base16ProMax.Config.ColorGroups.Color Removed foreground
---@field changed? Base16ProMax.Config.ColorGroups.Color Changed foreground
---@field untracked? Base16ProMax.Config.ColorGroups.Color Untracked foreground

---@class Base16ProMax.Config.ColorGroups.Search
---@field match? Base16ProMax.Config.ColorGroups.Color Match foreground
---@field current? Base16ProMax.Config.ColorGroups.Color Current match foreground
---@field incremental? Base16ProMax.Config.ColorGroups.Color Incremental match foreground

---@class Base16ProMax.Config.ColorGroups.Markdown
---@field heading1? Base16ProMax.Config.ColorGroups.Color Heading 1 foreground
---@field heading2? Base16ProMax.Config.ColorGroups.Color Heading 2 foreground
---@field heading3? Base16ProMax.Config.ColorGroups.Color Heading 3 foreground
---@field heading4? Base16ProMax.Config.ColorGroups.Color Heading 4 foreground
---@field heading5? Base16ProMax.Config.ColorGroups.Color Heading 5 foreground
---@field heading6? Base16ProMax.Config.ColorGroups.Color Heading 6 foreground

---@class Base16ProMax.Config.ColorGroups.Modes
---@field normal? Base16ProMax.Config.ColorGroups.Color Normal mode foreground
---@field insert? Base16ProMax.Config.ColorGroups.Color Insert mode foreground
---@field visual? Base16ProMax.Config.ColorGroups.Color Visual mode foreground
---@field visual_line? Base16ProMax.Config.ColorGroups.Color Visual line mode foreground
---@field replace? Base16ProMax.Config.ColorGroups.Color Replace mode foreground
---@field command? Base16ProMax.Config.ColorGroups.Color Command mode foreground

---@class Base16ProMax.Config.Styles
---@field italic? boolean Enable italics
---@field bold? boolean Enable bold text
---@field transparency? boolean Transparent background
---@field dim_inactive_windows? boolean Dim inactive windows
---@field blends? Base16ProMax.Config.Styles.Blends Blend values to override
---@field use_cterm? boolean Use cterm colors (overrides colors)

---@class Base16ProMax.Config.Styles.Blends
---@field subtle? number barely visible backgrounds (10%)
---@field medium? number noticeable but not distracting (15%)
---@field strong? number prominent highlights (25%)
---@field super? number very prominent highlights (50%)

---@class Base16ProMax.Config.Plugins
---@field enable_all? boolean Enable all plugins
---@field nvim_mini_mini_icons? boolean Enable Mini Icons
---@field nvim_mini_mini_diff? boolean Enable Mini Diff
---@field nvim_mini_mini_files? boolean Enable Mini Files
---@field nvim_mini_mini_pick? boolean Enable Mini Pick
---@field nvim_mini_mini_statusline? boolean Enable Mini Statusline
---@field meandering_programmer_render_markdown_nvim? boolean Enable Render Markdown
---@field y3owk1n_undo_glow_nvim? boolean Enable Undo Glow
---@field y3owk1n_time_machine_nvim? boolean Enable Time Machine
---@field saghen_blink_cmp? boolean Enable Blink Cmp
---@field magicduck_grug_far_nvim? boolean Enable Grug Far
---@field folke_which_key_nvim? boolean Enable Which Key
---@field folke_flash_nvim? boolean Enable Flash
---@field lewis6991_gitsigns_nvim? boolean Enable Git Signs
---@field nvim_telescope_telescope_nvim? boolean Enable Telescope
---@field ibhagwan_fzf_lua? boolean Enable Fzf Lua
---@field nvim_lualine_lualine_nvim? boolean Enable Lualine

---@alias Base16ProMax.Group.Raw
---| '"base00"' # Default background (Semantic Alias: bg)
---| '"base01"' # Lighter Background (Used for status bars) (Semantic Alias: bg_dim)
---| '"base02"' # Selection background (Semantic Alias: bg_light)
---| '"base03"' # Comments, Invisibles, Line Highlighting (Semantic Alias: fg_dim)
---| '"base04"' # Dark Foreground (Used for status bars) (Semantic Alias: fg_dark)
---| '"base05"' # Default Foreground, Caret, Delimiters, Operators (Semantic Alias: fg)
---| '"base06"' # Light foreground (Semantic Alias: fg_light)
---| '"base07"' # The Lightest Foreground (Semantic Alias: fg_bright)
---| '"base08"' # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted (Semantic Alias: red)
---| '"base09"' # Integers, Boolean, Constants, XML Attributes, Markup Link Url (Semantic Alias: orange)
---| '"base0A"' # Classes, Markup Bold, Search Text Background (Semantic Alias: yellow)
---| '"base0B"' # Strings, Inherited Class, Markup Code, Diff Inserted (Semantic Alias: green)
---| '"base0C"' # Support, Regular Expressions, Escape Characters, Markup Quotes (Semantic Alias: cyan)
---| '"base0D"' # Functions, Methods, Attribute IDs, Headings (Semantic Alias: blue)
---| '"base0E"' # Keywords, Storage, Selector, Markup Italic, Diff Changed (Semantic Alias: purple)
---| '"base0F"' # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?> (Semantic Alias: brown)

---@alias Base16ProMax.Group.Alias
---| '"bg"' # Default background (Raw Base16ProMax: base00)
---| '"bg_dim"' # Lighter Background (Used for status bars) (Raw Base16ProMax: base01)
---| '"bg_light"' # Selection background (Raw Base16ProMax: base02)
---| '"fg_dim"' # Comments, Invisibles, Line Highlighting (Raw Base16ProMax: base03)
---| '"fg_dark"' # Dark Foreground (Used for status bars) (Raw Base16ProMax: base04)
---| '"fg"' # Default Foreground, Caret, Delimiters, Operators (Raw Base16ProMax: base05)
---| '"fg_light"' # Light foreground (Raw Base16ProMax: base06)
---| '"fg_bright"' # The Lightest Foreground (Raw Base16ProMax: base07)
---| '"red"' # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted (Raw Base16ProMax: base08)
---| '"orange"' # Integers, Boolean, Constants, XML Attributes, Markup Link Url (Raw Base16ProMax: base09)
---| '"yellow"' # Classes, Markup Bold, Search Text Background (Raw Base16ProMax: base0A)
---| '"green"' # Strings, Inherited Class, Markup Code, Diff Insert
---| '"cyan"' # Support, Regular Expressions, Escape Characters, Markup Quotes (Raw Base16ProMax: base0C)
---| '"blue"' # Functions, Methods, Attribute IDs, Headings (Raw Base16ProMax: base0D)
---| '"purple"' # Keywords, Storage, Selector, Markup Italic, Diff Changed (Raw Base16ProMax: base0E)
---| '"brown"' # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?> (Raw Base16ProMax: base0F)

return M
