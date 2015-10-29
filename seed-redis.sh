#!/usr/bin/env bash
redis-cli SET 'at:subdomain:bar' 'http://httpbin.org'
redis-cli SET 'at:subdomain:foo' 'http://httpbin.org'
redis-cli SET 'at:subdomain:foo' 'https://cardsagainsthumanity-api.herokuapp.com'
