# Intro

Apisonator works as an api gateway that can redirects traffic from
a local endpoint to another endpoint (ip:port) and is able to apply
different functions in the various nginx phases (access, content,
log...). Think it as a lightweight kong/3scale replacement.

Addons are predefined sets of functions that do common things you
might want to do like rate limiting, url rewritting, or sending
requests to an analytics server somewhere else.

Middleware are custom addos set up by the user itself.

apisonator is multitennant, so different subdomains might point to
different endpoints and apply different functions.



## Requirements:
 - openresty
 - redis

Enjoy!
