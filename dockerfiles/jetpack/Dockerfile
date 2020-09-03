FROM wpvipdev/alpine:3.12.0-1

ARG JP_VERSION

RUN apk add --no-cache --virtual build-deps git && \
    apk add --no-cache rsync && \
    git clone --branch $JP_VERSION --depth 1 https://github.com/Automattic/jetpack /jetpack && \
    rm -rf /jp/.git && \
    apk del build-deps

COPY run.sh /

CMD ["sh", "/run.sh"]
