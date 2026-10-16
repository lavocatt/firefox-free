# 🦊 firefox-free: The Containerized Dev Browser

A fully functional, hardware-accelerated, unmanaged Firefox instance running inside a rootless Podman container. 

Built to bypass aggressive corporate web proxies and managed browser policies (e.g., Managed Chrome) that break local development environments, Kubernetes dashboards, and upstream OIDC logins.

## The "Zero Trust" Philosophy
This setup creates a **Tiered Security Model** on a single corporate machine:
1. **Corporate (Managed Chrome):** Used exclusively for the internal intranet, HR, and corporate cloud. Contains custom Root CAs and tracking.
2. **Local/Upstream (firefox-free):** A standard consumer browser that does not trust the corporate CAs, so internal HTTPS sites fail certificate validation. Used for standard internet, and `localhost` development. Note that this is trust isolation, not network isolation: the container shares the host network (`--net=host`).

Sites that belong in the other browser can be kept out of firefox-free with the [bypass list](#bypass-list).

## Features
* **Containerized:** Runs as a standard `podman` user process. Leaves no unmanaged binaries in `/usr/bin`.
* **Persistent Profile:** Bookmarks, history, and passwords survive reboots and container rebuilds (`~/.firefox-free-profile`).
* **Hardware Integrated:** Native access to GPU (`/dev/dri`), Audio, and Webcam (all host devices via `--privileged`).
* **Wayland Native:** Full Wayland support with working GNOME screen sharing (via PipeWire and XDG portals).
* **DBus Connected:** No UI freezes; native GNOME file pickers and dialogs.
* **Desktop App Hand-off:** `slack://`, `zoommtg://`, `mailto:` and other custom schemes are forwarded to the host's apps through the XDG desktop portal, so desktop sign-in flows (e.g. Slack) complete.
* **Full Media Playback:** H.264, HEVC and AAC via RPM Fusion's `libavcodec-freeworld`, with VA-API hardware decoding.
* **Bypass List:** Domains you list are opened in another browser when clicked from other apps; a way out for sites that must not, or cannot, be used from firefox-free. Empty by default.
* **Self-Updating:** The image is rebuilt daily with the latest Firefox and security fixes; you are notified when a restart picks it up.
* **SELinux Compliant:** Uses `:Z` flags and `svirt_sandbox_file_t` contexts to play nice with Fedora's security policies.

## Project Structure
* `Containerfile`: The Fedora 44-based blueprint that installs Firefox, codecs and media drivers.
* `firefox-free-prefs.js`: Default Firefox preferences baked into the image (portal hand-off, VA-API).
* `firefox-free`: The heavy-lifting launcher script that mounts the hardware, sockets, and profiles into the container.
* `bypass-domains`: Template for the bypass list (empty).
* `firefox-free-update`: Rebuilds the image with the latest packages.
* `firefox-free-update.{service,timer}`: systemd user units running the rebuild daily.
* `firefox-free.desktop`: The GNOME application shortcut.
* `install.sh`: The idempotent deployment script to set up everything on a fresh machine.

## Installation

1. Clone or download this repository. Keep the clone: automatic updates rebuild from it.
2. Optional: add extra root CA certificates. Every file in `certs/` (git-ignored, populated by hand) is trusted inside the container, so copy only the CAs you deliberately want this browser to trust.
   Do **not** copy the whole host anchors directory: on a managed machine it typically also holds the corporate CAs this browser is meant not to trust. Rebuild the image after changing `certs/`.
3. Run the deployment script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Bypass list

A get-out-of-jail card. firefox-free is usually the default browser, so links clicked in chat, mail or a terminal go through the `firefox-free` launcher. When a link's host is in `~/.config/firefox-free/bypass-domains`, the launcher opens it in another browser instead, and does not start the container if nothing else is left to open. Typical uses: sites that must go through a managed browser, or a site that just doesn't work in firefox-free.

One domain per line, subdomains included, `#` for comments; edits apply on the next click:

```
example.com     # also matches www.example.com, docs.example.com
```

The list is empty by default, and `install.sh` never overwrites your copy.

The bypass browser defaults to `google-chrome`. To pick another, set any command that takes a URL in `~/.config/firefox-free/config` (kept across re-installs):

```bash
BYPASS_BROWSER="firefox"                            # the host's own Firefox
BYPASS_BROWSER="flatpak run com.google.Chrome"      # a Flatpak browser
```

If that command is not installed, the link opens in firefox-free and a notification says so.

Only links coming from other apps are bypassed: links clicked or typed inside firefox-free stay there.

## Updates

Firefox inside the container never updates itself; it is refreshed by rebuilding the image:

* A systemd user timer rebuilds it daily (or at next login if the machine was off).
* Starting `firefox-free` when it is not running also triggers a background rebuild if the last one is over 24h old.
* The new image is used on the next cold start. While Firefox is running on an older image, opening a new window shows an "update ready" notification: close all windows and relaunch.

Manual rebuild and logs:

```bash
firefox-free-update                         # rebuild now
tail ~/.local/state/firefox-free/update.log
systemctl --user list-timers firefox-free-update.timer
```

To move to a new Fedora release, change the `FROM` line of the `Containerfile`.
