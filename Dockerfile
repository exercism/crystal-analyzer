FROM crystallang/crystal:1.22.1-alpine AS builder

# install packages required to run the representer
RUN apk add --no-cache bash coreutils yaml-dev musl-dev make

# install packages required to run the representer
COPY shard.lock shard.yml ./
RUN shards install

COPY . .

RUN ./bin/build.sh

WORKDIR /lib/ameba

RUN make clean && make

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --update --no-cache --force-overwrite pcre2-dev bash jq coreutils libgcc yaml libevent gc
WORKDIR /opt/analyzer

COPY . .
COPY --from=builder /lib/ameba/bin/ameba bin/ameba
COPY --from=builder /bin/analyzer bin/analyzer

ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
