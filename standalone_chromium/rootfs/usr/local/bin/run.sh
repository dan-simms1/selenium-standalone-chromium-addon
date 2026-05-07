#!/usr/bin/env bash
set -eu

CONFIG=/data/options.json

if [ -f "$CONFIG" ]; then
    export SE_NODE_MAX_SESSIONS="$(jq -r '.max_sessions // 2' "$CONFIG")"
    export SE_VNC_PASSWORD="$(jq -r '.vnc_password // "secret"' "$CONFIG")"
    export SE_SCREEN_WIDTH="$(jq -r '.screen_width // 1920' "$CONFIG")"
    export SE_SCREEN_HEIGHT="$(jq -r '.screen_height // 1080' "$CONFIG")"
fi

# The upstream entrypoint sets up Xvfb, the VNC server (read-only by
# default), and the Selenium Grid node. Hand off to it.
exec /opt/bin/entry_point.sh
