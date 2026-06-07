FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Pixalab" maintainer="admin@pixalab.co"

LABEL       org.opencontainers.image.source="https://github.com/PixalabCo/eggs"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt update \
				&& apt upgrade -y \
				&& apt install -y --no-install-recommends curl gnupg ca-certificates tzdata iproute2 util-linux \
				&& curl -fsSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/packages-microsoft-prod.deb \
				&& dpkg -i /tmp/packages-microsoft-prod.deb \
				&& rm -f /tmp/packages-microsoft-prod.deb \
				&& apt update \
				&& apt install -y --no-install-recommends dotnet-runtime-8.0 \
				&& apt clean \
				&& rm -rf /var/lib/apt/lists/* \
				&& useradd -m -d /home/container container

COPY        ./*.sh /
RUN			chmod +x /entrypoint.sh

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

CMD         [ "/entrypoint.sh" ]