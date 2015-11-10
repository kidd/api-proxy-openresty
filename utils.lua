package.path = package.path .. ";lib/?.lua;test/?.lua;./?.lua;"
i = require 'lib.inspect'
pinspect = function(t) print(i(t)) end
j = function(t, s) return table.concat(t, (s or '')) end
local D = ngx.DEBUG

function string:split(delimiter)
  local result = { }
  local from = 1
  local delim_from, delim_to = string.find( self, delimiter, from )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from )
  end
  table.insert( result, string.sub( self, from ) )
  return result
end

-- map(function, table)
-- e.g: map(double, {1,2,3})    -> {2,4,6}
local function map(func, tbl)
  local newtbl = {}
  for i,v in pairs(tbl) do
    newtbl[i] = func(v)
  end
  return newtbl
end

return {
  i = i,
  D = D,
  j = j,
  map = map
}
