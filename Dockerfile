FROM alpine:3.4
RUN addgroup -S mosquitto && \
    adduser -S -H -h /var/empty -s /sbin/nologin -D -G mosquitto mosquitto

ENV PATH=/usr/local/bin:/usr/local/sbin:$PATH
ARG MOSQUITTO_VERSION=v1.4.12
ENV MOSQUITTO_VERSION $MOSQUITTO_VERSION

COPY run.sh /
RUN buildDeps='git alpine-sdk libwebsockets-dev c-ares-dev util-linux-dev curl-dev libxslt docbook-xsl'; \
    chmod +x /run.sh && \
    mkdir -p /var/lib/mosquitto && \
    touch /var/lib/mosquitto/.keep && \
    mkdir -p /etc/mosquitto.d && \
    apk update && \
    apk add $buildDeps libwebsockets libuuid c-ares curl && \
    git clone https://github.com/eclipse/mosquitto.git && \
    cd mosquitto && \
    git checkout ${MOSQUITTO_VERSION} -b ${MOSQUITTO_VERSION} && \
    sed -i -e "s|(INSTALL) -s|(INSTALL)|g" -e 's|--strip-program=${CROSS_COMPILE}${STRIP}||' */Makefile */*/Makefile && \
    sed -i "s@/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl@/usr/share/xml/docbook/xsl-stylesheets-1.79.1/manpages/docbook.xsl@" man/manpage.xsl && \
    # wo WITH_MEMORY_TRACKING=no, mosquitto segfault after receiving first message
    make WITH_MEMORY_TRACKING=no WITH_PERSISTENCE=no WITH_BRIDGE=no WITH_TLS=no WITH_SRV=yes WITH_WEBSOCKETS=yes && \
    make install && \
    cd / && rm -rf mosquitto && \
    apk del $buildDeps && rm -rf /var/cache/apk/*

ADD mosquitto.conf /etc/mosquitto/mosquitto.conf

EXPOSE 1883
EXPOSE 9001

ENTRYPOINT ["/run.sh"]
CMD ["mosquitto"]

