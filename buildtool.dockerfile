FROM alpine:edge as alpine
COPY . /opt/abl
COPY ./apk.repos /etc/apk/repositories
RUN apk add alpine-sdk bash bison chibi-scheme coreutils cpio elfutils-dev findutils diffutils flex git linux-headers make ncurses-dev openssl-dev perl rsync zstd
ENTRYPOINT ["chibi-scheme", "/opt/abl/buildtool/build.scm"]
