#!/bin/bash

set -e

set -o allexport
source .env
set +o allexport

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout "${FLEET_SERVER_KEY}" -out "${FLEET_SERVER_CERT}" -subj "/CN=${SERVER_NAME}" \
  -addext "subjectAltName=DNS:${SERVER_NAME}"


