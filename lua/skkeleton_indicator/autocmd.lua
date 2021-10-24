local api = require'skkeleton_indicator.util'.api

local M = {
  funcs = {}
}

function M.new(module_name)
  return setmetatable({module_name = module_name}, {__index = M})
end

function M:add(defs)
  local cmds = {'augroup '..self.module_name}
  for _, def in ipairs(defs) do
    table.insert(self.funcs, def[3])
    local cmd = ([[lua require'%s.autocmd'.funcs[%d]()]]):format(
      self.module_name,
      #self.funcs
    )
    table.insert(cmds, ('autocmd %s %s %s'):format(def[1], def[2], cmd))
  end
  table.insert(cmds, 'augroup END')
  api.exec(table.concat(cmds, '\n'), false)
end

return M
