# base16.nvim

A modern, highly configurable Base16 colorscheme engine for Neovim that brings the classic Base16 aesthetic into the contemporary editor landscape.

## Motivation

While the Base16 specification provides a solid foundation for terminal and editor theming, existing Neovim implementations often fall short of modern expectations. Popular colorschemes today offer features like:

- Semantic color grouping and customization
- Window dimming and transparency effects
- Blend modes and subtle background variations
- Extensive plugin integrations
- Fine-grained style controls

**base16.nvim** bridges this gap by combining the timeless Base16 color palette system with the advanced features users expect from modern colorscheme plugins. Unlike simpler Base16 implementations that only provide basic syntax highlighting, this plugin offers:

- **Semantic Color Aliases**: Use intuitive names like `bg`, `fg`, `red`, `blue` instead of cryptic `base00`, `base08`
- **Advanced Styling**: Transparency, window dimming, blend modes, and comprehensive style options
- **Plugin Ecosystem**: Native support for Mini.nvim, Blink.cmp, RenderMarkdown, and more
- **Flexible Customization**: Override any color group or highlight with functions or direct values
- **Modern Architecture**: Built with performance, validation, and extensibility in mind

Whether you're a Base16 enthusiast wanting modern features or a user of contemporary themes looking for the Base16 aesthetic, this plugin provides the best of both worlds.

### Goal of this project

The goal of this project is to provide a modern, highly customizable base16 implementation for Neovim that looks decent,
as long as the base16 scheme provided are adhering to the guidelines as close as possible.

## Features

- **Complete Base16 Implementation**: Full support for the Base16 specification with semantic aliases
- **Modern Styling Options**: Transparency, italics, bold text, window dimming, and blend modes
- **Extensive Plugin Support**: Native integrations for popular Neovim plugins
- **Semantic Color Groups**: Intuitive color organization for backgrounds, syntax, states, diff, and search
- **Runtime Validation**: Comprehensive configuration validation with helpful error messages
- **Performance Optimized**: Efficient caching and minimal runtime overhead
- **Highly Customizable**: Override any aspect through configuration or runtime functions

## Note about what is not for this plugin

This plugin is not designed to be a collection of all existing Base16 schemes and it will never includes them in the source. If you want a collection of Base16 schemes, check out [tinted theming](https://github.com/tinted-theming/schemes).

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "y3owk1n/base16.nvim",
  config = function()
    require("base16").setup({
      colors = {
        base00 = "#1f1f28", base01 = "#2a2a37", base02 = "#3a3a4e",
        base03 = "#4e4e5e", base04 = "#9e9eaf", base05 = "#c5c5da",
        base06 = "#dfdfef", base07 = "#e6e6f0", base08 = "#ff5f87",
        base09 = "#ff8700", base0A = "#ffaf00", base0B = "#5fff87",
        base0C = "#5fd7ff", base0D = "#5fafff", base0E = "#af87ff",
        base0F = "#d7875f",
      },
    })
    vim.cmd.colorscheme("base16")
  end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "y3owk1n/base16.nvim",
  config = function()
    require("base16").setup({ --[[ your config ]] })
    vim.cmd.colorscheme("base16")
  end
}
```

## Quick Start

```lua
-- Minimal setup with Kanagawa-inspired colors
require("base16").setup({
  colors = {
    base00 = "#1f1f28", base01 = "#2a2a37", base02 = "#3a3a4e",
    base03 = "#4e4e5e", base04 = "#9e9eaf", base05 = "#c5c5da",
    base06 = "#dfdfef", base07 = "#e6e6f0", base08 = "#ff5f87",
    base09 = "#ff8700", base0A = "#ffaf00", base0B = "#5fff87",
    base0C = "#5fd7ff", base0D = "#5fafff", base0E = "#af87ff",
    base0F = "#d7875f",
  },
})

