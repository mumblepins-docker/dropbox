FROM lsiobase/ubuntu:bionic
# set version label
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="mumblepins"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
    echo "**** install packages ****" && \
        apt-get update && \
        apt-get install -y --no-install-recommends \
            git \
            build-essential \
            python2.7 && \
    echo "**** install dropbox FS fix ****" && \
        cd /tmp && \
        git clone https://github.com/dark/dropbox-filesystem-fix && \
        cd dropbox-filesystem-fix && \
        make && \
        cp libdropbox_fs_fix.so /usr/local/lib/ && \
    echo "**** make directories ****" && \
        mkdir -p /dropbox /data /config && \
        ln -s /config /dropbox/.dropbox && \
        ln -s /data /dropbox/Dropbox && \
    echo "**** install dropbox ****" && \
        (cd /dropbox && \
            (uname -a | grep -q '64') && \
            curl -sSL "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf - || \
            curl -sSL "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf - ) && \
        curl -sSL "https://www.dropbox.com/download?dl=packages/dropbox.py" > /usr/local/bin/dropbox && \
        chmod +x /usr/local/bin/dropbox && \
        ln -s /usr/bin/python2.7 /usr/local/bin/python2 && \
        ln -s /usr/bin/python2.7 /usr/local/bin/python && \
    echo "**** cleanup ****" && \
            apt-get autoremove --purge -y \
                git \
                build-essential  && \
            apt-get clean && \
            rm -rf \
                /tmp/* \
                /var/lib/apt/lists/* \
                /var/tmp/*

# add local files
COPY root/ /

VOLUME /config /data
