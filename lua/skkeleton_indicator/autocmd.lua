local api = require("skkeleton_indicator.util").api

---@class skkeleton_indicator.autocmd.Autocmd
---@field group integer
local Autocmd = {}

---@param module_name string
---@return skkeleton_indicator.autocmd.Autocmd
function Autocmd.new(module_name)
  return setmetatable({ group = api.create_augroup(module_name, {}) }, { __index = Autocmd })
end

---@param defs table
---@return nil
function Autocmd:add(defs) -- luacheck: ignore 212
  for _, def in ipairs(defs) do
    api.create_autocmd(def[1], {
      pattern = def[2],
      callback = def[3],
    })
  end
end

return Autocmd
