local Indicator = require'skkeleton_indicator.indicator'

local module_name = (function()
  local file = debug.getinfo(1, 'S').source
  return file:match[[/([^/]+)/[^/]+.lua$]]
end)()

local M = {}

function M.setup(opts)
  Indicator.new(
    vim.tbl_extend('keep', opts or {}, {
      module_name = module_name,
      eiji_hl_name = module_name..'_eiji',
      hira_hl_name = module_name..'_hira',
      kata_hl_name = module_name..'_kata',
      eiji_text = '英字',
      hira_text = 'ひら',
      kata_text = 'カタ',
      fade_out_ms = 3000,
    })
  )
end

return M
