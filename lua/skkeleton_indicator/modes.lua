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
    dark = {
      eiji = { fg = "NvimLightBlue", bg = "NvimDarkGrey2", ctermfg = "blue", ctermbg = "black", bold = true },
      hira = { fg = "NvimDarkGrey2", bg = "NvimLightGreen", ctermfg = "black", ctermbg = "green", bold = true },
      kata = { fg = "NvimDarkGrey2", bg = "NvimLightYellow", ctermfg = "black", ctermbg = "yellow", bold = true },
      hankata = { fg = "NvimDarkGrey2", bg = "NvimLightMagenta", ctermfg = "black", ctermbg = "magenta", bold = true },
      zenkaku = { fg = "NvimLightGrey2", bg = "NvimDarkCyan", ctermfg = "black", ctermbg = "cyan", bold = true },
      abbrev = { fg = "NvimLightGrey2", bg = "NvimDarkRed", ctermfg = "white", ctermbg = "red", bold = true },
    },
    light = {
      eiji = { fg = "NvimDarkBlue", bg = "NvimLightGrey2", ctermfg = "blue", ctermbg = "white", bold = true },
      hira = { fg = "NvimDarkGrey2", bg = "NvimLightGreen", ctermfg = "white", ctermbg = "green", bold = true },
      kata = { fg = "NvimDarkGrey2", bg = "NvimLightYellow", ctermfg = "white", ctermbg = "yellow", bold = true },
      hankata = { fg = "NvimDarkGrey2", bg = "NvimLightMagenta", ctermfg = "white", ctermbg = "magenta", bold = true },
      zenkaku = { fg = "NvimDarkGrey2", bg = "NvimLightBlue", ctermfg = "black", ctermbg = "blue", bold = true },
      abbrev = { fg = "NvimDarkGrey2", bg = "NvimLightRed", ctermfg = "black", ctermbg = "red", bold = true },
    },
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
  local is_default_colorscheme = not vim.g.colors_name
  if vim.tbl_isempty(hl) or (is_default_colorscheme and config.use_default_highlight) then
    hl = Mode.default_hl[vim.o.background][name]
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
