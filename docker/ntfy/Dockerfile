FROM binwiederhier/ntfy as ntfy-base
FROM alpine
RUN apk update && apk add supervisor
COPY --from=ntfy-base /usr/bin/ntfy /usr/bin/ntfy
COPY ./supervisord.conf /etc/supervisord.conf
COPY ./Caddyfile /etc/caddy/Caddyfile
COPY ./cad-sec /usr/bin/caddy
EXPOSE 80
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
