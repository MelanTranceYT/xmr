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
# Qemu Start  
    && wget http://archive.ubuntu.com/ubuntu/pool/main/liba/libaio/libaio1_0.3.112-5_amd64.deb \
    && dpkg -i libaio1_0.3.112-5_amd64.deb \
    && apt-get install libaio1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/b/brltty/libbrlapi0.7_6.0+dfsg-4ubuntu6_amd64.deb \
    && dpkg -i libbrlapi0.7_6.0+dfsg-4ubuntu6_amd64.deb \
    && apt-get install libbrlapi0.7 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libc/libcacard/libcacard0_2.6.1-1_amd64.deb \
    && dpkg -i libcacard0_2.6.1-1_amd64.deb \
    && apt-get install libcacard0 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/d/device-tree-compiler/libfdt1_1.5.1-1_amd64.deb \
    && dpkg -i libfdt1_1.5.1-1_amd64.deb \
    && apt-get install libfdt1 \
# small packages    
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-3-200_3.4.0-1_amd64.deb \
    && dpkg -i libnl-3-200_3.4.0-1_amd64.deb \
    && apt-get install libnl-3-200 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libn/libnl3/libnl-route-3-200_3.4.0-1_amd64.deb \
    && dpkg -i libnl-route-3-200_3.4.0-1_amd64.deb \
    && apt-get install libnl-route-3-200 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/r/rdma-core/libibverbs1_28.0-1ubuntu1_amd64.deb \
    && dpkg -i libibverbs1_28.0-1ubuntu1_amd64.deb \
    && apt-get install libibverbs1 \
# small packages end
    && wget http://archive.ubuntu.com/ubuntu/pool/main/p/pmdk/libpmem1_1.8-1ubuntu1_amd64.deb \
    && dpkg -i libpmem1_1.8-1ubuntu1_amd64.deb \
    && apt-get install libpmem1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/r/rdma-core/librdmacm1_28.0-1ubuntu1_amd64.deb \
    && dpkg -i librdmacm1_28.0-1ubuntu1_amd64.deb \
    && apt-get install librdmacm1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libs/libslirp/libslirp0_4.1.0-2ubuntu2_amd64.deb \
    && dpkg -i libslirp0_4.1.0-2ubuntu2_amd64.deb \
    && apt-get install libslirp0 \
# small packages 2    
    && wget http://archive.ubuntu.com/ubuntu/pool/main/o/orc/liborc-0.4-0_0.4.31-1_amd64.deb \
    && dpkg -i liborc-0.4-0_0.4.31-1_amd64.deb \
    && apt-get install liborc-0.4-0 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/g/gst-plugins-base1.0/libgstreamer-plugins-base1.0-0_1.16.2-4_amd64.deb \
    && dpkg -i libgstreamer-plugins-base1.0-0_1.16.2-4_amd64.deb \
    && apt-get install libgstreamer-plugins-base1.0-0 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/s/spice/libspice-server1_0.14.2-4ubuntu2_amd64.deb \
    && dpkg -i libspice-server1_0.14.2-4ubuntu2_amd64.deb \
    && apt-get install libspice-server1 \
# small packages 2 end
    && wget http://archive.ubuntu.com/ubuntu/pool/main/u/usbredir/libusbredirparser1_0.8.0-1_amd64.deb \
    && dpkg -i libusbredirparser1_0.8.0-1_amd64.deb \
    && apt-get install libusbredirparser1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/v/virglrenderer/libvirglrenderer1_0.8.2-1ubuntu1_amd64.deb \
    && dpkg -i libvirglrenderer1_0.8.2-1ubuntu1_amd64.deb \
    && apt-get install libvirglrenderer1 \
# small packages 3   
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libi/libiscsi/libiscsi7_1.18.0-2_amd64.deb \
    && dpkg -i libiscsi7_1.18.0-2_amd64.deb \
    && apt-get install libiscsi7 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/c/ceph/librados2_15.2.1-0ubuntu1_amd64.deb \
    && dpkg -i librados2_15.2.1-0ubuntu1_amd64.deb \
    && apt-get install librados2 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/c/ceph/librbd1_15.2.1-0ubuntu1_amd64.deb \
    && dpkg -i librbd1_15.2.1-0ubuntu1_amd64.deb \
    && apt-get install librbd1 \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/q/qemu/qemu-block-extra_4.2-3ubuntu6_amd64.deb \
    && dpkg -i qemu-block-extra_4.2-3ubuntu6_amd64.deb \
    && apt-get install qemu-block-extra \
# tiny packages 1 end
    && wget http://archive.ubuntu.com/ubuntu/pool/main/a/acl/acl_2.2.53-6_amd64.deb \
    && dpkg -i acl_2.2.53-6_amd64.deb \
    && apt-get install acl \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/q/qemu/qemu-system-common_4.2-3ubuntu6_amd64.deb \
    && dpkg -i qemu-system-common_4.2-3ubuntu6_amd64.deb \
    && apt-get install qemu-system-common \
# small packages 3 end
    && wget http://archive.ubuntu.com/ubuntu/pool/main/q/qemu/qemu-system-data_4.2-3ubuntu6_all.deb \
    && dpkg -i qemu-system-data_4.2-3ubuntu6_all.deb \
    && apt-get install qemu-system-data \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/i/ipxe-qemu-256k-compat/ipxe-qemu-256k-compat-efi-roms_1.0.0+git-20150424.a25a16d-0ubuntu4_all.deb \
    && dpkg -i ipxe-qemu-256k-compat-efi-roms_1.0.0+git-20150424.a25a16d-0ubuntu4_all.deb \
    && apt-get install ipxe-qemu-256k-compat-efi-roms \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/s/seabios/seabios_1.13.0-1ubuntu1_all.deb \
    && dpkg -i seabios_1.13.0-1ubuntu1_all.deb \
    && apt-get install seabios \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/i/ipxe/ipxe-qemu_1.0.0+git-20190109.133f4c4-0ubuntu3_all.deb \
    && dpkg -i ipxe-qemu_1.0.0+git-20190109.133f4c4-0ubuntu3_all.deb \
    && apt-get install ipxe-qemu \
# qemu install
    && wget http://archive.ubuntu.com/ubuntu/pool/main/q/qemu/qemu-system-x86_4.2-3ubuntu6_amd64.deb \
    && dpkg -i qemu-system-x86_4.2-3ubuntu6_amd64.deb \
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
