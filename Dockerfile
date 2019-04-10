FROM alpine:3.7

ENV KUBE_LATEST_VERSION="v1.10.0"
ENV HUGO_VERSION="0.50"

ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl /tmp
ADD scripts/* /bin/

RUN addgroup -S user1 \
    && adduser -D -G user1 -u 1000 -s /bin/bash -h /home/user1 user1 \
    && mkdir -p /repo /home/user1/.ssh /data \
    && chown -R user1:user1 /home/user1 /repo /data \
    && chmod 700 /home/user1/.ssh 


RUN apk --no-cache -U upgrade \
    && apk add --no-cache -U bash mongodb mongodb-tools git python py-pip openssh-client postgresql-client ca-certificates gettext curl \
    && tar -xvf /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C /tmp/ \
    && mv -v /tmp/hugo /usr/bin/hugo \
    && mv /tmp/kubectl /bin/kubectl \
    && rm -vf /tmp/* \
    && mkdir -vp /var/www \
    && chown -R user1:user1 /var/www \
    && pip install --upgrade pip \
    && pip install git-url-parse Pygments \
    && chmod +x /bin/*.py /bin/*.sh /usr/bin/hugo /bin/kubectl \
    && rm -rf /var/cache/apk/*

WORKDIR /

USER 1000

ENTRYPOINT /bin/bash
