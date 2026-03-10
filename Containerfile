FROM registry.fedoraproject.org/fedora:43
RUN dnf install -y firefox liberation-fonts alsa-lib pipewire-alsa pulseaudio-libs mesa-dri-drivers && dnf clean all
# Ensure user 1000 exists (standard for first user)
RUN useradd -u 1000 -m -G video,audio firefox
USER 1000
ENV HOME=/home/firefox
CMD ["/usr/bin/firefox"]
