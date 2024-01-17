FROM crystallang/crystal:1.11.2-alpine as Builder

# install packages required to run the representer
RUN apk add --no-cache bash coreutils yaml-dev musl-dev make

# install packages required to run the representer
COPY shard.lock shard.yml ./
RUN shards install

COPY . .

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