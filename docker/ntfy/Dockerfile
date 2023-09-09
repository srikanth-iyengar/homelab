FROM httpd
RUN apt update && apt install libapache2-mod-auth-openidc curl -y
RUN cp /usr/lib/apache2/modules/mod_auth_openidc.so /usr/local/apache2/modules/mod_auth_openidc.so
ENTRYPOINT ["httpd-foreground"]
