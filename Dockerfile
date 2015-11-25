FROM ubuntu:14.04
MAINTAINER 3scale <support@3scale.net>

ENV    DEBIAN_FRONTEND noninteractive
RUN    echo "deb-src http://archive.ubuntu.com/ubuntu trusty main" >> /etc/apt/sources.list
RUN    sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN    apt-get update
RUN    apt-get upgrade -y
RUN    apt-get -y install wget vim git libpq-dev

# Openresty (Nginx)
RUN    apt-get -y build-dep nginx \
  && apt-get -q -y clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN    wget http://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz \
  && tar xvfz ngx_openresty-1.9.3.1.tar.gz \
  && cd ngx_openresty-1.9.3.1 \
  && ./configure --with-luajit  --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-http_postgres_module --with-pcre-jit \
  && make \
  && make install \
  && rm -rf /ngx_openresty*

EXPOSE 8080

RUN cd /usr/local/bin && ln -s ../openresty/luajit/bin/luajit-2.1.0-alpha lua
RUN cd /usr/local/bin && ln -s /usr/local/openresty/nginx/sbin/nginx
# CMD /usr/local/openresty/nginx/sbin/nginx -p `pwd` -c nginx.conf.compiled
COPY . /opt/apisonator
WORKDIR /opt/apisonator
ENV REDIS_URL 172.17.0.1
ENV PORT 8080
CMD sh /opt/apisonator/start_nginx.sh
