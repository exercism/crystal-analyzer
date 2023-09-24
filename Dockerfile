FROM crystallang/crystal:1.9.2-alpine as Builder

# install packages required to run the representer
COPY . .

RUN apk add --no-cache bash coreutils

RUN ./bin/build.sh

FROM alpine:3.17

RUN apk add --update --no-cache --force-overwrite pcre-dev pcre2-dev bash jq coreutils  
WORKDIR /opt/analyzer

COPY . .
COPY --from=Builder /bin/analyzer bin/analyzer

ENTRYPOINT ["/opt/analyzer/bin/run.sh"]