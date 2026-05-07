FROM seleniarm/standalone-chromium:4.20.0-20240427

USER root

ENV LANG=C.UTF-8

# Pull options at runtime via run.sh (which jq-reads /data/options.json)
# and exports SE_NODE_MAX_SESSIONS, SE_VNC_PASSWORD, SE_SCREEN_WIDTH and
# SE_SCREEN_HEIGHT. The upstream image picks up these env vars.
COPY rootfs/ /
RUN chmod +x /usr/local/bin/run.sh

CMD ["/usr/local/bin/run.sh"]
