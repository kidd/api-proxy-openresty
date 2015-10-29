require 'utils'
local redis = require "resty.redis"
local redis = require "resty.redis"
local request = require "lib/rate_limit"
local proxy = require 'lib.proxy'
local addon = require 'lib.addon'

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
  local subdomain = j({"at", "subdomain" , string.split(server, '%.')[1]}, ':')

  ngx.log(DEBUG, 'Redis getting key from ', subdomain)
  local res, err = r:get(subdomain)

  if ((not res) or res == ngx.null) then
    ngx.log(DEBUG, "Failed to get dog: ", err)
    ngx.say("subdomain not valid")
    ngx.exit(404)
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
local host = ngx.var.host
local backend_host = resolve_backend(host, r)

-- local active_addons = proxy.active_addons(host, r)
local active_addons = {}
active_addons = {'test', 'threescale_auth'}

ngx.var.target = backend_host

map(function(addon)
      local a = require(j({"addons",addon, addon}, '.'))
      if a.access then
        a.access()
      end
    end, active_addons)


-- main()
-- ngx.exit(200)

-- request.limit {
--     key = ngx.var.remote_addr, rate = 5,
--     interval = 10,
--     log_level = ngx.NOTICE,
--     connection = red,
--     redis_config = {timeout = 1000, pool_size = 100 } }
