local Indicator = require'skkeleton_indicator.indicator'

local M = {}

function M.setup(opts)
  M.instance = Indicator.new(
    vim.tbl_extend('keep', opts or {}, {
      moduleName = 'skkeleton_indicator',
      eijiHlName = 'SkkeletonIndicatorEiji',
      hiraHlName = 'SkkeletonIndicatorHira',
      kataHlName = 'SkkeletonIndicatorKata',
      hankataHlName = 'SkkeletonIndicatorHankata',
      eijiText = '英字',
      hiraText = 'ひら',
      kataText = 'カタ',
      hankataText = '半ｶﾀ',
      fadeOutMs = 3000,
      ignoreFt = {},
      bufFilter = function() return true end,
    })
  )
end

return M
