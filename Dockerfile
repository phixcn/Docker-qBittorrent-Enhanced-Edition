FROM lsiobase/alpine:3.10 as compilingqB

# compiling qB
# set version label
ARG  LIBTORRENT_VER=1.1.14
ARG  QBITTORRENT_VER=4.1.9.15
LABEL build_version="SuperNG6.qbittorrentEE:- ${QBITTORRENT_VER}"
LABEL maintainer="SuperNG6"


RUN  apk add --no-cache ca-certificates make g++ gcc qt5-qtsvg-dev boost-dev qt5-qttools-dev file \
&&   mkdir /qbtorrent  \
&&   wget -P /qbtorrent https://github.com/arvidn/libtorrent/releases/download/libtorrent-`echo "$LIBTORRENT_VER"|sed 's#\.#_#g'`/libtorrent-rasterbar-${LIBTORRENT_VER}.tar.gz   \
&&   tar  -zxvf  /qbtorrent/libtorrent-rasterbar-${LIBTORRENT_VER}.tar.gz   -C    /qbtorrent  \
&&   cd  /qbtorrent/libtorrent-rasterbar-${LIBTORRENT_VER} \
&&   ./configure  --host=x86_64-alpine-linux-musl \
&&   make -j$(nproc) install-strip \
# qBittorrent-Enhanced-Edition
&&   wget  -P /qbtorrent https://github.com/c0re100/qBittorrent-Enhanced-Edition/archive/release-${QBITTORRENT_VER}.zip   \
&&   unzip   /qbtorrent/release-${QBITTORRENT_VER}.zip  -d    /qbtorrent \
&&   cd  /qbtorrent/qBittorrent-Enhanced-Edition-release-${QBITTORRENT_VER} \
# make install
&&   ./configure   --disable-gui --host=x86_64-alpine-linux-musl \
&&   make -j$(nproc) install \
&&   ldd /usr/local/bin/qbittorrent-nox   |cut -d ">" -f 2|grep lib|cut -d "(" -f 1|xargs tar -chvf /qbtorrent/qbittorrent.tar  \
&&   mkdir /qbittorrent   \
&&   tar  -xvf /qbtorrent/qbittorrent.tar   -C  /qbittorrent   \
&&   cp --parents /usr/local/bin/qbittorrent-nox  /qbittorrent
 

# docker qBittorrent-Enhanced-Edition

FROM lsiobase/alpine:3.10

# environment settings
ENV TZ=Asia/Shanghai
ENV WEBUIPORT=8080

# add local files and install qbitorrent
COPY root /
COPY --from=compilingqB  /qbittorrent  /

# install ca-certificates tzdata python3
RUN  apk add --no-cache ca-certificates tzdata python3 \
&&   rm -rf /var/cache/apk/*   \
&&   chmod a+x  /usr/local/bin/qbittorrent-nox  

# ports and volumes
VOLUME /downloads /config
EXPOSE 8080  6881  6881/udp
