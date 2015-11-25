local M = {}

local get_config = function (r)
  local host = ngx.var.host
  local subdomain = string.split(host, '%.') [1]
end

function M.access(r)
end
