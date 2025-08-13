FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386 \
				&& apt update \
				&& apt upgrade -y \
				&& apt install -y tar curl gcc g++ lib32gcc-s1 libgcc1 libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat-traditional tzdata \
				&& useradd -m -d /home/container container

RUN         mkdir -pm755 /etc/apt/keyrings
RUN         curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | tee /etc/apt/keyrings/winehq-archive.key
RUN         curl -fsSL https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources | tee /etc/apt/sources.list.d/winehq.list
RUN         apt update && apt install -y --no-install-recommends winehq-stable

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]