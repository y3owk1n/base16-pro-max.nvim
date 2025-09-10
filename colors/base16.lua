-- This file is executed by :colorscheme base16
-- It is executed in an empty Lua environment, so we have to require()
local ok, base16 = pcall(require, "base16")
if not ok then
  vim.notify("base16.nvim not installed", vim.log.levels.ERROR)
  return
end

-- If the user has already called setup() we just activate the theme.
-- If not, we call setup() with an empty table so that the mandatory
-- base00…base0F table is expected to come from the user’s own config.
if not base16.config or not next(base16.config) then
  base16.setup({}) -- user must have filled M.config.colors elsewhere
end

base16.colorscheme() -- apply highlights

-- Tell Neovim which colorscheme is active
vim.g.colors_name = "base16"
