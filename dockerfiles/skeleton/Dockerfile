FROM wpvipdev/alpine:3.12.0-1

ARG CHANGESET

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-skeleton/ /clientcode && \
    cd /clientcode && \
    git checkout $CHANGESET && \
    rm -rf /clientcode/.git && \
    apk del build-deps

CMD ["sleep", "infinity"]
