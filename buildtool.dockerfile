FROM alpine:edge as alpine
COPY . /opt/abl
COPY ./apk.repos /etc/apk/repositories
RUN apk add alpine-sdk bash bison chibi-scheme coreutils cpio diffutils elfutils-dev findutils flex git go linux-headers make ncurses-dev openssl-dev perl rsync zstd
ENTRYPOINT ["chibi-scheme", "/opt/abl/buildtool/build.scm"]
