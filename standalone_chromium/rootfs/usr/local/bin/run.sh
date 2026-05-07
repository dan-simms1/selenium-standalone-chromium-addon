#!/usr/bin/env bash
set -eu

CONFIG=/data/options.json

if [ -f "$CONFIG" ]; then
    SE_NODE_MAX_SESSIONS="$(jq -r '.max_sessions // 2' "$CONFIG")"
    SE_VNC_PASSWORD="$(jq -r '.vnc_password // empty' "$CONFIG")"
    SE_SCREEN_WIDTH="$(jq -r '.screen_width // 1920' "$CONFIG")"
    SE_SCREEN_HEIGHT="$(jq -r '.screen_height // 1080' "$CONFIG")"
    export SE_NODE_MAX_SESSIONS SE_SCREEN_WIDTH SE_SCREEN_HEIGHT
    if [ -n "${SE_VNC_PASSWORD:-}" ]; then
        export SE_VNC_PASSWORD
    else
        echo "WARNING: vnc_password is empty. The noVNC console on port 7900 will be unprotected."
        echo "         Set vnc_password in the add-on Configuration tab to enable a password."
    fi
    if [ "$SE_NODE_MAX_SESSIONS" -gt 4 ]; then
        echo "NOTE: max_sessions is $SE_NODE_MAX_SESSIONS. Each session can pin a CPU core; verify your hardware can keep up."
    fi
fi

# The upstream entrypoint sets up Xvfb, the VNC server, and the
# Selenium Grid node. Hand off to it.
exec /opt/bin/entry_point.sh
