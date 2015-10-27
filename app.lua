local redis = require "resty.redis"
local request = require "lib/rate_limit"

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

local red = redis:new()
red:set_timeout(1000) -- 1 sec

redisurl = os.getenv("REDIS_URL")
if(redisurl) then
  redisurl_connect = string.split(redisurl, ":")[3]
  redisurl_user = string.split(redisurl_connect, "@")[1]
  redisurl_host = string.split(redisurl_connect, "@")[2]
  redisurl_port = tonumber(string.split(redisurl, ":")[4])

  local ok, err = red:connect(redisurl_host, redisurl_port)
  if not ok then
    ngx.say("failed to connect: ", err)
    ngx.exit(ngx.HTTP_OK)
  end

  local res, err = red:auth(redisurl_user)
  if not res then
    ngx.say("failed to authenticate: ", err)
    return
  end

else
  red:connect('127.0.0.1', '6379')
end


request.limit {
    key = ngx.var.remote_addr, rate = 5,
    interval = 10,
    log_level = ngx.NOTICE,
    connection = red,
    redis_config = {timeout = 1000, pool_size = 100 } }


ngx.say("lol")
ngx.exit(200)

