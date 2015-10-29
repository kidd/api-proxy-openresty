local u = require 'utils'
local M = {}

M.active_addons = function(subdomain, r)
  local function get_addons_for(host, r)
    return r:get(j({'at', 'addons', host}, ':'))
  end

  return string.split(get_addons_for(subdomain, r), ';')
end

return M
