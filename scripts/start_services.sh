#!/usr/bin/env bash
set -e

check_directory_path() {
  if [[ $(pwd) != */fleetdm-docker ]]; then
    printf "Uh oh! Looks like you're in the wrong directory. Navigate to /fleetdm-docker then try again"
    exit 1
  fi
}

main() {
  check_directory_path

  set -o allexport
  source .env
  set +o allexport

  if [ "${CLOUDFLARED_ENABLED}" == "true" ]; then
    echo "CLOUDFLARED_ENABLED is true, running all services..."
    docker-compose --profile tunnel up -d --build
  else
    echo "CLOUDFLARED_ENABLED is not true, running without cloudflared..."
    docker-compose --profile default up -d --build
  fi

}

main
