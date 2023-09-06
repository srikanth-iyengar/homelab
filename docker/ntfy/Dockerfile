FROM binwiederhier/ntfy as ntfy-base
FROM openresty/openresty:alpine-fat
 
RUN mkdir /var/log/nginx
 
RUN apk add --no-cache openssl-dev
RUN apk add --no-cache git
RUN apk add --no-cache gcc
RUN apk add --no-cache supervisor
RUN luarocks install lua-resty-openidc

COPY --from=ntfy-base /usr/bin/ntfy /usr/bin/ntfy
 
EXPOSE 80
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
