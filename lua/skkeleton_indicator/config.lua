---@class SkkeletonIndicatorOpts
---@field moduleName? string
---@field eijiHlName? string
---@field hiraHlName? string
---@field kataHlName? string
---@field hankataHlName? string
---@field zenkakuHlName? string
---@field abbrevHlName? string
---@field eijiText? string
---@field hiraText? string
---@field kataText? string
---@field hankataText? string
---@field zenkakuText? string
---@field abbrevText? string
---@field border? SkkeletonIndicatorBorderOpt
---@field row? integer
---@field col? integer
---@field zindex? integer
---@field alwaysShown? boolean
---@field fadeOutMs? integer
---@field ignoreFt? string[]
---@field bufFilter? fun(buf: integer): boolean
---@field useDefaultHighlight? boolean

---@class SkkeletonIndicatorRawConfig
---@field module_name string
---@field eiji_hl_name string
---@field hira_hl_name string
---@field kata_hl_name string
---@field hankata_hl_name string
---@field zenkaku_hl_name string
---@field abbrev_hl_name string
---@field eiji_text string
---@field hira_text string
---@field kata_text string
---@field hankata_text string
---@field zenkaku_text string
---@field abbrev_text string
---@field border? SkkeletonIndicatorBorderOpt
---@field row integer
---@field col integer
---@field zindex? integer
---@field always_shown boolean
---@field fade_out_ms integer
---@field ignore_ft string[]
---@field buf_filter fun(buf: integer): boolean
---@field use_default_highlight boolean

---@type SkkeletonIndicatorRawConfig
local default_values = {
  module_name = "skkeleton_indicator",
  eiji_hl_name = "SkkeletonIndicatorEiji",
  hira_hl_name = "SkkeletonIndicatorHira",
  kata_hl_name = "SkkeletonIndicatorKata",
  hankata_hl_name = "SkkeletonIndicatorHankata",
  zenkaku_hl_name = "SkkeletonIndicatorZenkaku",
  abbrev_hl_name = "SkkeletonIndicatorAbbrev",
  eiji_text = "英字",
  hira_text = "ひら",
  kata_text = "カタ",
  hankata_text = "半ｶﾀ",
  zenkaku_text = "全英",
  abbrev_text = "abbr",
  row = 1,
  col = 1,
  always_shown = true,
  fade_out_ms = 3000,
  ignore_ft = {},
  buf_filter = function(_)
    return true
  end,
  use_default_highlight = true,
}

---@type table<string, boolean>
local keys = {
  module_name = true,
  eiji_hl_name = true,
  hira_hl_name = true,
  kata_hl_name = true,
  hankata_hl_name = true,
  zenkaku_hl_name = true,
  abbrev_hl_name = true,
  eiji_text = true,
  hira_text = true,
  kata_text = true,
  hankata_text = true,
  zenkaku_text = true,
  abbrev_text = true,
  border = true,
  row = true,
  col = true,
  zindex = true,
  always_shown = true,
  fade_out_ms = true,
  ignore_ft = true,
  buf_filter = true,
  use_default_highlight = true,
}

---@class SkkeletonIndicatorConfig: SkkeletonIndicatorRawConfig
---@field setup fun(opts?: SkkeletonIndicatorOpts)
---@field values SkkeletonIndicatorRawConfig

---@param self SkkeletonIndicatorConfig
---@return fun(opts?: SkkeletonIndicatorOpts)
local function setup(self)
  return function(opts)
    local strings = require "skkeleton_indicator.strings"

    -- The default value for `row` is different according to `border`.
    if opts and not opts.row then
      opts.row = (not opts.border or opts.border == "none" or opts.border == "shadow") and 1 or 0
    end

    ---@type SkkeletonIndicatorRawConfig
    local config = vim.tbl_extend("force", default_values, strings.snake_case_dict(opts or {}))

    vim.validate {
      module_name = { config.module_name, "s" },
      eiji_hl_name = { config.eiji_hl_name, "s" },
      hira_hl_name = { config.hira_hl_name, "s" },
      kata_hl_name = { config.kata_hl_name, "s" },
      hankata_hl_name = { config.hankata_hl_name, "s" },
      zenkaku_hl_name = { config.zenkaku_hl_name, "s" },
      abbrev_hl_name = { config.abbrev_hl_name, "s" },
      eiji_text = { config.eiji_text, "s" },
      hira_text = { config.hira_text, "s" },
      kata_text = { config.kata_text, "s" },
      hankata_text = { config.hankata_text, "s" },
      zenkaku_text = { config.zenkaku_text, "s" },
      abbrev_text = { config.abbrev_text, "s" },
      border = { config.border, { "s", "f" }, true },
      row = { config.row, "n" },
      col = { config.col, "n" },
      zindex = { config.zindex, "n", true },
      always_shown = { config.always_shown, "b" },
      fade_out_ms = { config.fade_out_ms, "n" },
      ignore_ft = { config.ignore_ft, "t" },
      buf_filter = { config.buf_filter, "f" },
      use_default_highlight = { config.use_default_highlight, "b" },
    }
    self.values = config
  end
end

return setmetatable({ values = default_values }, {
  __index = function(self, key)
    if key == "values" then
      return rawget(self, key)
    elseif key == "setup" then
      return setup(self)
    elseif keys[key] then
      return rawget(rawget(self, "values"), key)
    end
  end,
}) --[[@as SkkeletonIndicatorConfig]]
