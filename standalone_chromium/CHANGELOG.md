# Changelog

## 1.2.0

- Added `vnc_enabled` option (default `false`). When disabled, the
  add-on starts the upstream entry point, then kills the noVNC and
  x11vnc processes so port 7900 refuses connections. A periodic
  re-kill loop catches any supervisord-driven restarts.
- The Yorkshire Water integration that drives this add-on never uses
  noVNC, so the new default is more sensible: closed by default, opt
  in only when actively debugging.
- README explains the new flow and recommends turning VNC off again
  after debugging.

## 1.1.2

- Empty `vnc_password` now explicitly falls back to the upstream
  default `secret` (instead of silently relying on the upstream image
  to do that, which was confusing and not what the previous warning
  claimed). The warning is updated to say so. README updated.

## 1.1.1

- Dropped `armv7` from the supported arch list; the upstream
  `seleniarm/standalone-chromium` image does not currently ship an
  armv7 tag.
- `vnc_password` defaults to empty. An empty password logs a warning
  on start so it is obvious in the add-on log that the noVNC viewer is
  unprotected; previously the default was a literal "secret" which
  was worse.
- Strengthened the README's security section: explicit attack-surface
  list, guidance on isolating the LAN, note that other add-ons on the
  same Home Assistant can reach this add-on, and a backup-handling
  note for integrations that store credentials.

## 1.1.0

- First public release on GitHub.
- Pinned upstream image to `seleniarm/standalone-chromium:4.20.0-20240425`
  for reproducible builds.
- Added options: `max_sessions`, `vnc_password`, `screen_width`,
  `screen_height`.
- Exposed noVNC port 7900 for live browser viewing.
- Added README, LICENSE, security notes.

## 1.0.0

- Internal-only version. Plain wrapper around
  `seleniarm/standalone-chromium:latest`.
