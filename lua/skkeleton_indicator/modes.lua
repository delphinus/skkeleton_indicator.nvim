local config = require "skkeleton_indicator.config"

---@alias SkkeletonIndicatorModeName "eiji"|"hira"|"kata"|"hankata"|"zenkaku"|"abbrev"

---@class SkkeletonIndicatorMode
---@field defaults table<string, vim.api.keyset.highlight>
---@field text string
---@field hl vim.api.keyset.highlight
---@field hl_name string
---@field name string
---@field width integer
local Mode = {
  default_hl = {
    eiji = { fg = "cyan", bg = "black", bold = true },
    hira = { fg = "black", bg = "green", bold = true },
    kata = { fg = "black", bg = "yellow", bold = true },
    hankata = { fg = "black", bg = "magenta", bold = true },
    zenkaku = { fg = "black", bg = "cyan", bold = true },
    abbrev = { fg = "black", bg = "red", bold = true },
  },
}

---@param name SkkeletonIndicatorModeName
---@return SkkeletonIndicatorMode
function Mode.new(name)
  local self = setmetatable(
    { name = name, hl_name = config[name .. "_hl_name"], text = config[name .. "_text"] },
    { __index = Mode }
  )
  self.width = vim.fn.strdisplaywidth(self.text)
  local hl = vim.api.nvim_get_hl(0, { name = self.hl_name }) --[[@as vim.api.keyset.highlight]]
  if vim.tbl_isempty(hl) then
    hl = Mode.default_hl[name]
  end
  vim.api.nvim_set_hl(0, self.hl_name, hl)
  return self
end

---@class SkkeletonIndicatorModes
---@field modes table<SkkeletonIndicatorModeName, SkkeletonIndicatorMode>
local Modes = {}

---@return SkkeletonIndicatorModes
function Modes.new()
  return setmetatable({
    modes = vim.iter({ "eiji", "hira", "kata", "hankata", "zenkaku", "abbrev" }):fold({}, function(a, b)
      a[b] = Mode.new(b)
      return a
    end),
  }, { __index = Modes })
end

---@return boolean
function Modes:is_insert() -- luacheck: ignore 212
  return not not vim.api.nvim_get_mode().mode:find "i"
end

---@return SkkeletonIndicatorMode
function Modes:detect()
  ---@type boolean, ""|SkkeletonIndicatorModeName|nil
  local ok, name = pcall(vim.fn["skkeleton#mode"])
  if not ok or name == "" then
    name = "eiji"
  end
  return self.modes[name]
end

return Modes
