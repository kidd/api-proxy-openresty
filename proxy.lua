local headers = ngx.req.get_headers(0)
local endpoint = headers["X-Proxy-Endpoint"]
local path = headers["X-Proxy-Path"]
local query = headers["X-Proxy-Query"]

local target = endpoint

if path then
  target = target .. path
  if query then
    target = target .. '?' .. query
  end
end

ngx.var.target = target
