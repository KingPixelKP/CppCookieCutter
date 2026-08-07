FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

COPY scripts/install-deps.sh /tmp/install-deps.sh

RUN bash /tmp/install-deps.sh --ci \
  && rm -f /tmp/install-deps.sh

ENV CC=clang
ENV CXX=clang++

WORKDIR /tmp
