---@param str string
---@return string
local function snake_case(str)
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

---@param orig table<string, any>
---@return table<string, any>
local function snake_case_dict(orig)
  return vim.iter(orig):fold({}, function(acc, key, value)
    acc[snake_case(key)] = value
    return acc
  end)
end

return { snake_case = snake_case, snake_case_dict = snake_case_dict }
