local api = require("skkeleton_indicator.util").api
local fn = require("skkeleton_indicator.util").fn
local uv = require("skkeleton_indicator.util").uv
local Autocmd = require "skkeleton_indicator.autocmd"
local Modes = require "skkeleton_indicator.modes"

---@alias skkeleton_indicator.indicator.Border
---| "none"
---| "single"
---| "double"
---| "rounded"
---| "solid"
---| "shadow"
---| string[]
---| string[][]

---@class skkeleton_indicator.indicator.BorderArgs
---@field mode skkeleton_indicator.modes.ModeName

---@alias skkeleton_indicator.indicator.BorderOpt
---| skkeleton_indicator.indicator.Border?
---| fun(args: skkeleton_indicator.indicator.BorderArgs): skkeleton_indicator.indicator.Border?

---@class skkeleton_indicator.indicator.Opts
---@field module_name string
---@field eiji_hl_name string
---@field hira_hl_name string
---@field kata_hl_name string
---@field hankata_hl_name string
---@field zenkaku_hl_name string
---@field eiji_text string
---@field hira_text string
---@field kata_text string
---@field hankata_text string
---@field zenkaku_text string
---@field border skkeleton_indicator.indicator.BorderOpt
---@field row integer
---@field col integer
---@field always_shown boolean
---@field fade_out_ms integer
---@field ignore_ft string[]
---@field buf_filter fun(buf: integer): boolean

---@class skkeleton_indicator.indicator.Indicator
---@field ns integer
---@field modes skkeleton_indicator.modes.Modes
---@field opts skkeleton_indicator.indicator.Opts
---@field is_skkeleton_loaded boolean
---@field winid integer[]
local Indicator = {
  timer = uv.new_timer(),
  winid = {},
}

---@return skkeleton_indicator.indicator.Indicator
function Indicator.new()
  local self = setmetatable({
    is_skkeleton_loaded = false,
  }, { __index = Indicator })
  return self
end

---@param opts skkeleton_indicator.indicator.Opts
---@return nil
function Indicator:setup(opts)
  self.opts = opts
  self.ns = api.create_namespace(opts.module_name)
  self.modes = Modes.new(opts)
  Autocmd.new(opts.module_name):add {
    { "InsertEnter", "*", self:method "open" },
    { "InsertLeave", "*", self:method "close" },
    { "CursorMovedI", "*", self:method "move" },
    { "User", "skkeleton-mode-changed", self:method("update", "mode-changed") },
    { "User", "skkeleton-disable-post", self:method("update", "disable-post") },
    { "User", "skkeleton-enable-post", self:method("update", "enable-post") },
  }
end

---@return boolean
function Indicator:is_disabled()
  if not self.opts.always_shown and (not self.is_skkeleton_loaded or not fn["skkeleton#is_enabled"]()) then
    return true
  end
  ---@type integer
  local buf = api.get_current_buf()
  ---@type string
  local current_ft = api.buf_get_option(buf, "filetype")
  for _, ft in ipairs(self.opts.ignore_ft) do
    if current_ft == ft then
      return true
    end
  end
  return not self.opts.buf_filter(buf)
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
---@param mode skkeleton_indicator.modes.Mode
---@return nil
function Indicator:set_text(buf, mode)
  api.buf_set_lines(buf, 0, 0, false, { mode.text })
  api.buf_clear_namespace(buf, self.ns, 0, -1)
  api.buf_add_highlight(buf, self.ns, mode.hl_name, 0, 0, -1)
  self.timer:stop()
  if self.opts.fade_out_ms > 0 then
    self.timer:start(self.opts.fade_out_ms, 0, self:method "close")
  end
end

---@param mode skkeleton_indicator.modes.Mode
---@return skkeleton_indicator.indicator.Border?
function Indicator:border(mode)
  local border_opt = self.opts.border
  if type(border_opt) == "function" then
    return border_opt { mode = mode.name } or { " " }
  end
  return border_opt
end

---@param winid integer
---@param mode skkeleton_indicator.modes.Mode
function Indicator:border_highlight(winid, mode)
  vim.wo[winid].winhighlight = "FloatBorder:" .. mode.hl_name
end

---@return nil
function Indicator:open()
  if self:is_opened() or self:is_disabled() or self:is_in_cmdwin() then
    return
  end
  local mode = self.modes:detect()
  ---@type integer
  local buf = api.create_buf(false, true)
  self:set_text(buf, mode)
  ---@type integer
  local winid = api.open_win(buf, false, {
    style = "minimal",
    relative = "cursor",
    row = self.opts.row,
    col = self.opts.col,
    height = 1,
    width = self.modes.width,
    focusable = false,
    noautocmd = true,
    border = self:border(mode),
  })
  self:border_highlight(winid, mode)
  table.insert(self.winid, 1, winid)
end

---@param event string
---@return nil
function Indicator:update(event)
  ---@return nil
  local function update()
    -- update() will be called in InsertLeave because skkeleton invokes the
    -- skkeleton-mode-changed event. So here it should checks mode() to confirm
    -- it is in the Insert mode.
    if not self.modes:is_insert() then
      return
    end

    if event == "enable-post" then
      self.is_skkeleton_loaded = true
    elseif event == "disable-post" and not self.opts.always_shown then
      self:close()
      return
    end

    if self:is_opened() then
      local winid = self.winid[1]
      local mode = self.modes:detect()
      ---@type integer
      local buf = api.win_get_buf(winid)
      self:set_text(buf, mode)
      api.win_set_config(winid, { border = self:border(mode) })
      self:border_highlight(winid, mode)
    else
      self:open()
    end
  end

  vim.schedule(update)
end

---@return nil
function Indicator:move()
  if self:is_opened() and self.winid[1] then
    api.win_set_config(self.winid[1], {
      relative = "cursor",
      row = self.opts.row,
      col = self.opts.col,
    })
  end
end

---@return nil
function Indicator:close()
  self.timer:stop()
  if not self:is_opened() then
    return
  end

  ---@param winid integer
  ---@return nil
  local function close(winid)
    ---@type integer
    local buf = api.win_get_buf(winid)
    api.win_close(winid, true)
    api.buf_clear_namespace(buf, self.ns, 0, -1)
    api.buf_delete(buf, { force = true })
  end

  for i = #self.winid, 1, -1 do
    local winid = self.winid[i]
    vim.schedule(function()
      close(winid)
    end)
    table.remove(self.winid)
  end
end

---@return boolean
function Indicator:is_opened()
  return #self.winid > 0
end

function Indicator:is_in_cmdwin()
  return fn.getcmdwintype() ~= ""
end

return Indicator
