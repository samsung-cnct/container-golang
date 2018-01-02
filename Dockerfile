FROM golang:1.9.0
LABEL maintainer="Guinevere Saenger <guineveresaenger@gmail.com>"

ENV GODEP_VERSION v79
ENV GODEP_URL https://github.com/tools/godep/releases/download/$GODEP_VERSION/godep_linux_amd64
ENV GODEP_SHA256SUM "d67903869dfb994d9bc627cba7314628eb398679232b27ea2bba66b08cd59cfb  /usr/local/bin/godep"

ENV GOSU_VERSION 1.10
ENV GOSU_URL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64
ENV GOSU_PATH /usr/local/bin/gosu

#
# Luckily golang container has curl and ca-certificates installed already, so we don't need apt-get for anything.
# Just need to add in glide for golang dependency management.
#
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN curl -sL "$GODEP_URL" -o /usr/local/bin/godep \
	&& strip /usr/local/bin/godep \
    && echo $GODEP_SHA256SUM | sha256sum -c \
    && chmod 755 /usr/local/bin/godep

RUN curl -L "$GOSU_URL" -o "$GOSU_PATH" \
	&& curl -fsSL "$GOSU_URL.asc" -o "$GOSU_PATH.asc" \
	&& gpg --verify "$GOSU_PATH.asc" \
	&& rm "$GOSU_PATH.asc" \
	&& chmod +x "$GOSU_PATH"


# entrypoint script to set the container user to host user

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
