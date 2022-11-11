local Indicator = require "skkeleton_indicator.indicator"
local snake_case_dict = require("skkeleton_indicator.util").snake_case_dict

local indicator = Indicator.new()
local skkeleton_indicator = {
  instance = indicator,
}

function skkeleton_indicator.setup(opts)
  indicator:setup(snake_case_dict(vim.tbl_extend("force", {
    moduleName = "skkeleton_indicator",
    eijiHlName = "SkkeletonIndicatorEiji",
    hiraHlName = "SkkeletonIndicatorHira",
    kataHlName = "SkkeletonIndicatorKata",
    hankataHlName = "SkkeletonIndicatorHankata",
    zenkakuHlName = "SkkeletonIndicatorZenkaku",
    eijiText = "英字",
    hiraText = "ひら",
    kataText = "カタ",
    hankataText = "半ｶﾀ",
    zenkakuText = "全英",
    alwaysShown = true,
    fadeOutMs = 3000,
    ignoreFt = {},
    bufFilter = function(_)
      return true
    end,
  }, opts or {})))
end

return skkeleton_indicator
