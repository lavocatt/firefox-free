# create a folder to contain the firefox profile
mkdir -p ~/.firefox-free-profile
mkdir -p ~/.cache/firefox-free/
chown -R $(id -u):$(id -g) ~/.firefox-free-profile
chcon -Rt svirt_sandbox_file_t ~/.firefox-free-profile

# Build the container
podman build -t firefox-free .

# Install the firefox free app and desktop shortcut
mkdir -p ~/.local/bin/
mkdir -p ~/.local/share/applications/
cp .local/bin/firefox-free ~/.local/bin/
cp .local/share/applications/firefox-free.desktop ~/.local/share/applications/

# Make everyone able to find the firefox-free executable
# for bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
# for gnome
mkdir -p ~/.config/environment.d
echo "PATH=$HOME/.local/bin:$PATH" > ~/.config/environment.d/90-local-bin.conf

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
