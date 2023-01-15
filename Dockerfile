ARG ARCH=
FROM ${ARCH}debian:bullseye AS build_env

RUN echo deb http://deb.debian.org/debian bullseye-backports main > /etc/apt/sources.list.d/backports.list

RUN apt-get -y update && \
  apt-get -y install \
    build-essential git-core \
    lintian pkg-config quilt patch cargo \
    nodejs node-colors node-commander \
    libudev-dev libapt-pkg-dev \
    libacl1-dev libpam0g-dev libfuse3-dev \
    libsystemd-dev uuid-dev libssl-dev \
    libclang-dev libjson-perl libcurl4-openssl-dev \
    dh-exec wget devscripts rsync patchelf xmlto jq sudo && \
  apt-get install -t bullseye-backports -y meson

RUN wget https://static.rust-lang.org/rustup/rustup-init.sh && \
  chmod +x rustup-init.sh && \
  ./rustup-init.sh -y --default-toolchain nightly

WORKDIR /src

RUN for tool in /root/.cargo/bin/*; do ln -vsf $tool /usr/bin/; done
RUN cargo install debcargo
RUN /usr/bin/rustc --version
RUN git config --global user.email "docker@compile.dev" && \
  git config --global user.name "Docker Compile"

# Prepare scripts
FROM build_env as pbs_env
ARG VERSION=master
ADD /versions/${VERSION}/ /patches/
ADD /scripts/ /scripts/

# Build all
FROM pbs_env as pbs_build

RUN /scripts/clone.bash /src /patches/versions
RUN /scripts/strip-cargo.bash
RUN /scripts/apply-patches.bash /patches/pbs/
RUN /scripts/resolve-dependencies.bash /src /patches/deps
RUN /patches/build.bash
