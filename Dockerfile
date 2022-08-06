# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y clang cmake make haskell-stack build-essential

## Add source code to the build stage.
WORKDIR /
ADD . /yaml
WORKDIR yaml/yaml

## Build
RUN stack install yaml --flag yaml:-no-exe

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /root/.local/bin/json2yaml /json2yaml
COPY --from=builder /root/.local/bin/yaml2json /yaml2json
