FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

ENV         DEBIAN_FRONTEND=noninteractive
# Tắt log Wine để sạch console
ENV         WINEPREFIX=/home/container/.wine
ENV         WINEARCH=win64
ENV         DISPLAY=:0

RUN         dpkg --add-architecture i386 \
                && apt update \
                && apt upgrade -y \
                && apt install -y tar curl gnupg2 gcc g++ lib32gcc-s1 libgcc1 libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat-traditional tzdata inotify-tools xvfb procps \
                && useradd -m -d /home/container container

# Cài đặt Wine Staging
RUN         mkdir -pm755 /etc/apt/keyrings \
                && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key -o /etc/apt/keyrings/winehq-archive.key \
                && curl -fsSL https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources -o /etc/apt/sources.list.d/winehq-bookworm.sources \
                && apt update \
                && apt install -y --no-install-recommends winehq-staging

# Tạo sẵn WINEPREFIX để tránh xung đột quyền khi khởi chạy lần đầu
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./*.sh /
RUN         chmod +x /entrypoint.sh /watch.sh /start.sh
USER        container

ENTRYPOINT  [ "/usr/bin/xvfb-run", "-a" ]
CMD         [ "/bin/bash", "/start.sh" ]