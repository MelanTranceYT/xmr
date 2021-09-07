FROM ubuntu:20.04 as ubuntu-base

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gnome-boxes/gnome-boxes_3.36.2-1_amd64.deb \
    && dpkg -i gnome-boxes_3.36.2-1_amd64.deb \
    && apt-get update \
    && apt-get install gnome-boxes
