FROM wpvipdev/alpine:3.12.0-1

ARG WP_VERSION

RUN apk add --no-cache --virtual build-deps git && \
    apk add --no-cache rsync && \
    git clone --branch $WP_VERSION --depth 1 https://github.com/WordPress/WordPress /wp && \
    mkdir /wp/config /wp/log /wp/wp-content/mu-plugins /wp/wp-content/client-mu-plugins /wp/wp-content/images /wp/wp-content/languages /wp/wp-content/private /wp/wp-content/vip-config && \
    rm -rf /wp/.git && \
    apk del build-deps

COPY object-cache*.php /wp/wp-content/
COPY wp-config.php /wp/
COPY run.sh /

CMD ["sh", "/run.sh"]
