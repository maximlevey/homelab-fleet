ARG REDIS_VERSION
FROM redis:${REDIS_VERSION:-6}

HEALTHCHECK --interval=1s --timeout=3s --retries=30 \
  CMD redis-cli ping