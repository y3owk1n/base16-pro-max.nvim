local M = {}

---Setup markdown highlights
---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param c table<Base16ProMax.Group.Alias, string>
function M.setup(highlights, c)
  local get_group_color = require("base16-pro-max.lib.colors").get_group_color
  local config = require("base16-pro-max.config").config

  for i = 1, 6 do
    highlights["markdownH" .. i] = {
      fg = get_group_color("markdown", "heading" .. i, c),
      bold = config.styles.bold,
    }
    highlights["markdownH" .. i .. "Delimiter"] = {
      fg = get_group_color("markdown", "heading" .. i, c),
      bold = config.styles.bold,
    }
    highlights["@markup.heading." .. i .. ".markdown"] = { link = "markdownH" .. i }
    highlights["@markup.heading." .. i .. ".marker.markdown"] = { link = "markdownH" .. i .. "Delimiter" }
  end

  -- Markdown links and formatting
  highlights.markdownLinkText = { link = "markdownUrl" }
  highlights.markdownUrl = {
    fg = get_group_color("syntax", "keyword", c),
    sp = get_group_color("syntax", "keyword", c),
    underline = true,
  }

  -- Markup elements
  highlights["@markup.strong"] = { bold = config.styles.bold }
  highlights["@markup.italic"] = { italic = config.styles.italic }
  highlights["@markup.strikethrough"] = { strikethrough = true }
  highlights["@markup.underline"] = { underline = true }
  highlights["@markup.heading"] = {
    fg = get_group_color("syntax", "operator", c),
    bold = config.styles.bold,
  }
  highlights["@markup.quote"] = { fg = get_group_color("syntax", "comment", c) }
  highlights["@markup.list"] = { fg = get_group_color("states", "error", c) }
  highlights["@markup.link"] = {
    fg = get_group_color("syntax", "keyword", c),
    underline = true,
  }
  highlights["@markup.raw"] = { fg = get_group_color("syntax", "string", c) }

  -- Diff markup
  highlights["@diff.plus"] = { fg = get_group_color("diff", "added", c) }
  highlights["@diff.minus"] = { fg = get_group_color("diff", "removed", c) }
  highlights["@diff.delta"] = { fg = get_group_color("states", "hint", c) }

  -- Tags
  highlights["@tag"] = { link = "Tag" }
  highlights["@tag.attribute"] = { fg = get_group_color("syntax", "keyword", c) }
  highlights["@tag.delimiter"] = { fg = get_group_color("syntax", "delimiter", c) }
end

return M
