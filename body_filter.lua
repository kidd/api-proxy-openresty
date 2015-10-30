require 'utils'

j = function(t, s) return table.concat(t, (s or '')) end

function map(func, tbl)
  local newtbl = {}
  for i,v in pairs(tbl) do
    newtbl[i] = func(v)
  end
  return newtbl
end

function body_filter(addon)
  local a = require(j({"addons",addon, addon}, '.'))
  if a.body_filter then
    ngx.log(0, "body will be " ,i(a))
    a.body_filter()
  end
end

map(body_filter, ngx.ctx.active_addons)
