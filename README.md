# 🦊 firefox-free: The Containerized Dev Browser

A fully functional, hardware-accelerated, unmanaged Firefox instance running inside a rootless Podman container. 

Built to bypass aggressive corporate web proxies and managed browser policies (e.g., Managed Chrome) that break local development environments, Kubernetes dashboards, and upstream OIDC logins.

## The "Zero Trust" Philosophy
This setup creates a **Tiered Security Model** on a single corporate machine:
1. **Corporate (Managed Chrome):** Used exclusively for internal intranet (`w3`), HR, and corporate cloud. Contains custom Root CAs and tracking.
2. **Local/Upstream (firefox-free):** An air-gapped, standard consumer browser. It physically cannot access internal networks because it lacks the corporate SSL certificates. Used for standard internet, and `localhost` development.

## Features
* **Containerized:** Runs as a standard `podman` user process. Leaves no unmanaged binaries in `/usr/bin`.
* **Persistent Profile:** Bookmarks, history, and passwords survive reboots and container rebuilds (`~/.firefox-free-profile`).
* **Hardware Integrated:** Native access to GPU (`/dev/dri`), Audio, and Webcam (`/dev/video0`).
* **Wayland Native:** Full Wayland support with working GNOME screen sharing (via PipeWire and XDG portals).
* **DBus Connected:** No UI freezes; native GNOME file pickers and dialogs.
* **SELinux Compliant:** Uses `:Z` flags and `svirt_sandbox_file_t` contexts to play nice with Fedora's security policies.

## Project Structure
* `Containerfile`: The Fedora 43-based blueprint that installs Firefox and necessary media drivers.
* `firefox-free`: The heavy-lifting launcher script that mounts the hardware, sockets, and profiles into the container.
* `firefox-free.desktop`: The GNOME application shortcut.
* `install.sh`: The idempotent deployment script to set up everything on a fresh machine.

## Installation

1. Clone or download this repository.
2. Run the deployment script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
