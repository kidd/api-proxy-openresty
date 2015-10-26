local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec
local ok, err = red:connect("192.168.99.100", 32768)


local res, err = red:get('sbd:' .. ngx.var.subdomain)


local rack = require 'rack'
local r    = rack.new()

r:use(require "my.middleware")
local response = r:run()
r:respond(response)

