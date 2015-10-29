#!/usr/bin/env bash
redis-cli SET 'at:domain:bar' 'http://httpbin.org'
redis-cli SET 'at:domain:foo' 'http://httpbin.org'
