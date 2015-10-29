local threescale = require "threescale"

local service = {
  id            = "2555417724260",
  auth_key_name = "apikey"
}

local function get_auth_params(request)
  local headers = ngx.req.get_headers()
  if headers[service.auth_key_name] then
    return headers[service.auth_key_name]
  else
    ngx.status = 403
    ngx.print("Authentication parameters missing")
    ngx.exit(ngx.HTTP_OK)
  end
end

-- get threescale method based on the request
-- example:
--    - input: "GET /api/endpoint/"
--    - method: "GET_api_endpoint"
local function get_threescale_method(request)
  local method, path, query_fragment = request:match("^(.+) ([^%?]+)(%??.*) .+$")
  local parsed_path = path:gsub("^%/", ""):gsub("%/$", "")
  return method .. "_" .. parsed_path
end

local function authorize(key, usage, service)
  local authrep = threescale.authrep(service.id, key, usage)
  if authrep.status ~= 200 then
    ngx.status = 403
    ngx.print("Authentication failed")
    ngx.exit(ngx.HTTP_OK)
  end
end

local key = get_auth_params()
local threescale_method = get_threescale_method(ngx.var.request)
ngx.log(0, threescale_method)
local usage = { [threescale_method] = 1 }
authorize(key, usage, service)
