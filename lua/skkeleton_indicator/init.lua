local fn = vim.fn
local api = setmetatable({}, {
  __index = function(_, name) return vim.api['nvim_'..name] end
})

local M = {
  funcs = {},
  my_name = (function()
    local file = debug.getinfo(1, 'S').source
    return file:match'/([^/]+)/[^/]+.lua$'
  end)(),
  modes = {
    eiji = {
      hl_name = 'skkeleton_indicator_eiji',
      hl = {fg = '#88c0d0', bg = '#2e3440', bold = true},
      text = '英字',
    },
    hira = {
      hl_name = 'skkeleton_indicator_hira',
      hl = {fg = '#2e3440', bg = '#a3be8c', bold = true},
      text = 'ひら',
    },
    kata = {
      hl_name = 'skkeleton_indicator_kata',
      hl = {fg = '#2e3440', bg = '#ebcb8b', bold = true},
      text = 'カタ',
    },
  },
  fade_out_ms = 3000,
}

function M.new()
  return setmetatable({
    ns = api.create_namespace(M.my_name),
    timer = nil,
    winid = 0,
  }, { __index = M })
end

function M.setup()
  local self = M.new()
  api._set_hl_ns(self.ns)
  for _, v in pairs(M.modes) do api.set_hl(self.ns, v.hl_name, v.hl) end
  self:autocmd{
    {'InsertEnter', '*', self:method'open'},
    {'InsertLeave', '*', self:method'close'},
    {'CursorMovedI', '*', self:method'move'},
    {'User', 'skkeleton-mode-changed', self:method'update'},
    {'User', 'skkeleton-disable-post', self:method'update'},
    {'User', 'skkeleton-enable-post', self:method'update'},
  }
end

function M:method(name)
  return function() self[name](self) end
end

function M:autocmd(defs)
  local cmds = {'augroup '..M.my_name}
  for _, def in ipairs(defs) do
    table.insert(M.funcs, def[3])
    local cmd = ([[lua require'%s'.funcs[%d]()]]):format(M.my_name, #M.funcs)
    table.insert(cmds, ('autocmd %s %s %s'):format(def[1], def[2], cmd))
  end
  table.insert(cmds, 'augroup END')
  api.exec(table.concat(cmds, '\n'), false)
end

function M:skk_mode()
  local ok, m = pcall(fn['skkeleton#mode'])
  if not ok or m == '' then
    return M.modes.eiji
  elseif m == 'hira' then
    return M.modes.hira
  end
  return M.modes.kata
end

function M:set_text(buf)
  local mode = self:skk_mode()
  api.buf_set_lines(buf, 0, 0, false, {mode.text})
  api.buf_clear_namespace(buf, self.ns, 0, -1)
  api.buf_add_highlight(buf, self.ns, mode.hl_name, 0, 0, -1)
  if self.timer then fn.timer_stop(self.timer) end
  self.timer = fn.timer_start(M.fade_out_ms, self:method'close')
end

function M:open()
  if self.timer then return end
  local buf = api.create_buf(false, true)
  self:set_text(buf)
  self.winid = api.open_win(buf, false, {
    style = 'minimal',
    relative = 'cursor',
    row = 1,
    col = 1,
    height = 1,
    width = 4,
    focusable = false,
    noautocmd = true,
  })
end

function M:update()
  local function update()
    -- update() will be called in InsertLeave because skkeleton invokes the
    -- skkeleton-mode-changed event. So here it should checks mode() to confirm
    -- here is the Insert mode.
    if not fn.mode():find'i' then return end

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
