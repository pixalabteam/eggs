FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386 \
				&& apt update \
				&& apt upgrade -y \
				&& apt install -y tar curl gnupg2 gcc g++ lib32gcc-s1 libgcc1 libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat-traditional tzdata inotify-tools \
				&& useradd -m -d /home/container container

RUN         curl -fsSL https://dl.winehq.org/wine-builds/winehq.key -o /tmp/winehq.key \
				&& apt-key add /tmp/winehq.key \
				&& echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list.d/wine.list \
				&& apt update \
				&& apt install -y --no-install-recommends winehq-stable

COPY        ./*.sh /
RUN			chmod +x /entrypoint.sh

USER        container
ENV         USER=container HOME=/home/container
ENV         WINEPREFIX=/opt/wineprefix
ENV         WINEDEBUG=-all
ENV         WINEDLLOVERRIDES=mscoree,mshtml=
WORKDIR     /home/container

# Pre-initialize Wine prefix at build time to avoid slow first-run init
RUN         DISPLAY= wineboot --init && wineserver --wait

CMD         [ "/entrypoint.sh" ]