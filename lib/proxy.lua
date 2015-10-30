local u = require 'utils'
local M = {}

M.active_addons = function(subdomain, r)
  return r:lrange(j({'at', 'addons', host}, ':'), 0 , -1)
end

return M
