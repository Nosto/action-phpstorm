# Self-contained image: the former base image supercid/jbstorm is no longer
# available on Docker Hub, so it is rebuilt here from public sources.
# Same JDK base and PhpStorm version as the original image.
FROM openjdk:21-ea-23-jdk-slim-bullseye

ARG IDEA_VERSION=PhpStorm-2023.1.2
ARG IDEA_SHA256=889f531bbe5c6dda9fb4805dbbccd25d3aa4262a97f4ad14cf184db3eaf2d980

# Debian 11 (bullseye) is end-of-life: its packages are only available from the archive mirror.
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    apt-get update -y -o Acquire::Check-Valid-Until=false && \
    apt-get install -y --no-install-recommends curl wget maven groovy xsltproc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/ide.tar.gz https://download.jetbrains.com/webide/${IDEA_VERSION}.tar.gz && \
    echo "${IDEA_SHA256}  /tmp/ide.tar.gz" | sha256sum -c - && \
    mkdir /opt/ide && \
    tar -x -C /opt/ide --strip-components=1 -z -f /tmp/ide.tar.gz && \
    rm /tmp/ide.tar.gz

ENV IDEA_HOME=/opt/ide

RUN groupadd -r jetbrains && \
    useradd --no-log-init --gid jetbrains --home-dir /home/jetbrains --create-home jetbrains

WORKDIR /home/jetbrains
USER jetbrains:jetbrains
COPY --chown=jetbrains:jetbrains jdk.table.xml /etc/idea/config/options/
COPY --chown=jetbrains:jetbrains jdk.table.xml /home/jetbrains/.IdeaIC2018.1/config/options/jdk.table.xml
USER root

RUN echo idea.config.path=/etc/idea/config >> /opt/ide/bin/idea.properties && \
    rm -rf /opt/ide/plugins/phing && \
    chmod -R 777 /etc/idea

COPY *.xslt /
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
