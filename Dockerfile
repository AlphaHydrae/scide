FROM bats/bats:v1.4.1

RUN apk add --no-cache make parallel python3 && \
    adduser -D -s /bin/bash scide

USER scide:scide

COPY ./ /code/

ENTRYPOINT [ "/usr/bin/make" ]
