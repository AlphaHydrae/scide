FROM bats/bats:v1.4.1

WORKDIR /usr/src/app

RUN apk add --no-cache make

COPY ./ /usr/src/app/

CMD [ "/usr/bin/make" ]
