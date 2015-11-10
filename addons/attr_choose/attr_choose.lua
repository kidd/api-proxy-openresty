local M = {}

function string:split(delimiter)
  local result = { }
  local from = 1
  local delim_from, delim_to = string.find( self, delimiter, from )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from )
  end
  table.insert( result, string.sub( self, from ) )
  return result
end

M.access = function()
  local headers = ngx.req.get_headers()
  if headers['X-Requested-Attrs'] then
    local r_headers = headers['X-Requested-Attrs']
    ngx.log(0, #r_headers)
    ngx.ctx.attr_choose = {}
    ngx.ctx.attr_choose.requested_headers = r_headers
  else
    ngx.ctx.attr_choose.requested_headers = nil
  end
end

M.headers_filter = function()
  ngx.header.content_length = nil
end

local function m_split(str)
  ngx.log(0, string.split(str, ", ")[1])
  return string.split(str, ", ")
end

M.body_filter = function()
  local r_headers = ngx.ctx.attr_choose.requested_headers
  if r_headers then
    if not ngx.arg[2] then
      local t = cjson.decode(ngx.arg[1])

      r_headers = string.split(r_headers, ", ")

      local ks = r_headers
      local vs = map(function(x) return t[x] end, r_headers)

      ngx.arg[1] = cjson.encode(tomap(zip(ks, vs)))
    end
  end
end

M.test = function()
  -- foo service = 'http://httpbin.org'
  -- curl "http://localhost:8000/get" -H "apikey: 85d56ec7aea8a7a8e10c068aa194a74f"  -H'Host: foo.asdfa.aa' -H'X-Requested-Attrs: origin, args'
  -- {"args":{},"origin":"88.10.48.55"}
end


return M
