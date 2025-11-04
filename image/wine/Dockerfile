FROM        debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"
LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386

RUN         apt-get update && apt-get install -y \
                apt-transport-https gnupg curl cabextract unzip winbind xvfb \
                wine32 jq inotify-tools locales \
                tar gcc g++ lib32gcc-s1 libgcc1 \
                libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 \
                lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 \
                libncurses5:i386 libcurl3-gnutls:i386 \
                libsdl2-2.0-0:i386 iproute2 gdb \
                libsdl1.2debian libfontconfig1 \
                telnet net-tools netcat-traditional tzdata \
                ca-certificates software-properties-common \
                p7zip-full \
            && apt-get clean

ENV         WINE_VERSION=8.0.1~bookworm-1
RUN         curl -O https://dl.winehq.org/wine-builds/winehq.key && \
                apt-key add winehq.key && \
                rm winehq.key && \
                echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list.d/winehq.list && \
                apt-get update && \
                apt-get install -y --install-recommends \
                wine-stable-i386=${WINE_VERSION} wine-stable:i386=${WINE_VERSION} winehq-stable:i386=${WINE_VERSION} && \
                apt-get clean

# Install winetricks
RUN         curl https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > /usr/local/bin/winetricks && \
                chmod +x /usr/local/bin/winetricks

# Setup locale
RUN         echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
                locale-gen en_US.UTF-8

ENV         LANG=en_US.UTF-8 \
                LANGUAGE=en_US:en \
                LC_ALL=en_US.UTF-8

# Create container user
RUN         useradd -m -d /home/container container

COPY        ./*.sh /
RUN         chmod +x /entrypoint.sh /watch.sh /start.sh

USER        container
ENV         USER=container \
                HOME=/home/container \
                WINEPREFIX=/home/container/.wine \
                WINEARCH=win32 \
                DISPLAY=:0 \
                WINEDLLOVERRIDES="mscoree,mshtml="

WORKDIR     /home/container

CMD         [ "/start.sh" ]