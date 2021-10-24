return {
  fn = vim.fn,
  api = setmetatable({
    _cache = {},
  }, {
    __index = function(self, name)
      if not self._cache[name] then
        self._cache[name] = vim.api['nvim_'..name]
      end
      return self._cache[name]
    end,
  }),
}
