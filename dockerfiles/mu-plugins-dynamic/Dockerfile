FROM wpvipdev/alpine:3.12.0-1

RUN apk add --no-cache git rsync && \
    git clone --depth 1 https://github.com/Automattic/vip-go-mu-plugins /mu-plugins && \
    cd /mu-plugins && \
    sed -i -e "s,git@github.com:,https://github.com/," .gitmodules && \
    git submodule update --init

COPY run.sh /run.sh
COPY autoupdate.sh /autoupdate.sh

CMD ["sh", "/run.sh"]
