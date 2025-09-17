---@mod base16-pro-max.plugins Plugin Integrations

---@brief [[
---# Plugin Integrations ~
---
---This module contains the plugin integrations for `base16-pro-max.nvim`.
---All integrations are disabled by default, but can be enabled in the config.
---
--->lua
---   require("base16-pro-max").setup({
---     plugins = {
---       enable_all = true,
---     },
---   })
---<
---
---Or you can enable them individually:
---
--->lua
---   require("base16-pro-max").setup({
---     plugins = {
---       enable_all = false,
---       nvim_mini_mini_icons = true
---     },
---   })
---<
---
---## Available Plugins Integrations ~
---
---See also |Base16ProMax.Config.Plugins| for all the plugins that can be enabled or disabled.
---
---Below only shows help for plugins that requires extra setup.
---
---### Lualine ~
---
--->lua
---   require("lualine").setup({
---     options = {
---       theme = "base16-pro-max",
---     },
---   })
---<
---
---@brief ]]

local M = {}

---@type string[]
M.plugin_map = {
  "nvim_mini_mini_icons",
  "nvim_mini_mini_diff",
  "nvim_mini_mini_files",
  "nvim_mini_mini_pick",
  "nvim_mini_mini_statusline",
  "meandering_programmer_render_markdown_nvim",
  "y3owk1n_undo_glow_nvim",
  "y3owk1n_time_machine_nvim",
  "saghen_blink_cmp",
  "magicduck_grug_far_nvim",
  "folke_which_key_nvim",
  "folke_flash_nvim",
  "lewis6991_gitsigns_nvim",
  "nvim_telescope_telescope_nvim",
  "ibhagwan_fzf_lua",
  "nvim_lualine_lualine_nvim",
}

---@private
---Check if a plugin is enabled in config
---@param name string The plugin name
function M.has_plugin(name)
  local config = require("base16-pro-max").config

  local plugin = config.plugins[name]

  if plugin == nil then
    return config.plugins.enable_all or false
  end

  return plugin
end

---@param highlights table<string, vim.api.keyset.highlight>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  for _, plugin in ipairs(M.plugin_map) do
    if M.has_plugin(plugin) then
      local plugin_ok, plugin_mod = pcall(require, "base16-pro-max.plugins." .. plugin)
      if not plugin_ok then
        vim.notify("base16-pro-max.nvim: Failed to load plugin: " .. plugin, vim.log.levels.ERROR)
        return
      end
      plugin_mod.setup(highlights, function_refs)
    end
  end
end

return M
