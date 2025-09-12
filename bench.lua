-- Run with `nvim --headless -l ./bench.lua` to get the results

local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")
vim.opt.rtp:prepend(plugin_root)

local colors = {
  base00 = "#1f1f28",
  base01 = "#2a2a37",
  base02 = "#3a3a4e",
  base03 = "#4e4e5e",
  base04 = "#9e9eaf",
  base05 = "#c5c5da",
  base06 = "#dfdfef",
  base07 = "#e6e6f0",
  base08 = "#ff5f87",
  base09 = "#ff8700",
  base0A = "#ffaf00",
  base0B = "#5fff87",
  base0C = "#5fd7ff",
  base0D = "#5fafff",
  base0E = "#af87ff",
  base0F = "#d7875f",
}

-- Helpers
local function hr_ms(fn)
  local t0 = vim.uv.hrtime()
  fn()
  return (vim.uv.hrtime() - t0) / 1e6
end

local function clear_module(name)
  package.loaded[name] = nil
  _G[name] = nil
end

-- Cold require
for _ = 1, 3 do
  clear_module("base16-pro-max")
  require("base16-pro-max")
end
clear_module("base16-pro-max")
local cold_ms = hr_ms(function()
  require("base16-pro-max")
end)

local b16 = require("base16-pro-max")

-- Setup
local setup_ms = hr_ms(function()
  b16.setup({ colors = colors })
end)

-- Colorscheme re-apply
vim.o.eventignore = "all"
vim.o.lazyredraw = true

local reps = 100
local apply_ms = hr_ms(function()
  for _ = 1, reps do
    vim.api.nvim_set_hl(0, "Normal", {})
    b16._reapply_highlights()
  end
end) / reps

-- Peak memory
collectgarbage("collect")
local peak_kb = collectgarbage("count")

-- Result
print(
  "╔══════════════════════════════════════════════════════╗"
)
print("║        base16-pro-max.nvim Benchmark Results         ║")
print(
  "╚══════════════════════════════════════════════════════╝\n"
)

print(("• Cold require  : %6.2f ms  (parse + JIT compile)"):format(cold_ms))
print(("• Setup         : %6.2f ms  (config merge, table build)"):format(setup_ms))
print(("• Re-apply avg  : %6.3f ms  (highlight reapply, %d reps)"):format(apply_ms, reps))
print(("• Peak Lua mem  : %6.1f KB\n"):format(peak_kb))
