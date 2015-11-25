local u = require 'utils'; local j = u.j ; local D = u.D ; local i = u.i; local DEBUG = u.D
local redis = require "resty.redis"
local proxy = require 'lib.proxy'
local addon = require 'lib.addon'
local middleware = require 'lib.middleware'

local redis_connect = function()
  local red = redis:new()
  red:set_timeout(1000) -- 1 sec

  local redisurl = os.getenv("REDIS_URL") or '127.0.0.1'

  if(redisurl and string.find(redisurl, '@')) then
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
    red:connect(redisurl, '6379')
  end

  return red
end

local resolve_backend = function(server, r)
  local subdomain = u.j({"at", "subdomain" , string.split(server, '%.')[1]}, ':')

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
local subdomain = string.split(host, '%.')[1]
ngx.log(D, subdomain)
local backend_host = resolve_backend(host, r)

local active_addons = proxy.active_addons(subdomain, r)
ngx.ctx.active_addons = active_addons

-- we prepare the shared space for each addon to mess around
map(function(addon) ngx.ctx[addon] = {} end, active_addons)

-- target of the proxy pass
ngx.var.target = backend_host

-- Access addons
each(function(addon)
      local a = require(j({"addons",addon, addon}, '.'))
      if a.access then
        a.access(r)
      end
    end
  , iter(active_addons))

local active_middleware = middleware.active_middleware(subdomain, r)
ngx.ctx.active_middleware = active_middleware

-- load middleware
local middleware = map(function(x)
    local f = assert(loadstring(x))
    return f()
    end, active_middleware)

-- access middleware
map(function(x)
    if x.access then
      x.access()
    end
    end, middleware)
