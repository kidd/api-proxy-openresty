require 'utils'
local redis = require "resty.redis"
local request = require "lib/rate_limit"

local redis_connect = function()
  local red = redis:new()
  red:set_timeout(1000) -- 1 sec

  local redisurl = os.getenv("REDIS_URL")
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
      return nil, 'failed to authenticate'
    end

  else
    red:connect('127.0.0.1', '6379')
  end

  return red
end

local resolve_backend = function(server, r)
  local subdomain = j({"at", "domain" , string.split(server, '%.')[1]}, ':')

  ngx.log(DEBUG, 'Redis getting key from ', subdomain)
  local res, err = r:get(subdomain)

  if not res then
    ngx.log(DEBUG, "Failed to get dog: ", err)
    return
  end

  ngx.log(DEBUG, 'Redirect to: ', res)
  return res
end

local main = function()
  local args = ngx.req.get_uri_args()
  ngx.say(ngx.var[args.com])
end

local r = redis_connect()
local backend_host = resolve_backend(ngx.var.host, r)
ngx.var.target = backend_host

-- main()
-- ngx.exit(200)

-- request.limit {
--     key = ngx.var.remote_addr, rate = 5,
--     interval = 10,
--     log_level = ngx.NOTICE,
--     connection = red,
--     redis_config = {timeout = 1000, pool_size = 100 } }
