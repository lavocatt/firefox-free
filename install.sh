# create a folder to contain the firefox profile
mkdir -p ~/.firefox-free-profile
mkdir -p ~/.cache/firefox-free/
chown -R $(id -u):$(id -g) ~/.firefox-free-profile
chcon -Rt svirt_sandbox_file_t ~/.firefox-free-profile

# Custom CA certificates go in certs/ (git-ignored); it may stay empty
mkdir -p certs

# Remember where the sources are, for automatic rebuilds
mkdir -p ~/.config/firefox-free
# (update only our line: the user may have other settings there)
touch ~/.config/firefox-free/config
sed -i '/^FIREFOX_FREE_SRC=/d' ~/.config/firefox-free/config
echo "FIREFOX_FREE_SRC=\"$(pwd)\"" >> ~/.config/firefox-free/config
# Domains opened in another browser instead; keep the user's edited copy
cp -n .config/firefox-free/bypass-domains ~/.config/firefox-free/

# Build the container
podman build --pull=newer -t firefox-free .
mkdir -p ~/.local/state/firefox-free
touch ~/.local/state/firefox-free/last-build

# Install the firefox free app and desktop shortcut
mkdir -p ~/.local/bin/
mkdir -p ~/.local/share/applications/
cp .local/bin/firefox-free .local/bin/firefox-free-update ~/.local/bin/
sed "s|^Exec=.*|Exec=$HOME/.local/bin/firefox-free %u|" \
    .local/share/applications/firefox-free.desktop \
    > ~/.local/share/applications/firefox-free.desktop

# Rebuild the image daily with the latest Firefox
mkdir -p ~/.config/systemd/user/
cp .config/systemd/user/firefox-free-update.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now firefox-free-update.timer

# Make everyone able to find the firefox-free executable
# for bash
for rc in ~/.bashrc ~/.profile; do
    grep -qsF '$HOME/.local/bin' "$rc" \
        || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
done
# for gnome
mkdir -p ~/.config/environment.d
echo 'PATH=$HOME/.local/bin:${PATH}' > ~/.config/environment.d/90-local-bin.conf

# Set it as the default for HTTP and HTTPS protocols
xdg-mime default firefox-free.desktop x-scheme-handler/http
xdg-mime default firefox-free.desktop x-scheme-handler/https
xdg-mime default firefox-free.desktop text/html
# Tell the general XDG settings that this is the default web browser
xdg-settings set default-web-browser firefox-free.desktop

# Optional: Override the system firefox with an alias
# echo 'alias firefox="~/.local/bin/firefox-free"' >> ~/.bashrc
# ln -s ~/.local/bin/firefox-free ~/.local/bin/firefox

# Refresh the applications
update-desktop-database ~/.local/share/applications
