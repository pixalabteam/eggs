FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt update \
				&& apt upgrade -y \
				&& apt install -y tar curl gnupg2 libgcc1 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat-traditional tzdata \
				&& useradd -m -d /home/container container

RUN         curl -fsSL https://dl.winehq.org/wine-builds/winehq.key -o /tmp/winehq.key \
				&& apt-key add /tmp/winehq.key \
				&& echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list.d/wine.list \
				&& apt update \
				&& apt install -y --no-install-recommends winehq-stable

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]