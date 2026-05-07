#!/usr/bin/env bash
set -eu

CONFIG=/data/options.json

if [ -f "$CONFIG" ]; then
    SE_NODE_MAX_SESSIONS="$(jq -r '.max_sessions // 2' "$CONFIG")"
    OPT_VNC_PASSWORD="$(jq -r '.vnc_password // empty' "$CONFIG")"
    SE_SCREEN_WIDTH="$(jq -r '.screen_width // 1920' "$CONFIG")"
    SE_SCREEN_HEIGHT="$(jq -r '.screen_height // 1080' "$CONFIG")"
    export SE_NODE_MAX_SESSIONS SE_SCREEN_WIDTH SE_SCREEN_HEIGHT

    # The upstream seleniarm image sets VNC_PASSWORD to "secret" by
    # default unless we override it. We have three behaviours:
    #
    #   - User set vnc_password: use that value.
    #   - User left it empty: keep the upstream default of "secret"
    #     and log a loud warning. "secret" is well-known and offers no
    #     real protection; this is intentional so the noVNC viewer
    #     keeps working without configuration, but the user is told.
    #
    # We never disable the password entirely (no SE_VNC_NO_PASSWORD)
    # because an unauthenticated noVNC stream is a genuinely bad
    # default for a service that watches a live login.
    if [ -n "${OPT_VNC_PASSWORD:-}" ]; then
        export SE_VNC_PASSWORD="${OPT_VNC_PASSWORD}"
    else
        echo "WARNING: vnc_password is empty. The noVNC console on port 7900"
        echo "         will use the upstream default password 'secret', which"
        echo "         is well-known and provides no real protection."
        echo "         Set vnc_password in the add-on Configuration tab to fix this."
        export SE_VNC_PASSWORD="secret"
    fi
    if [ "$SE_NODE_MAX_SESSIONS" -gt 4 ]; then
        echo "NOTE: max_sessions is $SE_NODE_MAX_SESSIONS. Each session can pin a CPU core; verify your hardware can keep up."
    fi
fi

# The upstream entrypoint sets up Xvfb, the VNC server, and the
# Selenium Grid node. Hand off to it.
exec /opt/bin/entry_point.sh
