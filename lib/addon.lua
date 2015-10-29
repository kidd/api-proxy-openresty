local M = {}



-- map(function, table)
-- e.g: map(double, {1,2,3})    -> {2,4,6}
function map(func, tbl)
  local newtbl = {}
  for i,v in pairs(tbl) do
    newtbl[i] = func(v)
  end
  return newtbl
end


local keys = function(t)
  local newtbl = {}
  c = 1
  for i,v in pairs(tbl) do
    newtbl[c] = i
    c = c + 1
  end
  return newtbl
end

M.phases = function(addon)
  return keys(addon)
end


return M
