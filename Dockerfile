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

# Compile everything
FROM build_env AS deb_env

ARG VERSION=master
ADD . /src

VOLUME /src/tmp
RUN BUILD=1 /src/build.bash "$VERSION"

# Install dependencies
FROM ${ARCH}debian:bullseye AS release_env

COPY --from=build_env /deb/${VERSION}/*.deb /deb
ADD /scripts/install.bash /deb
RUN mkdir -p /run/network && \
  /deb/install.bash /deb

VOLUME /var/lib/proxmox-etc
VOLUME /var/lib/vz

ADD /scripts/init.bash /init
CMD ["/init"]
