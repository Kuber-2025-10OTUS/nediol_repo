# build
FROM alpine:3.19 AS builder

RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    linux-headers \
    curl

ENV NGINX_VERSION=1.29.4

RUN curl -O http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar -xzf nginx-$NGINX_VERSION.tar.gz

WORKDIR /nginx-$NGINX_VERSION

RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --with-http_stub_status_module

RUN make -j$(nproc) && make install

# runtime
FROM alpine:3.19

RUN apk add --no-cache pcre zlib openssl

COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx

COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
