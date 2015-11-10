local proxy_location = "/___http_call"

-- keep compat with socket.url, just in case
local url = {
  escape =  function(s)
    return (string.gsub(s, "([^A-Za-z0-9_])",
                        function(c)
                          return string.format("%%%02x", string.byte(c))
                        end))
  end
}

-- local inspect = require 'inspect'

local methods = {
  ["GET"] = ngx.HTTP_GET,
  ["HEAD"] = ngx.HTTP_HEAD,
  ["PUT"] = ngx.HTTP_PUT,
  ["POST"] = ngx.HTTP_POST,
  ["DELETE"] = ngx.HTTP_DELETE,
  ["OPTIONS"] = ngx.HTTP_OPTIONS
}
local set_proxy_location = function(loc)
  proxy_location = loc
end

local function encode_query_string( t, prefix )
  local e = url.escape
  local num_or_str = function(x) return  (type(x) == 'string' or type(x) == 'number') end

  local accum = {}
  local val = ''
  for k, v in pairs(t) do
    if num_or_str(v) and prefix  then
      val = prefix .. '[' .. e(k) .. ']=' .. e(v)
    elseif num_or_str(v) then
      val = e(k) .. '=' .. e(v)

    elseif type(v) == 'table' and prefix  then
      val =  encode_query_string(v, prefix ..'[' .. e(k) .. ']')
    elseif type(v) == 'table' then
      val = encode_query_string(v, e(k))
    end
    table.insert(accum, val)
  end
  return table.concat(accum, '&')
end

local simple = function(req, body)
  if type(req) == "string" then
    req = {
      url = req
    }
  end
  if body then
    req.method = "POST"
    req.body = body
  end
  if type(req.body) == "table" then
    req.body = encode_query_string(req.body)
    req.headers = req.headers or { }
    req.headers["Content-type"] = "application/x-www-form-urlencoded"
  end

  local query_string = encode_query_string(req.args or {})
  if query_string then
    req.url = req.url .. "?" .. query_string
  end

  local res = ngx.location.capture(proxy_location, {
    method = methods[req.method or "GET"],

    body = req.body,
    ctx = {
      -- passing the original headers to new request makes nginx segfault
      headers = req.headers
    },
    vars = {
      _url = req.url
    }
  })

  return res.body, res.status, res.header
end

local request
request = function(url, str_body)
  local return_res_body
  local req
  if type(url) == "table" then
    req = url
  else
    return_res_body = true
    req = {
      url = url,
      source = str_body and ltn12.source.string(str_body),
      headers = str_body and {
        ["Content-type"] = "application/x-www-form-urlencoded"
      }
    }
  end
  req.method = req.method or (req.source and "POST" or "GET")
  local body
  if req.source then
    local buff = { }
    local sink = ltn12.sink.table(buff)
    ltn12.pump.all(req.source, sink)
    body = table.concat(buff)
  end
  local res = ngx.location.capture(proxy_location, {
    method = methods[req.method],
    body = body,
    ctx = {
      headers = req.headers
    },
    args = req.args,
    vars = {
      _url = req.url
    }
  })
  local out
  if return_res_body then
    out = res.body
  else
    if req.sink then
      ltn12.pump.all(ltn12.source.string(res.body), req.sink)
    end
    out = 1
  end
  return out, res.status, res.header
end
local ngx_replace_headers
ngx_replace_headers = function(new_headers)
  if new_headers == nil then
    new_headers = nil
  end
  local req
  do
    local _obj_0 = ngx
    req = _obj_0.req
  end
  new_headers = new_headers or ngx.ctx.headers
  for k, v in pairs(req.get_headers()) do
    if k ~= 'content-length' and k ~= 'host' then
      req.clear_header(k)
    end
  end
  if new_headers then
    for k, v in pairs(new_headers) do
      req.set_header(k, v)
    end
  end
end

return {
  request = request,
  simple = simple,
  set_proxy_location = set_proxy_location,
  ngx_replace_headers = ngx_replace_headers
}