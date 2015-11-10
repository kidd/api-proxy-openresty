local threescale = {
  config = {
    api_host     = "https://su1.3scale.net",
    provider_key = "f82cb6bfe905cf038e5a1f62ec1a3fc8"
  }
}

local http = require "addons.threescale_auth.http"

local function add_trans(usage)
  local us = usage:split("&")
  local ret = ""
  for i,v in ipairs(us) do
    ret =  ret .. "transactions[0][usage]" .. string.sub(v, 6) .. "&"
  end
  return string.sub(ret, 1, -2)
end

function threescale.authorize(service_id, user_key, usage)
  local path   = "/transactions/authorize.xml"
  local method = "GET"
  local url    = threescale.config.api_host .. path
  local params = {
    provider_key = threescale.config.provider_key,
    service_id   = service_id,
    usage        = usage,
    user_key     = user_key
  }

  local res_body, res_status, res_header = http.simple({ url = url, method = method, args = params })

  return {
    body   = res_body,
    status = res_status,
    header = res_header,
  }
end

function threescale.authrep(service_id, user_key, usage)
  local path   = "/transactions/authrep.xml"
  local method = "GET"
  local url    = threescale.config.api_host .. path
  local params = {
    provider_key = threescale.config.provider_key,
    service_id   = service_id,
    usage        = usage,
    user_key     = user_key
  }

  local res_body, res_status, res_header = http.simple({url = url, method = method, args = params })

  return {
    body   = res_body,
    status = res_status,
    header = res_header,
  }
end

function threescale.report(service_id, user_key, usage)
  local path   = "/transactions.xml"
  local method = "POST"
  local url    = threescale.config.api_host .. path

  local body = {
    provider_key = threescale.config.provider_key,
    service_id   = service_id,
    transactions = {
       {
    usage    = usage,
    user_key = user_key
       }
    }
  }

  local res_body, res_status, res_header = http.simple({ url = url }, body)

  return {
    body   = res_body,
    status = res_status,
    header = res_header,
  }
end

return threescale
