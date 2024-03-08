local Indicator = require "skkeleton_indicator.indicator"
local snake_case_dict = require("skkeleton_indicator.util").snake_case_dict

local indicator = Indicator.new()

---@class SkkeletonIndicator
local skkeleton_indicator = {
  instance = indicator,
}

---@class SkkeletonIndicatorOpts
---@field moduleName? string
---@field eijiHlName? string
---@field hiraHlName? string
---@field kataHlName? string
---@field hankataHlName? string
---@field zenkakuHlName? string
---@field eijiText? string
---@field hiraText? string
---@field kataText? string
---@field hankataText? string
---@field zenkakuText? string
---@field border? skkeleton_indicator.indicator.BorderOpt
---@field row? integer
---@field col? integer
---@field zindex? integer
---@field alwaysShown? boolean
---@field fadeOutMs? integer
---@field ignoreFt? string[]
---@field bufFilter? fun(buf: integer): boolean

---@param opts? SkkeletonIndicatorOpts
---@return nil
function skkeleton_indicator.setup(opts)
  local o = snake_case_dict(vim.tbl_extend("force", {
    moduleName = "skkeleton_indicator",
    eijiHlName = "SkkeletonIndicatorEiji",
    hiraHlName = "SkkeletonIndicatorHira",
    kataHlName = "SkkeletonIndicatorKata",
    hankataHlName = "SkkeletonIndicatorHankata",
    zenkakuHlName = "SkkeletonIndicatorZenkaku",
    abbrevHlName = "SkkeletonIndicatorAbbrev",
    eijiText = "英字",
    hiraText = "ひら",
    kataText = "カタ",
    hankataText = "半ｶﾀ",
    zenkakuText = "全英",
    abbrevText = "abbr",
    col = 1,
    alwaysShown = true,
    fadeOutMs = 3000,
    ignoreFt = {},
    bufFilter = function(_)
      return true
    end,
  }, opts or {}))
  -- The default value for `row` is different according to `border`.
  if not o.row then
    o.row = (not o.border or o.border == "none" or o.border == "shadow") and 1 or 0
  end
  indicator:setup(o)
end

return skkeleton_indicator
