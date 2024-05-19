---@type SkkeletonIndicator?
local indicator

vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    if not indicator then
      indicator = require "skkeleton_indicator.indicator"()
      indicator:open()
    end
  end,
})

return {
  ---@param opts? SkkeletonIndicatorOpts
  setup = function(opts)
    require("skkeleton_indicator.config").setup(opts)
    if indicator then
      indicator.modes = require("skkeleton_indicator.modes").new()
      indicator:update "mode-changed"
    end
  end,
  indicator = function()
    return indicator
  end,
}
