local api = require("skkeleton_indicator.util").api
local fn = require("skkeleton_indicator.util").fn

---@class skkeleton_indicator.modes.Highlight
---@field fg string
---@field bg string
---@field bold boolean

---@alias skkeleton_indicator.modes.ModeName "hira"|"kata"|"hankata"|"zenkaku"

---@class skkeleton_indicator.modes.Mode
---@field name skkeleton_indicator.modes.ModeName
---@field hl_name string
---@field text string
---@field hl skkeleton_indicator.modes.Highlight

---@class skkeleton_indicator.modes.Modes
---@field eiji skkeleton_indicator.modes.Mode
---@field hira skkeleton_indicator.modes.Mode
---@field kata skkeleton_indicator.modes.Mode
---@field hankata skkeleton_indicator.modes.Mode
---@field zenkaku skkeleton_indicator.modes.Mode
---@field modes string[]
---@field width integer
local Modes = {}

---@param opts skkeleton_indicator.indicator.Opts
---@return skkeleton_indicator.modes.Modes
function Modes.new(opts)
  local self = setmetatable({
    eiji = {
      name = "eiji",
      hl_name = opts.module_name .. "_eiji",
      text = opts.eiji_text,
      hl = { fg = "cyan", bg = "black", bold = true },
    },
    hira = {
      name = "hira",
      hl_name = opts.module_name .. "_hira",
      hl = { fg = "black", bg = "green", bold = true },
      text = opts.hira_text,
    },
    kata = {
      name = "kata",
      hl_name = opts.module_name .. "_kata",
      hl = { fg = "black", bg = "yellow", bold = true },
      text = opts.kata_text,
    },
    hankata = {
      name = "hankata",
      hl_name = opts.module_name .. "_hankata",
      hl = { fg = "black", bg = "magenta", bold = true },
      text = opts.hankata_text,
    },
    zenkaku = {
      name = "zenkaku",
      hl_name = opts.module_name .. "_zenkaku",
      hl = { fg = "black", bg = "cyan", bold = true },
      text = opts.zenkaku_text,
    },
    modes = { "eiji", "hira", "kata", "hankata", "zenkaku" },
    width = 0,
  }, { __index = Modes })

  for _, v in ipairs(self.modes) do
    local mode = self[v] --[[@as skkeleton_indicator.modes.Mode]]
    local w = fn.strdisplaywidth(mode.text)
    if w > self.width then
      self.width = w
    end
    ---@type string
    local hl_name = opts[v .. "_hl_name"]
    local ok, hl = pcall(api.get_hl_by_name, hl_name, true)
    if ok then
      mode.hl = hl
    end
  end

  api.create_autocmd("ColorScheme", {
    group = api.create_augroup(opts.module_name .. "_color", {}),
    callback = function()
      self:set_hl()
    end,
  })
  self:set_hl()

  return self
end

function Modes:set_hl()
  for _, v in ipairs(self.modes) do
    ---@type skkeleton_indicator.modes.Mode
    local mode = self[v]
    api.set_hl(0, mode.hl_name, mode.hl)
  end
end

---@return boolean
function Modes:is_insert() -- luacheck: ignore 212
  return fn.mode():find "i" and true or false
end

---@return skkeleton_indicator.modes.Mode
function Modes:detect()
  local ok, m = pcall(fn["skkeleton#mode"])
  if not ok or m == "" then
    return self.eiji
  elseif m == "hira" then
    return self.hira
  elseif m == "kata" then
    return self.kata
  elseif m == "zenkaku" then
    return self.zenkaku
  end
  return self.hankata
end

return Modes
