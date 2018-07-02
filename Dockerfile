FROM alpine:3.7

ENV KUBE_LATEST_VERSION="v1.10.0"

RUN apk --no-cache -U upgrade \
    && \
    apk add --no-cache -U bash mariadb-client mongodb mongodb-tools git python py-pip openssh-client postgresql-client ca-certificates gettext curl \
    && \
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /bin/kubectl \
    && \
    chmod +x /bin/kubectl \
    && \
    rm /var/cache/apk/*

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

WORKDIR /

USER user1

ENTRYPOINT /bin/bash