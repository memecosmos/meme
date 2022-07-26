# docker build . -t MeMeCosmos/meme:latest
# docker run --rm -it MeMeCosmos/meme:latest /bin/sh
FROM golang:1.18-alpine AS build

ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3 jq build-base chrony ca-certificates musl-dev openssl
ENV VERSION main
# Set up dependencies
RUN set -eux; apk add --update --no-cache $PACKAGES;

# Set working directory for the build
WORKDIR /go/src/github.com/MEMECosmos/

# Add source files
RUN git clone --recursive https://github.com/MEMECosmos/meme
WORKDIR /go/src/github.com/MEMECosmos/meme

RUN git checkout $VERSION

# See https://github.com/CosmWasm/wasmvm/releases
ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.0.0/libwasmvm_muslc.aarch64.a /lib/libwasmvm_muslc.aarch64.a
ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.0.0/libwasmvm_muslc.x86_64.a /lib/libwasmvm_muslc.x86_64.a
RUN sha256sum /lib/libwasmvm_muslc.aarch64.a | grep 7d2239e9f25e96d0d4daba982ce92367aacf0cbd95d2facb8442268f2b1cc1fc
RUN sha256sum /lib/libwasmvm_muslc.x86_64.a | grep f6282df732a13dec836cda1f399dd874b1e3163504dbd9607c6af915b2740479

# Copy the library you want to the final location that will be found by the linker flag `-lwasmvm_muslc`
RUN cp /lib/libwasmvm_muslc.$(uname -m).a /lib/libwasmvm_muslc.a

# force it to use static lib (from above) not standard libgo_cosmwasm.so file
RUN LEDGER_ENABLED=false BUILD_TAGS=muslc LEDGER_ENABLED=true make build



# --------------------------------------------------------
FROM alpine:edge

ENV MEME_HOME /root/.memed

# Install ca-certificates
RUN apk add --no-cache --update ca-certificates py3-setuptools supervisor wget lz4 gzip jq curl

# Temp directory for copying binaries
RUN mkdir -p /tmp/bin
WORKDIR /tmp/bin

COPY --from=build /go/src/github.com/MEMECosmos/meme/build /tmp/bin
RUN install -m 0755 -o root -g root -t /usr/local/bin memed


# Remove temp files
RUN rm -r /tmp/bin

WORKDIR $MEME_HOME

# Expose ports
# rest server
EXPOSE 1317 9090
# tendermint p2p
EXPOSE 26656
# tendermint rpc
EXPOSE 26657

CMD ["memed", "version"]


