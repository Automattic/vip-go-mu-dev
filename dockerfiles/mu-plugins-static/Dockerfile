FROM wpvipdev/alpine:3.12.0-1

ARG CHANGESET

RUN apk add --no-cache --virtual build-deps git && \
    git clone https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    git checkout $CHANGESET && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init && \
    rm -rf /mu-plugins/.git && \
    apk del build-deps

CMD ["sleep", "infinity"]
