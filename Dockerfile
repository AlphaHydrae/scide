FROM bats/bats:v1.4.1

RUN apk add --no-cache make parallel

COPY ./ /code/

ENTRYPOINT [ "/usr/bin/make" ]
