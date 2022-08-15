local M = {
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

function M.snake_case(str)
  return str:gsub("[A-Z]?[a-z]+", function(part)
    return part:match("^[A-Z]") and "_" .. part:lower() or part:lower()
  end)
end

function M.snake_case_dict(opts)
  local dict = {}
  for k, v in pairs(opts) do
    dict[M.snake_case(k)] = v
  end
  return dict
end

return M
