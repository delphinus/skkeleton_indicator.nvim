---@alias SkkeletonIndicatorImeName "skkeleton"|"goda-skk"

---@class SkkeletonIndicatorIme
---@field name SkkeletonIndicatorImeName
---@field event_prefix string the prefix of its User events, such as "skkeleton-mode-changed"
---@field is_enabled fun(): boolean
---@field mode fun(): ""|SkkeletonIndicatorModeName|nil "" while it is disabled

-- The input methods the indicator follows. They have the same events (with
-- their own prefix) and the same names of the modes.
---@type SkkeletonIndicatorIme[]
local imes = {
  {
    name = "skkeleton",
    event_prefix = "skkeleton",
    is_enabled = function()
      local ok, enabled = pcall(vim.fn["skkeleton#is_enabled"])
      return ok and enabled
    end,
    mode = function()
      local ok, mode = pcall(vim.fn["skkeleton#mode"])
      return ok and mode or nil
    end,
  },
  {
    -- https://github.com/Shougo/goda-skk.vim
    name = "goda-skk",
    event_prefix = "goda-skk",
    is_enabled = function()
      return vim.g["goda_skk#enabled"] == true
    end,
    mode = function()
      return vim.g["goda_skk#mode"]
    end,
  },
}

return imes