vim.cmd.colorscheme("base16")
```

## Configuration

### Default Configuration

```lua
require("base16").setup({
  -- Base16 colors (required)
  colors = {
    base00 = "#000000", -- Default background
    base01 = "#000000", -- Lighter background (status bars)
    base02 = "#000000", -- Selection background
    base03 = "#000000", -- Comments, line highlighting
    base04 = "#000000", -- Dark foreground (status bars)
    base05 = "#000000", -- Default foreground
    base06 = "#000000", -- Light foreground
    base07 = "#000000", -- Lightest foreground
    base08 = "#000000", -- Red (variables, errors)
    base09 = "#000000", -- Orange (integers, constants)
    base0A = "#000000", -- Yellow (classes, search)
    base0B = "#000000", -- Green (strings, success)
    base0C = "#000000", -- Cyan (support, regex)
    base0D = "#000000", -- Blue (functions, info)
    base0E = "#000000", -- Purple (keywords, changes)
    base0F = "#000000", -- Brown (deprecated)
  },

  -- Style options
  styles = {
    italic = false,                    -- Enable italic text
    bold = false,                      -- Enable bold text
    transparency = false,              -- Transparent background
    use_cterm = false,                 -- Use cterm colors
    dim_inactive_windows = false,      -- Dim inactive windows
    blends = {
      subtle = 10,                     -- Barely visible (10%)
      medium = 15,                     -- Noticeable (15%)
      strong = 25,                     -- Prominent (25%)
      super = 50,                      -- Very prominent (50%)
    },
  },

  -- Plugin integrations
  plugins = {
    enable_all = false,                -- Enable all supported plugins
  },

  -- Semantic color groups
  color_groups = {
    backgrounds = {
      normal = "bg",
      dim = "bg_dim",
      light = "bg_light",
      selection = "bg_light",
      cursor_line = function(c) return U.blend(c.bg_light, c.bg, 0.6) end,
      cursor_column = function(c) return U.blend(c.bg_dim, c.bg, 0.3) end,
    },
    foregrounds = {
      normal = "fg",
      dim = "fg_dim",
      dark = "fg_dark",
      light = "fg_light",
      bright = "fg_bright",
      comment = "fg_dark",
      line_number = function(c) return U.blend(c.fg_dim, c.bg, 0.7) end,
    },
    syntax = {
      variable = "fg",
      constant = "brown",
      string = "green",
      number = "orange",
      boolean = "orange",
      keyword = "purple",
      function_name = "blue",
      type = "yellow",
      comment = "fg_dark",
      operator = "cyan",
      delimiter = "fg_dim",
    },
    states = {
      error = "red",
      warning = "yellow",
      info = "blue",
      hint = "cyan",
      success = "green",
    },
    diff = {
      added = "green",
      removed = "red",
      changed = "orange",
      text = "blue",
    },
    search = {
      match = "yellow",
      current = "orange",
      incremental = "orange",
    },
  },

  -- Additional highlight groups
  highlight_groups = {},

  -- Pre-highlight callback
  before_highlight = nil,
})
```

## Color Reference

### Base16 Semantic Aliases

The purpose is based of [tinted theming scheme](https://github.com/tinted-theming/home/blob/91b91035911dffb1bb925f8fa9dcfcdfe0b76110/styling.md)

| Alias       | Raw      | Purpose                            |
| ----------- | -------- | ---------------------------------- |
| `bg`        | `base00` | Default background                 |
| `bg_dim`    | `base01` | Lighter background (status bars)   |
| `bg_light`  | `base02` | Selection background               |
| `fg_dim`    | `base03` | Comments, line highlighting        |
| `fg_dark`   | `base04` | Dark foreground (status bars)      |
| `fg`        | `base05` | Default foreground                 |
| `fg_light`  | `base06` | Light foreground                   |
| `fg_bright` | `base07` | Lightest foreground                |
| `red`       | `base08` | Variables, errors, markup deletion |
| `orange`    | `base09` | Numbers, constants, attributes     |
| `yellow`    | `base0A` | Classes, search, markup bold       |
| `green`     | `base0B` | Strings, success, markup insertion |
| `cyan`      | `base0C` | Support, regex, markup quotes      |
| `blue`      | `base0D` | Functions, info, headings          |
| `purple`    | `base0E` | Keywords, changes, markup italic   |
| `brown`     | `base0F` | Deprecated, embedded languages     |

## Advanced Usage

### Custom Color Groups

```lua
require("base16").setup({
  colors = { --[[ your base16 colors ]] },
  color_groups = {
    syntax = {
      -- Use a different color for functions
      function_name = "cyan",
      -- Use a custom function for comments
      comment = function(c)
        return blend(c.fg_dim, c.bg, 0.8)
      end,
    },
    states = {
      -- Custom error color
      error = "#ff6b6b",
    },
  },
})
```

### Custom Highlight Groups

```lua
require("base16").setup({
  colors = { --[[ your base16 colors ]] },
  highlight_groups = {
    -- Custom highlight using base16 colors
    MyCustomHighlight = {
      fg = "red",          -- Use semantic alias
      bg = "base01",       -- Use raw base16 color
      bold = true,
    },
    -- Link to existing highlight
    MyOtherHighlight = { link = "Function" },
  },
})
```

### Style Variations

```lua
-- Dark theme with transparency and italics
require("base16").setup({
  colors = { --[[ dark colors ]] },
  styles = {
    transparency = true,
    italic = true,
    bold = true,
    dim_inactive_windows = true,
  },
})

