local M = {}

M.access = function()
  ngx.log(0, "ACCESS PHASE")
end

M.content = function()
  ngx.log(0, "content phase")
end

M.headers_filter = function()
  ngx.log(0, "headers filter phase")
end

M.body_filter = function()
  ngx.log(0, "body filter phase")
end

return M
