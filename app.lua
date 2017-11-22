-- Apisonator works as an api gateway that can redirects traffic from
-- a local endpoint to another endpoint (ip:port) and is able to apply
-- different functions in the various nginx phases (access, content,
-- log...). Think it as a lightweight kong/3scale replacement.

-- Addons are predefined sets of functions that do common things you
-- might want to do like rate limiting, url rewritting, or sending
-- requests to an analytics server somewhere else.

-- Middleware are custom addos set up by the user itself.

-- apisonator is multitennant, so different subdomains might point to
-- different endpoints and apply different functions.




-- It's purpose is to load the appropriate middleware for a given
-- request based on the subdomain of the request, and evaluate the
-- functions of the different addons and middleware in the different
-- nginx phases.
--
-- This is the main driver of apisonator.
--
-- The setup to make a basic roundtrip is:
--
-- - run seed-redis.sh (that sets the subdomain 'foo' to
--   http://httpb.in and enables "test" addon)
--
-- - sudo echo '127.0.0.1   foo' >>/etch/hosts
--
-- - run nginx with the approrpriate paths:
--   /usr/local/openresty/nginx/sbin/nginx -p ./ -c nginx.conf
--
-- - browse to http://foo:8888/get
--
-- - The test addon should print in nginx log the different
--   phases where it runs

local u = require 'utils'; local j = u.j ; local D = u.D ; local i = u.i; local DEBUG = u.D
local redis = require "resty.redis"
local proxy = require 'lib.proxy'
local addon = require 'lib.addon'
local middleware = require 'lib.middleware'

-- Get a connection for redis.
--
-- If REDIS_URL env var exists, picks that one, else default to
-- localhost
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


-- Middleware are similar to addons, but the code is provided by users
-- that can set them up by putting the code in the redis list
-- "at:middleware:subdomain".
local process_middleware = function(subdomain, r)

    -- Middleware,
  local active_middleware = middleware.active_middleware(subdomain, r)
  ngx.ctx.active_middleware = active_middleware

  -- load middleware
  local middleware = map(function(x)
                           local f = assert(loadstring(x))
                           return f()
                         end, active_middleware)

  -- access phase middlewares
  map(function(x)
      if x.access then
        x.access()
      end
      end, middleware)
end

local main = function()

  local r = redis_connect()
  local host = ngx.var.host
  local subdomain = string.split(host, '%.')[1]
  local backend_host = resolve_backend(host, r)

  local active_addons = proxy.active_addons(subdomain, r)
  ngx.ctx.active_addons = active_addons

  --
  -- we prepare the shared space for each addon to mess around and
  -- pass values from phase to phase
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

  -- process_middleware(subdomain, r)
end

main()
