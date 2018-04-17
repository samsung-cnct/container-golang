FROM golang:1.9.2
LABEL maintainer="Guinevere Saenger <guineveresaenger@gmail.com>"
WORKDIR /go/src

ARG DEP_VERSION=v0.4.1
ENV DEP_URL https://github.com/golang/dep/releases/download/$DEP_VERSION/dep-linux-amd64
ENV DEP_SHA256SUM "b6b9a83f187e75284e1dc071f336baf8d7ab1554b7ca5c5b0b9af3d9bc12993a  /usr/local/bin/dep"

ARG GOSU_VERSION=1.10
ENV GOSU_URL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64
ENV GOSU_PATH /usr/local/bin/gosu

# The golang container has curl and ca-certificates installed already, so we don't need apt-get for anything.

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
  gpg --keyserver pgp.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 || \
  gpg --keyserver keyserver.pgp.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN curl -sL "$DEP_URL" -o /usr/local/bin/dep \
	&& strip /usr/local/bin/dep \
    && chmod 755 /usr/local/bin/dep \
	&& echo $DEP_SHA256SUM | sha256sum -c

RUN curl -L "$GOSU_URL" -o "$GOSU_PATH" \
	&& curl -fsSL "$GOSU_URL.asc" -o "$GOSU_PATH.asc" \
	&& gpg --verify "$GOSU_PATH.asc" \
	&& rm "$GOSU_PATH.asc" \
	&& chmod +x "$GOSU_PATH"

RUN go get \
    golang.org/x/tools/cmd/godoc \
	gopkg.in/alecthomas/gometalinter.v2

RUN rm -rf /go/src/golang.org/x/tools/.git \
	&& rm -rf /go/src/gopkg.in/alecthomas/gometalinter.v2/.git


# entrypoint script to set the container user to host user

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
