local Indicator = require'skkeleton_indicator.indicator'
local snake_case_dict = require'skkeleton_indicator.util'.snake_case_dict

local M = {}

function M.setup(opts)
  M.instance = Indicator.new(
    snake_case_dict(
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
        alwaysShown = true,
        fadeOutMs = 3000,
        ignoreFt = {},
        bufFilter = function() return true end,
      })
    )
  )
end

return M
