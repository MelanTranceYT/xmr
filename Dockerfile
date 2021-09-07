FROM ubuntu:20.04 as ubuntu-base

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        sudo \
        supervisor \
        xvfb x11vnc novnc websockify \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gnome-boxes/gnome-boxes_3.36.2-1_amd64.deb \
    && dpkg -i gnome-boxes_3.36.2-1_amd64.deb \
    && apt-get update \
    && apt-get install gnome-boxes
