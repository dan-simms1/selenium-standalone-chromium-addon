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
| `vnc_password` | `secret` | Password for the noVNC viewer on port 7900. Change this. |
| `screen_width` | `1920` | Virtual display width in pixels. |
| `screen_height` | `1080` | Virtual display height in pixels. |

## Reaching the WebDriver

From other Home Assistant add-ons on the same supervisor network the
hostname is `local-standalone-chromium` (note the dash, not an
underscore).

From the Home Assistant core container, or from the host, use the
host IP and the published port: `http://<ha-ip>:4444/wd/hub`.

## Watching the browser

Open `http://<ha-ip>:7900/?autoconnect=1` in a browser. Enter the
`vnc_password` from your add-on options. Useful when an automation
fails and you want to see what state the page is in.

## Security

**Selenium Grid does not authenticate WebDriver requests.** Anyone
who can reach port 4444 can drive a browser on your machine. The
add-on intentionally does not expose this port to the internet.

- Only run this add-on on a trusted home network.
- Do not forward port 4444 from your router. Ever.
- Keep the noVNC password (`vnc_password`) set to something private
  if your network is shared.

If you need WebDriver access from outside your home network, put a
reverse proxy with authentication in front of port 4444. The add-on
itself does not provide one.

## What is inside the image

The add-on layers on top of `seleniarm/standalone-chromium:4.20.0-20240425`,
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
| 1.1.0 | First public release. Adds VNC password, screen size, and max sessions options. |
| 1.0.0 | Internal version. Plain wrapper around `seleniarm/standalone-chromium:latest`. |

## License

MIT. See `LICENSE`.

The bundled `seleniarm/standalone-chromium` image is licensed under
Apache 2.0 by SeleniumHQ. Chromium itself is licensed under the BSD
license and others.