-- Light theme with subtle blends
require("base16").setup({
  colors = { --[[ light colors ]] },
  styles = {
    blends = {
      subtle = 5,
      medium = 10,
      strong = 15,
      super = 25,
    },
  },
})
```

### Plugin Integration

```lua
require("base16").setup({
  colors = { --[[ your colors ]] },
  plugins = {
    -- Enable all supported plugins
    enable_all = true,
    -- Or enable specific plugins
    nvim_mini_mini_icons = true,
    saghen_blink_cmp = true,
    folke_which_key_nvim = true,
  },
})
```

## API Reference

### Functions

```lua
local base16 = require("base16")

-- Setup the plugin (required)
base16.setup(config)

-- Apply the colorscheme
vim.cmd.colorscheme("base16")

-- Get semantic color palette
local colors = base16.colors()
print(colors.red)  -- "#ff5f87"

-- Get specific color
local red = base16.get_color("red")
local bg = base16.get_color("bg")

-- Get multiple colors
local palette = base16.get_colors({"red", "blue", "green"})

-- Get raw base16 colors
local raw = base16.raw_colors()

-- Get color from groups
local error_color = base16.get_group_color("states", "error")

-- Blend colors
local blended = base16.blend_colors("#ff0000", "#000000", 0.5)

-- Validate colors
local valid, missing = base16.validate_colors(my_colors)
```

## Supported Plugins

- **Mini.nvim**: Icons, Diff, Files, Pick
- **Blink.cmp**: Completion menu styling
- **RenderMarkdown**: Enhanced markdown rendering
- **Undo Glow**: Undo visualization
- **Grug Far**: Search and replace
- **Which Key**: Key binding hints
- **Flash**: Jump navigation

### Why These Plugins?

The current plugin integrations reflect my personal Neovim setup - these are the plugins I use daily and can thoroughly test. Rather than adding superficial support for plugins I don't use, I've focused on providing high-quality integrations for my actual workflow.

**Want support for your favorite plugin?** I welcome pull requests! The plugin architecture makes it straightforward to add new integrations. Check out the existing implementations in the codebase as examples, and feel free to contribute support for additional plugins.

## Examples

### Popular Base16 Themes

**Gruvbox Dark:**

```lua
require("base16").setup({
  colors = {
    base00 = "#282828", base01 = "#3c3836", base02 = "#504945",
    base03 = "#665c54", base04 = "#bdae93", base05 = "#d5c4a1",
    base06 = "#ebdbb2", base07 = "#fbf1c7", base08 = "#fb4934",
    base09 = "#fe8019", base0A = "#fabd2f", base0B = "#b8bb26",
    base0C = "#8ec07c", base0D = "#83a598", base0E = "#d3869b",
    base0F = "#d65d0e",
  },
})
```

**Nord:**

```lua
require("base16").setup({
  colors = {
    base00 = "#2e3440", base01 = "#3b4252", base02 = "#434c5e",
    base03 = "#4c566a", base04 = "#d8dee9", base05 = "#e5e9f0",
    base06 = "#eceff4", base07 = "#8fbcbb", base08 = "#bf616a",
    base09 = "#d08770", base0A = "#ebcb8b", base0B = "#a3be8c",
    base0C = "#88c0d0", base0D = "#81a1c1", base0E = "#b48ead",
    base0F = "#5e81ac",
  },
})
```

## Troubleshooting

### Common Issues

**Colors not applying correctly:**

- Ensure your terminal supports true color: `set termguicolors` in Neovim
- Check that all required base16 colors (base00-base0F) are provided
- Verify color format is valid hex (e.g., `#ffffff`)

**Performance issues:**

- Color caching should handle most cases automatically
- If you modify colors frequently, call `require("base16")._invalidate_cache()` manually

**Plugin integrations not working:**

- Ensure the plugin is installed and loaded before base16
- Check that the plugin integration is enabled in your config
- Some plugins may override highlights - load base16 after them

**Validation errors:**

- Read error messages carefully - they indicate exactly what's wrong
- Use the default configuration as a reference
- Check function returns in color_groups are valid hex colors

## FAQ

### How is this different from other Base16 implementations?

