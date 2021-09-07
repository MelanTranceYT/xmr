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
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

COPY scripts/* /opt/bin/

# Add Supervisor configuration file
COPY supervisord.conf /etc/supervisor/

# Relaxing permissions for other non-sudo environments
RUN  mkdir -p /var/run/supervisor /var/log/supervisor \
    && chmod -R 777 /opt/bin/ /var/run/supervisor /var/log/supervisor /etc/passwd \
    && chgrp -R 0 /opt/bin/ /var/run/supervisor /var/log/supervisor \
    && chmod -R g=u /opt/bin/ /var/run/supervisor /var/log/supervisor

# Creating base directory for Xvfb
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

CMD ["/opt/bin/entry_point.sh"]

#============================
# Utilities
#============================
FROM ubuntu-base as ubuntu-utilities

RUN apt-get -qqy update \
    && apt-get -qqy --no-install-recommends install \
        firefox htop terminator gnupg2 software-properties-common \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt install -qqy --no-install-recommends ./google-chrome-stable_current_amd64.deb \
    && apt-add-repository ppa:remmina-ppa-team/remmina-next \
    && apt update \
    && apt install -qqy --no-install-recommends remmina remmina-plugin-rdp remmina-plugin-secret \
    && apt-add-repository ppa:obsproject/obs-studio \
    && apt update \
    && apt install -qqy --no-install-recommends obs-studio \
    && apt install unzip \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    
#============================
# GUI
#============================
FROM ubuntu-utilities as ubuntu-ui

ENV SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=24 \
    SCREEN_DPI=96 \
    DISPLAY=:99 \
    DISPLAY_NUM=99 \
    UI_COMMAND=/usr/bin/startxfce4

# RUN apt-get update -qqy \
#     && apt-get -qqy install \
#         xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable kde-plasma-desktop

RUN apt-get update -qqy \
    && apt-get -qqy install --no-install-recommends \
        dbus-x11 xfce4 \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && apt-add-repository ppa:openjdk-r/ppa \
    && apt-get update \
    && apt-get install openjdk-8-jdk -y \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/f/file/libmagic-mgc_5.38-4_amd64.deb \
    && dpkg -i libmagic-mgc_5.38-4_amd64.deb \
    && apt-get update \
    && apt-get install libmagic-mgc \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/f/file/libmagic1_5.38-4_amd64.deb \
    && dpkg -i libmagic1_5.38-4_amd64.deb \
    && apt-get update \
    && apt-get install libmagic1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/c/cdrkit/genisoimage_1.1.11-3.1ubuntu1_amd64.deb \
    && dpkg -i genisoimage_1.1.11-3.1ubuntu1_amd64.deb \
    && apt-get update \
    && apt-get install genisoimage \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libx/libxslt/libxslt1.1_1.1.34-4_amd64.deb \
    && dpkg -i libxslt1.1_1.1.34-4_amd64.deb \
    && apt-get update \
    && apt-get install libxslt1.1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/p/pciutils/libpci3_3.6.4-1_amd64.deb \
    && depkg -i libpci3_3.6.4-1_amd64.deb \
    && apt-get update \
    && apt-get install libpci3 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/p/pciutils/pciutils_3.6.4-1_amd64.deb \
    && dpkg -i pciutils_3.6.4-1_amd64.deb \
    && apt-get update \
    && apt-get install pciutils \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/u/usbutils/usbutils_012-2_amd64.deb \
    && dpkg -i usbutils_012-2_amd64.deb \
    && apt-get update \
    && apt-get install usbutils \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/o/osinfo-db/osinfo-db_0.20200325-1_all.deb \
    && dpkg -i osinfo-db_0.20200325-1_all.deb \
    && apt-get update \
    && apt-get install osinfo-db \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/libo/libosinfo/libosinfo-1.0-0_1.7.1-1_amd64.deb \
    && dpkg -i libosinfo-1.0-0_1.7.1-1_amd64.deb \
    && apt-get update \
    && apt-get install libosinfo-1.0-0 \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/libo/libosinfo/libosinfo-bin_1.7.1-1_amd64.deb \
    && dpkg -i libosinfo-bin_1.7.1-1_amd64.deb \
    && apt-get update \
    && apt-get install libosinfo-bin \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libv/libvirt/libvirt-daemon_6.0.0-0ubuntu8_amd64.deb \
    && dpkg -i libvirt-daemon_6.0.0-0ubuntu8_amd64.deb \
    && apt-get update \
    && apt-get install libvirt-daemon \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/t/tracker/tracker_2.3.4-1_amd64.deb \
    && dpkg -i tracker_2.3.4-1_amd64.deb \
    && apt-get update \
    && apt-get install tracker \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gnome-boxes/gnome-boxes_3.36.2-1_amd64.deb \
    && dpkg -i gnome-boxes_3.36.2-1_amd64.deb \
    && apt-get install gnome-boxes
