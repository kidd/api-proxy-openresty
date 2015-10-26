local request = require "lib/rate_limit.lua"

request.limit {
    key = ngx.var.remote_addr, rate = 2,
    interval = 10,
    log_level = ngx.NOTICE,
    redis_config = { host = "127.0.0.1", port = 6379, timeout = 1, pool_size = 100 }
  }



ngx.say('Hello World!')
ngx.exit(200)

