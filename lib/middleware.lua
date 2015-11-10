local u = require 'utils'
local M = {}

M.active_middleware = function(subdomain, r)
  local function get_middleware_for(host, r)
    return r:lrange(j({'at', 'middleware', host}, ':'), 0, -1)
  end

  return get_middleware_for(subdomain, r)
end

return M
