local M = {}

local keys = function(t)
  for k,v in ipairs(t) do
    print(k,v) end
end

M.phases = function(addon)
  keys(addon)
end


return M
