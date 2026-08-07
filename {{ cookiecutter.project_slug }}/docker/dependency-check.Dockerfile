FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    git \
    libasound2-dev \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libudev-dev \
    libwayland-dev \
    libxkbcommon-dev \
    lld \
    ninja-build \
    pkg-config \
    wayland-protocols \
    xorg-dev \
  && rm -rf /var/lib/apt/lists/*

ENV CC=clang
ENV CXX=clang++

WORKDIR /tmp

