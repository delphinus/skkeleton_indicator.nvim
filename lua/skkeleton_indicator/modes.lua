local api = require("skkeleton_indicator.util").api
local fn = require("skkeleton_indicator.util").fn

local M = {}

function M.new(opts)
  local self = setmetatable({
    eiji = {
      hl_name = opts.module_name .. "_eiji",
      text = opts.eiji_text,
      hl = { fg = "cyan", bg = "black", bold = true },
    },
    hira = {
      hl_name = opts.module_name .. "_hira",
      hl = { fg = "black", bg = "green", bold = true },
      text = opts.hira_text,
    },
    kata = {
      hl_name = opts.module_name .. "_kata",
      hl = { fg = "black", bg = "yellow", bold = true },
      text = opts.kata_text,
    },
    hankata = {
      hl_name = opts.module_name .. "_hankata",
      hl = { fg = "black", bg = "magenta", bold = true },
      text = opts.hankata_text,
    },
    zenkaku = {
      hl_name = opts.module_name .. "_zenkaku",
      hl = { fg = "black", bg = "cyan", bold = true },
      text = opts.zenkaku_text,
    },
    width = 0,
  }, { __index = M })

  -- opts.eiji_hl_name
  -- opts.hira_hl_name
  -- opts.kata_hl_name
  -- opts.hankata_hl_name
  for _, v in ipairs { "eiji", "hira", "kata", "hankata", "zenkaku" } do
    local mode = self[v]
    local w = fn.strdisplaywidth(mode.text)
    if w > self.width then
      self.width = w
    end
    local hl_name = opts[v .. "_hl_name"]
    local ok, hl = pcall(api.get_hl_by_name, hl_name, true)
    if ok then
      mode.hl = hl
    end
    api.set_hl(0, mode.hl_name, mode.hl)
  end

  return self
end

function M:is_insert()
  return fn.mode():find "i"
end

function M:detect()
  local ok, m = pcall(fn["skkeleton#mode"])
  if not ok or m == "" then
    return self.eiji
  elseif m == "hira" then
    return self.hira
  elseif m == "kata" then
    return self.kata
  elseif m == "zenkaku" then
    return self.zenkaku
  end
  return self.hankata
end

return M
