FROM erkin/schemebbs

## Env
# Last known working versions
ENV NGINX_VERSION 1.18.0

## Prepare build environment
RUN set -x && apk --no-cache --update --virtual build-dependencies add build-base pcre-dev openssl-dev zlib-dev git
WORKDIR /tmp/build
RUN git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git ngx-substitutions \
	&& git clone https://gitlab.com/naughtybits/ngx-fancyindex.git
# Fetch and extract tarball
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN tar xfz nginx-${NGINX_VERSION}.tar.gz

## Build with modules
WORKDIR /tmp/build/nginx-${NGINX_VERSION}
RUN ./configure --prefix=/opt/nginx --add-module=/tmp/build/ngx-fancyindex --add-module=/tmp/build/ngx-substitutions \
	&& make && make install

## Cleanup
WORKDIR /opt/schemebbs
RUN rm -rf /tmp/build \
	&& apk del build-dependencies

## Bring in the supervisor
# nginx needs pcre at runtime
RUN apk --no-cache add supervisor pcre
ADD supervisord.conf /etc/supervisord.conf

## Run
EXPOSE 80
VOLUME /opt/schemebbs/data
CMD supervisord --configuration /etc/supervisord.conf
