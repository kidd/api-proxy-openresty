local u = require 'utils'
local j = u.j
local D = u.D
local i = u.i
local map = u.map

map(function(addon)
      local a = require(j({"addons",addon, addon}, '.'))
      if a.body_filter then
        a.body_filter(r)
      end
    end
  , ngx.ctx.active_addons)
