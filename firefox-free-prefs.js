// Route external URI schemes (slack://, zoommtg://, mailto:, ...) through the
// host's xdg-desktop-portal. The container cannot see host .desktop files or
// binaries, so without this Firefox has no handler for custom schemes.
pref("widget.use-xdg-desktop-portal.open-uri", 1);
// Ask the portal to show the host "Open with" dialog when no handler is known.
pref("widget.use-xdg-desktop-portal.mime-handler", 1);
// VA-API hardware decoding (needs libavcodec + mesa-va-drivers-freeworld).
pref("media.ffmpeg.vaapi.enabled", true);
