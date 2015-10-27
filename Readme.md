# Intro

Example of openresty bootstrap for development and deploy on heroku.

Based on https://github.com/leafo/heroku-openresty


## Requirements:
 - lua 5.2
 - openresty
 - redis
 - foreman

## Development

```
$ PORT=8080 foreman start
```

## Deploy on heroku

```
$ heroku create --buildpack http://github.com/leafo/heroku-buildpack-lua.git

# Add the heroku redis addon

$ git push heroku master
```

Enjoy!
