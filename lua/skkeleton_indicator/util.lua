local Util = {
  uv = vim.loop,
  fn = vim.fn,
  api = setmetatable({
    _cache = {},
  }, {
    __index = function(self, name)
      if not self._cache[name] then
        self._cache[name] = vim.api["nvim_" .. name]
      end
      return self._cache[name]
    end,
  }),
}

---@param str string
---@return string
function Util.snake_case(str)
  local converted, _ = str:gsub(
    "[A-Z]?[a-z]+",
    ---@param part string
    ---@return string
    function(part)
      return part:match "^[A-Z]" and "_" .. part:lower() or part:lower()
    end
  )
  return converted
end

---@param orig table
---@return table
function Util.snake_case_dict(orig)
  local dict = {}
  for k, v in pairs(orig) do
    dict[Util.snake_case(k)] = v
  end
  return dict
end

return Util
