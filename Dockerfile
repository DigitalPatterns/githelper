FROM alpine:3.7

RUN apk --no-cache -U upgrade \
    && \
    apk add --no-cache -U bash mariadb-client mongodb mongodb-tools git python py-pip openssh-client postgresql-client

ADD scripts/* /bin/

RUN addgroup -S user1 \
    && \
    adduser -D -G user1 -u 1000 -s /bin/bash -h /home/user1 user1 \
    && \
    mkdir -p /repo /home/user1/.ssh \
    && \
    chown -R user1:user1 /home/user1 /repo \
    && \
    chmod 700 /home/user1/.ssh \
    && \
    pip install --upgrade pip \
    && \
    pip install git-url-parse \
    && \
    chmod +x /bin/*.py /bin/*.sh

WORKDIR /repo

USER user1

ENTRYPOINT /bin/bash