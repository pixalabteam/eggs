FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"
LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive
# Tắt debug wine và ép chạy ở chế độ headless
ENV         WINEDEBUG=-all
ENV         WINEPREFIX=/home/container/.wine
ENV         DISPLAY=:0

RUN         dpkg --add-architecture i386 \
                && apt update \
                && apt upgrade -y \
                && apt install -y tar curl gnupg2 gcc g++ lib32gcc-s1 libgcc1 libcurl4-gnutls-dev:i386 libssl3:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat-traditional tzdata inotify-tools xvfb \
                && useradd -m -d /home/container container

# Cài đặt Wine Staging (Tốt hơn cho các ứng dụng Server mới năm 2026)
RUN         mkdir -pm755 /etc/apt/keyrings \
                && curl -fsSL https://dl.winehq.org/wine-builds/winehq.key -o /etc/apt/keyrings/winehq-archive.key \
                && curl -fsSL https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources -o /etc/apt/sources.list.d/winehq-bookworm.sources \
                && apt update \
                && apt install -y --no-install-recommends winehq-staging

COPY        ./*.sh /
RUN         chmod +x /entrypoint.sh /watch.sh /start.sh

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Sử dụng xvfb-run để giả lập màn hình, giúp fix lỗi X11
ENTRYPOINT  [ "/usr/bin/xvfb-run", "-a" ]
CMD         [ "/bin/bash", "/start.sh" ]