FROM registry.fedoraproject.org/fedora:44
RUN dnf install -y firefox liberation-fonts alsa-lib pipewire-alsa pulseaudio-libs mesa-dri-drivers ca-certificates && dnf clean all
# Proprietary-codec libavcodec (H.264, HEVC, AAC) from RPM Fusion. Fedora's
# firefox ships without libavcodec, so MP4/H.264/AAC media fails to play.
RUN dnf install -y \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    && dnf install -y libavcodec-freeworld mesa-va-drivers-freeworld \
    && dnf clean all
# firefox-free-update passes the date here so this layer is never served from
# the build cache: every rebuild pulls the latest Firefox and security fixes.
ARG REFRESH=0
RUN echo "refresh: $REFRESH" && dnf upgrade -y --refresh && dnf clean all
COPY firefox-free-prefs.js /usr/lib64/firefox/browser/defaults/preferences/
# Firefox hands external schemes to GIO, which only forwards them to the host
# portal when it believes it is sandboxed. Force it, or slack:// etc. are dropped.
ENV GIO_USE_PORTALS=1
COPY certs/ /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust
# Ensure user 1000 exists (standard for first user)
RUN useradd -u 1000 -m -G video,audio firefox
USER 1000
ENV HOME=/home/firefox
CMD ["/usr/bin/firefox"]
