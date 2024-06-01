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

local function refresh()
  if indicator then
    indicator:refresh()
  end
end

return {
  ---@param opts? SkkeletonIndicatorOpts
  setup = function(opts)
    require("skkeleton_indicator.config").setup(opts)
    refresh()
  end,
  refresh = refresh,
}
