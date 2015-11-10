local u = require 'utils'
local j = u.j
local D = u.D
local i = u.i
local map = u.map

map(function(addon)
      local a = require(j({"addons",addon, addon}, '.'))
      if a.headers_filter then
        a.headers_filter(r)
      end
    end
  , ngx.ctx.active_addons)
