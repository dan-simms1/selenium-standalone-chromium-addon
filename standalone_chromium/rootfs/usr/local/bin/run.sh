#!/usr/bin/env bash
set -eu

CONFIG=/data/options.json

VNC_ENABLED="false"
if [ -f "$CONFIG" ]; then
    SE_NODE_MAX_SESSIONS="$(jq -r '.max_sessions // 2' "$CONFIG")"
    VNC_ENABLED="$(jq -r '.vnc_enabled // false' "$CONFIG")"
    OPT_VNC_PASSWORD="$(jq -r '.vnc_password // empty' "$CONFIG")"
    SE_SCREEN_WIDTH="$(jq -r '.screen_width // 1920' "$CONFIG")"
    SE_SCREEN_HEIGHT="$(jq -r '.screen_height // 1080' "$CONFIG")"
    export SE_NODE_MAX_SESSIONS SE_SCREEN_WIDTH SE_SCREEN_HEIGHT

    if [ "$VNC_ENABLED" = "true" ]; then
        # User explicitly opted in to noVNC. Pass through their
        # password if set; otherwise fall back to the upstream default
        # of "secret" and log a loud warning so they can see the
        # console is effectively unprotected.
        if [ -n "${OPT_VNC_PASSWORD:-}" ]; then
            export SE_VNC_PASSWORD="${OPT_VNC_PASSWORD}"
        else
            echo "WARNING: vnc_enabled is true but vnc_password is empty."
            echo "         The noVNC console on port 7900 will use the upstream"
            echo "         default password 'secret', which is well-known and"
            echo "         provides no real protection. Set vnc_password in the"
            echo "         add-on Configuration tab to fix this."
            export SE_VNC_PASSWORD="secret"
        fi
    fi
    if [ "$SE_NODE_MAX_SESSIONS" -gt 4 ]; then
        echo "NOTE: max_sessions is $SE_NODE_MAX_SESSIONS. Each session can pin a CPU core; verify your hardware can keep up."
    fi
fi

# The upstream entrypoint sets up Xvfb, the VNC server, the noVNC
# bridge, and the Selenium Grid node. We cannot stop noVNC from
# starting (the upstream supervisord brings it up unconditionally) so
# instead we launch entry_point in the background and, if VNC is not
# enabled, kill noVNC and the underlying x11vnc once they are up.
# Connections to port 7900 will then be refused.
if [ "$VNC_ENABLED" = "true" ]; then
    echo "noVNC is enabled. Browser will be viewable on port 7900."
    exec /opt/bin/entry_point.sh
fi

echo "noVNC is disabled (vnc_enabled=false). Port 7900 will refuse connections."

/opt/bin/entry_point.sh &
ENTRY_PID=$!

# Give the upstream supervisord time to start its services before we
# tear down the VNC ones. 6 seconds is empirically enough on the
# Raspberry Pi 5 hardware the add-on was developed against.
(
    sleep 6
    # noVNC is the websocket-to-VNC bridge that the browser viewer
    # talks to. Killing it stops the on-port-7900 service.
    pkill -f 'novnc' 2>/dev/null || true
    # Also kill x11vnc so the underlying VNC server is gone too.
    # nothing should be exposing 5900 from this add-on anyway.
    pkill -f 'x11vnc' 2>/dev/null || true
    # Re-kill periodically in case supervisord restarts the services.
    while kill -0 "$ENTRY_PID" 2>/dev/null; do
        sleep 30
        pkill -f 'novnc' 2>/dev/null || true
        pkill -f 'x11vnc' 2>/dev/null || true
    done
) &

wait "$ENTRY_PID"
