local Modes = require "skkeleton_indicator.modes"
local config = require "skkeleton_indicator.config"

---@alias SkkeletonIndicatorBorder
---| "none"
---| "single"
---| "double"
---| "rounded"
---| "solid"
---| "shadow"
---| string[]
---| string[][]

---@class SkkeletonIndicatorBorderArgs
---@field mode SkkeletonIndicatorModeName

---@alias SkkeletonIndicatorBorderOpt
---| SkkeletonIndicatorBorder?
---| fun(args: SkkeletonIndicatorBorderArgs): SkkeletonIndicatorBorder?

---@class SkkeletonIndicator
---@field ns integer
---@field modes SkkeletonIndicatorModes
---@field is_skkeleton_loaded boolean
---@field timer uv_timer_t
---@field winid integer[]
local Indicator = {}

---@return SkkeletonIndicator
function Indicator.new()
  local self = setmetatable({
    is_skkeleton_loaded = false,
    ns = vim.api.nvim_create_namespace(config.module_name),
    modes = Modes.new(),
    timer = vim.uv.new_timer(),
    winid = {},
  }, { __index = Indicator })
  local group = vim.api.nvim_create_augroup(config.module_name, {})
  vim
    .iter({
      { "InsertEnter", "*", self:method "open" },
      { "InsertLeave", "*", self:method "close" },
      { "CursorMovedI", "*", self:method "move" },
      { "User", "skkeleton-mode-changed", self:method("update", "mode-changed") },
      { "User", "skkeleton-disable-post", self:method("update", "disable-post") },
      { "User", "skkeleton-enable-post", self:method("update", "enable-post") },
    })
    :each(function(def)
      vim.api.nvim_create_autocmd(def[1], { group = group, pattern = def[2], callback = def[3] })
    end)
  return self
end

---@return boolean
function Indicator:is_disabled()
  if not config.always_shown and (not self.is_skkeleton_loaded or not vim.fn["skkeleton#is_enabled"]()) then
    return true
  end
  ---@type integer
  local buf = vim.api.nvim_get_current_buf()
  return vim.tbl_contains(config.ignore_ft, vim.bo[buf].filetype) or not config.buf_filter(buf)
end

---@param name string
---@param ... unknown
---@return fun(): nil
function Indicator:method(name, ...)
  local arg = { ... }
  ---@return nil
  return function()
    self[name](self, unpack(arg))
  end
end

---@param buf integer
---@param mode SkkeletonIndicatorMode
---@return nil
function Indicator:set_text(buf, mode)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { mode.text })
  vim.api.nvim_buf_clear_namespace(buf, self.ns, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, self.ns, mode.hl_name, 0, 0, -1)
  self.timer:stop()
  if config.fade_out_ms > 0 then
    self.timer:start(config.fade_out_ms, 0, self:method "close")
  end
end

---@param mode SkkeletonIndicatorMode
---@return SkkeletonIndicatorBorder?
function Indicator:border(mode)
  local border_opt = config.border
  if type(border_opt) == "function" then
    return border_opt { mode = mode.name } or { " " }
  end
  return border_opt
end

---@param winid integer
---@param mode SkkeletonIndicatorMode
function Indicator:border_highlight(winid, mode)
  vim.wo[winid].winhighlight = "FloatBorder:" .. mode.hl_name
end

---@return nil
function Indicator:open()
  if self:is_opened() or self:is_disabled() or self:is_in_cmdwin() then
    return
  end
  local mode = self.modes:detect()
  local buf = vim.api.nvim_create_buf(false, true)
  self:set_text(buf, mode)
  ---@type integer
  local winid = vim.api.nvim_open_win(buf, false, {
    style = "minimal",
    relative = "cursor",
    row = config.row,
    col = config.col,
    height = 1,
    width = mode.width,
    focusable = false,
    noautocmd = true,
    border = self:border(mode),
    zindex = config.zindex,
  })
  self:border_highlight(winid, mode)
  table.insert(self.winid, 1, winid)
end

---@param event string
---@return nil
function Indicator:update(event)
  vim.schedule(function()
    -- update() will be called in InsertLeave because skkeleton invokes the
    -- skkeleton-mode-changed event. So here it should checks mode() to confirm
    -- it is in the Insert mode.
    if not self.modes:is_insert() then
      return
    end

    if event == "enable-post" then
      self.is_skkeleton_loaded = true
    elseif event == "disable-post" and not config.always_shown then
      self:close()
      return
    end

    if self:is_opened() then
      local winid = self.winid[1]
      local mode = self.modes:detect()
      local buf = vim.api.nvim_win_get_buf(winid)
      self:set_text(buf, mode)
      vim.api.nvim_win_set_config(winid, { border = self:border(mode), width = mode.width })
      self:border_highlight(winid, mode)
    else
      self:open()
    end
  end)
end

---@return nil
function Indicator:move()
  if self:is_opened() and self.winid[1] then
    local mode = self.modes:detect()
    vim.api.nvim_win_set_config(self.winid[1], {
      relative = "cursor",
      row = config.row,
      col = config.col,
      width = mode.width,
    })
  end
end

---@return nil
function Indicator:close()
  self.timer:stop()
  if not self:is_opened() then
    return
  end

  vim.iter(self.winid):rev():each(vim.schedule_wrap(function(winid)
    local buf = vim.api.nvim_win_get_buf(winid)
    vim.api.nvim_win_close(winid, true)
    vim.api.nvim_buf_clear_namespace(buf, self.ns, 0, -1)
    vim.api.nvim_buf_delete(buf, { force = true })
  end))
  self.winid = {}
end

---@return boolean
function Indicator:is_opened()
  return #self.winid > 0
end

function Indicator:is_in_cmdwin()
  return vim.fn.getcmdwintype() ~= ""
end

return setmetatable({}, { __call = Indicator.new }) --[[@as fun(): SkkeletonIndicator]]
