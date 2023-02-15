
FROM rust:1.67-buster AS build-env

ARG TAG
ENV TAG $TAG

WORKDIR /root
RUN git clone  --depth 1 https://github.com/informalsystems/hermes \
 && cd hermes \
 && git fetch --tags \
 && git checkout tags/v${TAG} \
 && cargo build --release

FROM debian:buster-slim

RUN useradd -m hermes -s /bin/bash
WORKDIR /home/hermes
USER hermes:hermes
COPY --chown=0:0 --from=build-env /root/hermes/target/release/hermes /usr/bin/hermes
COPY ./entrypoint.sh /hermes/entrypoint.sh

ENTRYPOINT ["/hermes/entrypoint.sh"]
