FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         dpkg --add-architecture i386 \
				&& apt update \
				&& apt upgrade -y \
				&& apt install -y --no-install-recommends curl gnupg ca-certificates tzdata iproute2 util-linux tar lib32gcc-s1 lib32stdc++6 libcurl4:i386 libssl3:i386 \
				&& curl -fsSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb \
				&& dpkg -i /tmp/packages-microsoft-prod.deb \
				&& rm -f /tmp/packages-microsoft-prod.deb \
				&& apt update \
				&& apt install -y --no-install-recommends dotnet-runtime-8.0 \
				&& mkdir -p /opt/steamcmd /home/container/steamapps \
				&& curl -fsSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -o /tmp/steamcmd_linux.tar.gz \
				&& tar -xzf /tmp/steamcmd_linux.tar.gz -C /opt/steamcmd \
				&& chmod -R a+rX /opt/steamcmd \
				&& ln -sf /opt/steamcmd/steamcmd.sh /usr/local/bin/steamcmd \
				&& rm -f /tmp/steamcmd_linux.tar.gz \
				&& apt clean \
				&& rm -rf /var/lib/apt/lists/* \
				&& useradd -m -d /home/container container \
				&& chown -R container:container /home/container

COPY        ./*.sh /
RUN			chmod +x /entrypoint.sh

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

CMD         [ "/entrypoint.sh" ]