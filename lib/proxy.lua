local u = require 'utils'
local M = {}


M.active_addons = function(host, r)
  local function get_addons_for(host, r)
    return r:get(j({'at', 'addons', host}, ':'))
  end

  return string.split(get_addons_for(host, r), ';')
end

return M
