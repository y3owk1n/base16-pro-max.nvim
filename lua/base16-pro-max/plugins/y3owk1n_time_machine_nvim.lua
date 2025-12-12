local M = {}

M.url = "https://github.com/y3owk1n/time-machine.nvim"

---@param highlights table<string, Base16ProMax.HighlightOpts>
---@param function_refs Base16ProMax.Config.HighlightGroups.FunctionRefs
function M.setup(highlights, function_refs)
  local get_group_color = function_refs.get_group_color_fn
  local config = function_refs.styles_config
  local c = function_refs.colors

  highlights.TimeMachineNormal = {
    link = "Normal",
  }
  highlights.TimeMachineBorder = {
    link = "FloatBorder",
  }
  highlights.TimeMachineCurrent = {
    bg = get_group_color("states", "info", c),
    blend = config.blends.medium,
  }
  highlights.TimeMachineTimeline = {
    fg = get_group_color("states", "info", c),
  }
  highlights.TimeMachineTimelineAlt = {
    fg = get_group_color("foregrounds", "dark", c),
  }
  highlights.TimeMachineKeymap = {
    fg = get_group_color("states", "hint", c),
  }
  highlights.TimeMachineSeq = {
    fg = get_group_color("states", "error", c),
  }
  highlights.TimeMachineTag = {
    fg = get_group_color("states", "warning", c),
  }
  highlights.TimeMachineInfo = {
    fg = get_group_color("foregrounds", "dark", c),
  }
end

return M
