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

# Build ALL
FROM build_env as pbs_env

ADD /scripts/clone.bash /scripts/
RUN /scripts/clone.bash /patches/versions

ADD /scripts/strip-cargo.bash /scripts/
RUN /scripts/strip-cargo.bash

ADD /scripts/apply-patches.bash /scripts/
RUN /scripts/apply-patches.bash /patches/pbs/
RUN /scripts/apply-patches.bash /patches/pbs-$(dpkg --print-architecture)/

ADD /scripts/resolve-dependencies.bash /scripts/
RUN /scripts/resolve-dependencies.bash

ARG VERSION=master
ADD /versions/${VERSION}/ /patches/
RUN /patches/build.bash

ADD /scripts/export-deb.bash /scripts/
RUN /scripts/export-deb.bash /deb

# Install ALL
FROM ${ARCH}debian:bullseye AS deb_env
COPY --from=pbs_env /deb /deb

ADD /scripts/install.bash /deb/
RUN /scripts/install.bash /deb

VOLUME /var/lib/proxmox-etc
VOLUME /var/lib/vz

ADD /scripts/init.bash /init
CMD ["/init"]
