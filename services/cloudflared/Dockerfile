ARG CLOUDFLARED_VERSION
FROM cloudflare/cloudflared:${CLOUDFLARED_VERSION:-latest}

ENV CLOUDFLARED_CONFIG=/etc/cloudflared/config.yml
ENV CLOUDFLARED_CERT=/etc/cloudflared/certificate.pem
ENV CLOUDFLARED_CREDS=/etc/cloudflared/credentials.json

COPY secrets/cloudflared.yml ${CLOUDFLARED_CONFIG}
COPY secrets/credentials.json ${CLOUDFLARED_CREDS}
COPY secrets/certificate.pem ${CLOUDFLARED_CERT}

CMD ["tunnel", "--config", "/etc/cloudflared/config.yml", "run"]