Most existing Base16 plugins for Neovim are minimal implementations that only provide basic syntax highlighting. This plugin brings modern colorscheme features like semantic color aliases, transparency, window dimming, blend modes, and extensive plugin integrations while maintaining full Base16 specification compliance.

### Can I use existing Base16 color schemes?

Absolutely! Any standard Base16 color scheme will work. Just map the base00-base0F colors to the `colors` configuration. You can find schemes at [tinted theming](https://github.com/tinted-theming/schemes).

### Why do some highlight groups look different from other colorschemes?

This plugin uses semantic color groups for consistency and customization. If you prefer different mappings, you can override them in `color_groups` or `highlight_groups` configuration.

### How do I add support for a new plugin?

Check the existing plugin integrations in the source code as examples. Plugin highlights are typically added in the `setup_integration_hl` function. We welcome pull requests for new integrations!

### Can I use this with a light background?

Yes! Base16 works with both light and dark themes. Just provide appropriate base16 colors for your preferred background. The plugin automatically handles foreground/background relationships.

### Why are some plugins not supported?

The current integrations reflect the plugins I actively use and can properly test. This ensures high-quality implementations rather than superficial support. Community contributions for additional plugins are very welcome!

### How do I migrate from another colorscheme?

1. Find or create a Base16 version of your preferred colors
2. Replace your current colorscheme setup with base16 configuration
3. Customize color groups if needed
4. Enable relevant plugin integrations.

### Can I use custom colors outside the Base16 palette?

Yes! You can override any color in `color_groups` or `highlight_groups` with custom hex values or functions. The Base16 colors serve as the foundation, but you have full customization control.

### Is this compatible with other colorscheme plugins?

This plugin is designed to be a complete colorscheme solution. While you can technically load other colorschemes, they may override highlights. For best results, use base16.nvim as your primary colorscheme and customize as needed.

### How do I report bugs or request features?

Please open an issue on the GitHub repository with:

- Your Neovim version (`nvim --version`)
- Your configuration
- Steps to reproduce the issue
- Expected vs actual behavior

## Performance

### Benchmarks

- **Startup time**: < 5ms on modern hardware
- **Color computation**: Cached after first calculation
- **Memory usage**: Minimal footprint with efficient caching
- **Highlight application**: Optimized batch operations

### Optimization Tips

- Use the default `color_groups` when possible - they're pre-optimized
- Avoid complex functions in color_groups for frequently accessed colors
- Enable `use_cterm` only if needed for terminal compatibility
- Cache custom color calculations in your configuration

## Development

### Architecture

The plugin is structured in several key modules:

- **Validation (`V`)**: Comprehensive configuration validation
- **Utility (`U`)**: Color manipulation, caching, and helper functions
- **Highlight Setup**: Modular highlight group definitions
- **Plugin Integration**: Extensible plugin support system
- **API**: Public interface for programmatic access

### Adding Plugin Support

1. Add plugin option to `Base16.Config.Plugins` type
2. Create highlight function in `setup_integration_hl`
3. Use `U.has_plugin()` to check if integration should be applied
4. Follow existing patterns for consistent styling
5. Test with actual plugin usage
6. Submit pull request with documentation

### Color Group Architecture

The plugin uses a hierarchical color system:

```
Base16 Raw Colors (base00-base0F)
    ↓
Semantic Aliases (bg, fg, red, blue, etc.)
    ↓
Color Groups (backgrounds, syntax, states, etc.)
    ↓
Highlight Groups (Normal, Function, Error, etc.)
```

This allows for consistent theming while maintaining flexibility.

## Contributing

We welcome contributions! Here's how to get started:

### Contribution Guidelines

- Follow existing code style and patterns
- Add appropriate type annotations
- Include validation for new configuration options
- Test with real plugin usage scenarios
- Update documentation for new features
- Write clear commit messages

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes with proper testing
4. Update documentation if needed
5. Submit pull request with description
6. Respond to review feedback

### Areas for Contribution

- **Plugin integrations**: Support for additional Neovim plugins
- **Documentation**: Examples, tutorials, migration guides
- **Testing**: Automated testing, edge case coverage
- **Performance**: Optimization improvements

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Base16 Project](https://github.com/chriskempson/base16) for the color specification
- [Mini.nvim](https://github.com/echasnovski/mini.nvim) for inspiration on plugin architecture
- [Rosepine](https://github.com/rose-pine/neovim) for inspiration on the modern colorscheme features
- The Neovim community for feedback and contributions
- All contributors who help improve this plugin
