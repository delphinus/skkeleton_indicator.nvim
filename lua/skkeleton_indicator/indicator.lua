local api = require("skkeleton_indicator.util").api
local fn = require("skkeleton_indicator.util").fn
local uv = require("skkeleton_indicator.util").uv
local Modes = require "skkeleton_indicator.modes"

local M = {
  timer = nil,
  winid = {},
}

function M.new(opts)
  opts.ns = api.create_namespace(opts.module_name)
  local self = setmetatable({
    ns = opts.ns,
    modes = Modes.new(opts),
    always_shown = opts.always_shown,
    fade_out_ms = opts.fade_out_ms,
    ignore_ft = opts.ignore_ft,
    buf_filter = opts.buf_filter,
    is_skkeleton_loaded = false,
  }, { __index = M })
  local group = api.create_augroup(opts.module_name, {})
  api.create_autocmd("InsertEnter", { group = group, callback = self:method "open" })
  api.create_autocmd("InsertLeave", { group = group, callback = self:method "close" })
  api.create_autocmd("CursorMovedI", { group = group, callback = self:method "move" })
  api.create_autocmd(
    "User",
    { group = group, pattern = "skkeleton-mode-changed", callback = self:method("update", "mode-changed") }
  )
  api.create_autocmd(
    "User",
    { group = group, pattern = "skkeleton-disable-post", callback = self:method("update", "disable-post") }
  )
  api.create_autocmd(
    "User",
    { group = group, pattern = "skkeleton-enable-post", callback = self:method("update", "enable-post") }
  )
  return self
end

function M:is_disabled()
  if not self.always_shown and (not self.is_skkeleton_loaded or not fn["skkeleton#is_enabled"]()) then
    return true
  end
  local buf = api.get_current_buf()
  local current_ft = api.buf_get_option(buf, "filetype")
  for _, ft in ipairs(self.ignore_ft) do
    if current_ft == ft then
      return true
    end
  end
  return not self.buf_filter(buf)
end

function M:method(name, ...)
  local arg = { ... }
  return function()
    self[name](self, unpack(arg))
  end
end

function M:set_text(buf)
  local mode = self.modes:detect()
  api.buf_set_lines(buf, 0, 0, false, { mode.text })
  api.buf_clear_namespace(buf, self.ns, 0, -1)
  api.buf_add_highlight(buf, self.ns, mode.hl_name, 0, 0, -1)
  self:timer_stop()
  self.timer = vim.defer_fn(self:method "close", self.fade_out_ms)
end

function M:open()
  if self:is_timer_active() or self:is_disabled() then
    return
  end
  local buf = api.create_buf(false, true)
  self:set_text(buf)
  local winid = api.open_win(buf, false, {
    style = "minimal",
    relative = "cursor",
    row = 1,
    col = 1,
    height = 1,
    width = self.modes.width,
    focusable = false,
    noautocmd = true,
  })
  table.insert(self.winid, 1, winid)
end

function M:update(event)
  local function update(is_fast_event)
    -- update() will be called in InsertLeave because skkeleton invokes the
    -- skkeleton-mode-changed event. So here it should checks mode() to confirm
    -- it is in the Insert mode.
    if not self.modes:is_insert() then
      return
    end

    if event == "enable-post" then
      self.is_skkeleton_loaded = true
    elseif event == "disable-post" and not self.always_shown then
      self:close(is_fast_event)
      return
    end

    if self:is_timer_active() then
      local buf = api.win_get_buf(self.winid[1])
      self:set_text(buf)
    else
      self:open()
    end
  end

  if vim.in_fast_event() then
    update(true)
  else
    vim.schedule(update)
  end
end

function M:move()
  if not self:is_timer_active() then
    return
  end
  api.win_set_config(self.winid[1], {
    relative = "cursor",
    row = 1,
    col = 1,
  })
end

function M:close(is_fast_event)
  if not self:is_timer_active() then
    return
  end
  self:timer_stop()
  if #self.winid == 0 then
    return
  end

  local function close(winid)
    local buf = api.win_get_buf(winid)
    api.win_close(winid, true)
    api.buf_clear_namespace(buf, self.ns, 0, -1)
    api.buf_delete(buf, { force = true })
  end

  for i = #self.winid, 1, -1 do
    local winid = self.winid[i]
    if vim.in_fast_event() or is_fast_event then
      close(winid)
    else
      vim.schedule(function()
        close(winid)
      end)
    end
    table.remove(self.winid)
  end
end

function M:is_timer_active()
  return self.timer and uv.is_active(self.timer)
end

function M:timer_stop()
  if self:is_timer_active() then
    self.timer:stop()
    self.timer:close()
  end
end

return M
