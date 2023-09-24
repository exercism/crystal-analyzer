FROM crystallang/crystal:1.9.2-alpine as Builder

# install packages required to run the representer
COPY . .

RUN shards install

RUN apk add --no-cache bash coreutils shards yaml-dev musl-dev make

RUN ./bin/build.sh

WORKDIR /lib/ameba

RUN make clean && make

FROM alpine:3.17

RUN apk add --update --no-cache --force-overwrite pcre-dev pcre2-dev bash jq coreutils libgcc yaml libevent gc
WORKDIR /opt/analyzer

COPY . .
COPY --from=Builder /lib/ameba/bin/ameba bin/ameba
COPY --from=Builder /bin/analyzer bin/analyzer

ENTRYPOINT ["/opt/analyzer/bin/run.sh"]