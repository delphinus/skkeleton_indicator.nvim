local api = require'skkeleton_indicator.util'.api
local fn = require'skkeleton_indicator.util'.fn
local Autocmd = require'skkeleton_indicator.autocmd'
local Modes = require'skkeleton_indicator.modes'

local M = {
  funcs = {},
  timer = nil,
  winid = 0,
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
  }, {__index = M})
  Autocmd.new(opts.module_name):add{
    {'InsertEnter', '*', self:method'open'},
    {'InsertLeave', '*', self:method'close'},
    {'CursorMovedI', '*', self:method'move'},
    {'User', 'skkeleton-mode-changed', self:method('update', 'mode-changed')},
    {'User', 'skkeleton-disable-post', self:method('update', 'disable-post')},
    {'User', 'skkeleton-enable-post', self:method('update', 'enable-post')},
  }
  return self
end

function M:is_disabled()
  if not self.always_shown and
    (not self.is_skkeleton_loaded or not fn['skkeleton#is_enabled']()) then
    return true
  end
  local buf = api.get_current_buf()
  local current_ft = api.buf_get_option(buf, 'filetype')
  for _, ft in ipairs(self.ignore_ft) do
    if current_ft == ft then return true end
  end
  return not self.buf_filter(buf)
end

function M:method(name, ...)
  local arg = {...}
  return function() self[name](self, unpack(arg)) end
end

function M:set_text(buf)
  local mode = self.modes:detect()
  api.buf_set_lines(buf, 0, 0, false, {mode.text})
  api.buf_clear_namespace(buf, self.ns, 0, -1)
  api.buf_add_highlight(buf, self.ns, mode.hl_name, 0, 0, -1)
  if self.timer then fn.timer_stop(self.timer) end
  self.timer = fn.timer_start(self.fade_out_ms, self:method'close')
end

function M:open()
  if self.timer or self:is_disabled() then return end
  local buf = api.create_buf(false, true)
  self:set_text(buf)
  self.winid = api.open_win(buf, false, {
    style = 'minimal',
    relative = 'cursor',
    row = 1,
    col = 1,
    height = 1,
    width = self.modes.width,
    focusable = false,
    noautocmd = true,
  })
end

function M:update(event)
  local function update()
    -- update() will be called in InsertLeave because skkeleton invokes the
    -- skkeleton-mode-changed event. So here it should checks mode() to confirm
    -- here is the Insert mode.
    if not self.modes:is_insert() then return end

    if event == 'enable-post' then
      self.is_skkeleton_loaded = true
    elseif event == 'disable-post' and not self.always_shown then
      self:close()
      return
    end

    if self.timer then
      local buf = api.win_get_buf(self.winid)
      self:set_text(buf)
    else
      self:open()
    end
  end
  if vim.in_fast_event() then
    update()
  else
    vim.schedule(update)
  end
end

function M:move()
  if not self.timer then return end
  api.win_set_config(self.winid, {
    relative = 'cursor',
    row = 1,
    col = 1,
  })
end

function M:close()
  if not self.timer then return end
  fn.timer_stop(self.timer)
  self.timer = nil

  if self.winid == 0 then return end
  local buf = api.win_get_buf(self.winid)
  api.win_close(self.winid, false)
  api.buf_clear_namespace(buf, self.ns, 0, -1)
  api.buf_delete(buf, {force = true})
  self.winid = 0
end

return M
