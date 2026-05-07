# Selenium Standalone Chromium add-on for Home Assistant

A small Home Assistant add-on that runs Selenium Grid 4 with a real
Chromium browser. Other integrations and add-ons can drive the
browser through the WebDriver protocol on port 4444.

This is a generic helper. It is not specific to any single integration.

This add-on is unofficial and not affiliated with Selenium HQ or
Yorkshire Water Services Limited.

## When you might want this

- A Home Assistant integration needs to drive a real browser to log
  in to a service that uses reCAPTCHA or other anti-bot defences.
- You want to write Python automations that reach pages your standard
  HTTP libraries cannot easily reach.
- You want to debug a headless flow visually via noVNC.

## Installing

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the three-dot menu → **Repositories**.
3. Add `https://github.com/dan-simms1/selenium-standalone-chromium-addon`.
4. Find **Selenium Standalone Chromium** in the store and install it.
5. Set options if you want to change defaults, then **Start**.

## Configuration

| Option | Default | Notes |
| --- | --- | --- |
| `max_sessions` | `2` | Concurrent WebDriver sessions allowed. |
| `vnc_enabled` | `false` | When false, noVNC is not running and connections to port 7900 are refused. Set to `true` only when you want to debug a flow visually. |
| `vnc_password` | _empty_ | Only consulted when `vnc_enabled=true`. Empty falls back to the well-known default `secret` and logs a warning. |
| `screen_width` | `1920` | Virtual display width in pixels. |
| `screen_height` | `1080` | Virtual display height in pixels. |

## Reaching the WebDriver

From other Home Assistant add-ons on the same supervisor network the
hostname is `local-standalone-chromium` (note the dash, not an
underscore).

From the Home Assistant core container, or from the host, use the
host IP and the published port: `http://<ha-ip>:4444/wd/hub`.

## Watching the browser

By default the noVNC viewer is disabled and port 7900 refuses
connections. To enable it:

1. Set `vnc_enabled: true` in the add-on Configuration tab.
2. Set a private `vnc_password` in the same tab.
3. Restart the add-on.
4. Open `http://<ha-ip>:7900/?autoconnect=1` and enter the password.

When you are done debugging, set `vnc_enabled: false` and restart the
add-on so port 7900 is closed again. The viewer is useful when an
automation fails and you want to see what state the page is in, but
keeping it on permanently increases the attack surface for no
operational benefit.

## Security

**Selenium Grid does not authenticate WebDriver requests.** Anyone
who can reach port 4444 can:

- Open a Chromium session on your hardware.
- Type into pages on your behalf, including login forms.
- Read and exfiltrate any cookies set during that session.
- Probe other services on your local network from the browser.
- Watch other users' login flows live via the noVNC viewer if it is
  unprotected.

Treat the add-on as you would treat a remote-execution endpoint.

### Recommended hardening

- **Do not forward port 4444 from your router. Ever.** This is not a
  service that should ever be on the public internet without an
  authenticating reverse proxy.
- **Keep the home network isolated.** Untrusted devices on the same
  Wi-Fi (guest gear, smart speakers, IoT relays you do not control)
  can talk to port 4444 by default. A guest VLAN is a sensible
  perimeter.
- **Keep `vnc_enabled: false` unless you are actively debugging.**
  Default is false. When false, port 7900 refuses connections.
- **If you do enable VNC, set a strong `vnc_password`.** Empty falls
  back to the well-known default `secret` and is no protection.
- **Other Home Assistant add-ons can also reach this service** via
  the supervisor's add-on network. Anything you would not trust to
  drive a browser as you, do not install on the same Home Assistant.
- **Backups contain credentials of integrations that use this add-on.**
  An integration like `ha-yorkshire-water` that drives this Selenium
  has the user's portal password in its config entry and therefore in
  the HA backup. Apply the same backup-protection posture you use for
  any sensitive HA backup (encrypted off-box storage, no public cloud
  drops without encryption).
- **If you need WebDriver access from outside your home network**,
  put a reverse proxy with authentication in front of port 4444. The
  add-on itself does not provide one.

### What to avoid

- Running unsanitised user-supplied URLs through this add-on. The
  browser is real and will execute whatever javascript is served to
  it.
- Trusting cookie values that the browser ends up with after visiting
  attacker-controlled pages without scoping them to the expected host.

## What is inside the image

The add-on layers on top of `seleniarm/standalone-chromium:4.20.0-20240427`,
which bundles:

- Selenium Grid 4.20
- Chromium 124
- chromedriver 124
- Xvfb virtual display
- A noVNC server on port 7900

The add-on adds a small launcher that reads `/data/options.json`,
exports the matching `SE_*` environment variables, and hands off to
the upstream entry point.

## Versioning

| Add-on version | Notes |
| --- | --- |
| 1.2.0 | Added `vnc_enabled` (default false). Closes port 7900 by default; opt in for debugging. |
| 1.1.2 | Empty `vnc_password` explicitly falls back to upstream `secret` with warning aligned to docs. |
| 1.1.1 | Dropped armv7 (upstream image does not ship that arch). Empty `vnc_password` default with a noisy warning at start. Strengthened security section. |
| 1.1.0 | First public release. Adds VNC password, screen size, and max sessions options. |
| 1.0.0 | Internal version. Plain wrapper around `seleniarm/standalone-chromium:latest`. |

## License

MIT. See `LICENSE`.

The bundled `seleniarm/standalone-chromium` image is licensed under
Apache 2.0 by SeleniumHQ. Chromium itself is licensed under the BSD
license and others.
