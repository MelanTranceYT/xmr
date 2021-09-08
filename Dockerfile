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
# qemu install
    && wget http://archive.ubuntu.com/ubuntu/pool/main/q/qemu/qemu-system-x86_4.2-3ubuntu6_amd64.deb \
    && dpkg -i qemu-system-x86_4.2-3ubuntu6_amd64.deb && apt-get install -f \
    && apt-get install qemu-system-x86 \
# qemu end
    && wget http://ftp.br.debian.org/debian/pool/main/q/qemu/qemu-kvm_2.8+dfsg-6+deb9u9_amd64.deb \
    && dpkg -i qemu-kvm_2.8+dfsg-6+deb9u9_amd64.deb \
    && wget http://ftp.br.debian.org/debian/pool/main/libv/libvirt/libvirt-daemon-system_3.0.0-4+deb9u4_amd64.deb \
    && dpkg -i libvirt-daemon-system_3.0.0-4+deb9u4_amd64.deb \
    && wget http://ftp.br.debian.org/debian/pool/main/libv/libvirt/libvirt-clients_3.0.0-4+deb9u4_amd64.deb \
    && dpkg -i libvirt-clients_3.0.0-4+deb9u4_amd64.deb \
    && wget http://ftp.br.debian.org/debian/pool/main/b/bridge-utils/bridge-utils_1.5-13+deb9u1_amd64.deb \
    && dpkg -i bridge-utils_1.5-13+deb9u1_amd64.deb \
    && wget http://ftp.br.debian.org/debian/pool/main/s/screen/screen_4.5.0-6_amd64.deb \
    && dpkg -i screen_4.5.0-6_amd64.deb \
    && apt-get update \
    && apt-get install screen \
    && apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y \
    && apt-get install virt-manager \
