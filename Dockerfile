# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git clang cmake make haskell-stack

## Add source code to the build stage.
WORKDIR /
ADD https://api.github.com/repos/capuanob/yaml/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/yaml.git
WORKDIR yaml/yaml

## Build
RUN stack install yaml --flag yaml:-no-exe

## Consolidate all dynamic libraries used by the fuzzer
RUN mkdir /deps
RUN cp `ldd /root/.local/bin/json2yaml | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :
RUN cp `ldd /root/.local/bin/yaml2json | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /root/.local/bin/json2yaml /json2yaml
COPY --from=builder /root/.local/bin/yaml2json /yaml2json
COPY --from=builder /deps /usr/lib
