FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386 \
                && apt update \
                && apt upgrade -y \
                && apt install -y \
                    tar curl gnupg2 wget unzip jq \
                    gcc g++ lib32gcc-s1 libgcc1 \
                    libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 \
                    lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 \
                    libncurses5:i386 libcurl3-gnutls:i386 \
                    libsdl2-2.0-0:i386 iproute2 gdb \
                    libsdl1.2debian libfontconfig1 \
                    telnet net-tools netcat-traditional tzdata \
                    inotify-tools locales \
                    ca-certificates software-properties-common \
                    cabextract p7zip-full \
                && useradd -m -d /home/container container

RUN         curl -fsSL https://dl.winehq.org/wine-builds/winehq.key -o /tmp/winehq.key \
                && apt-key add /tmp/winehq.key \
                && echo "deb https://dl.winehq.org/wine-builds/debian/ bookworm main" > /etc/apt/sources.list.d/wine.list \
                && apt update \
                && apt install -y --no-install-recommends winehq-stable \
                && rm -f /tmp/winehq.key

# Install winetricks
RUN         wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
                && chmod +x winetricks \
                && mv winetricks /usr/local/bin/

# Setup locale
RUN         echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
                && locale-gen en_US.UTF-8 \
                && apt-get clean \
                && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV         LANG=en_US.UTF-8 \
                LANGUAGE=en_US:en \
                LC_ALL=en_US.UTF-8

COPY        ./*.sh /
RUN         chmod +x /entrypoint.sh /watch.sh /start.sh



USER        container
ENV         USER=container \
            HOME=/home/container \
            WINEPREFIX=/home/container/.wine \
            WINEARCH=win64 \
            DISPLAY=:0
WORKDIR     /home/container

CMD         [ "/start.sh" ]