#!/usr/bin/env bash
set -e

check_directory_path() {
  if [[ $(pwd) != */fleetdm-docker ]]; then
    printf "Uh oh! Looks like you're in the wrong directory. Navigate to /fleetdm-docker then try again"
    exit 1
  fi
}

clean_secrets_folder() {
  find "secrets" -type f -not -name ".*" -exec rm -f {} \;
}

check_cloudflared_login() {
  if [ ! -f "$HOME"/.cloudflared/cert.pem ]; then
    printf "Unable to find cloudflare certificate. Run 'cloudflared login' then try again"
    exit 1
  fi
}

cloudflare_tunnel_specified() {
  if [ -z "${CLOUDFLARED_TUNNEL_ID}" ]; then
    printf "Cloudflared tunnel ID not specified. A new tunnel will be created.\n\n"
    false
  else
    true
  fi
}

read_tunnel_credentials() {
  if ! cloudflared tunnel token --credfile "secrets/credentials.json" "${CLOUDFLARED_TUNNEL_ID}" &>/dev/null; then
    printf "Failed to read credentials for provided tunnel ID. Check .env then try again"
    exit 1
  fi
}

create_cloudflared_tunnel() {
  local tunnel_name
  tunnel_name="fleetdm-$(openssl rand -hex 4)"

  local cmd_output
  cmd_output="$(cloudflared tunnel create --cred-file "secrets/credentials.json" "${tunnel_name}")"

  CLOUDFLARED_TUNNEL_ID="$(echo "${cmd_output}" \
    | grep -o 'Created tunnel .* with id .*' \
    | awk '{print $NF}')"
}

generate_openssl_certificates() {
  local common_name
  read -rp "Enter a common name for your certificate: " common_name

  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout "secrets/certificate.pem" -out "secrets/certificate.key" \
    -subj "/CN=${common_name}" -addext "subjectAltName=DNS:${common_name}"
}

prompt_certificate_paths() {
  local cert_path key_path

  read -rp "Enter the /full/path/to your certificate file: " cert_path
  cp "${cert_path}" "secrets/certificate.pem"

  read -rp "Enter the /full/path/to your key file: " key_path
  cp "${key_path}" "secrets/certificate.key"
}

generate_cloudflared_config() {
  local hostname
  printf "Enter the ingress hostname for your tunnel: "
  read -r hostname

  cat <<EOF >secrets/cloudflared.yml
tunnel: ${CLOUDFLARED_TUNNEL_ID}
credentials-file: /etc/cloudflared/credentials.json
ingress:
  - hostname: ${hostname}
    service: https://localhost:8080
    originRequest:
      caPool: /etc/cloudflared/certificate.pem
  - service: http_status:404
EOF
}

main() {

  check_directory_path

  type cloudflared &>/dev/null || { echo "Requirement 'cloudflared' not installed"; exit 1; }
  type openssl &>/dev/null || { echo "Requirement 'openssl' not installed"; exit 1; }

  set -o allexport
  source .env
  set +o allexport

  local setup_warning
  read -rp "Setup will remove all files in the secrets directory. Proceed? (y/n): " setup_warning
  case "${setup_warning,,}" in
    "y" | "yes") clean_secrets_folder ;;
    *) exit 0 ;;
  esac

  if "${CLOUDFLARED_ENABLED}"; then
    printf "\nCLOUDFLARED_ENABLED is set to true. Cloudflared tunnel will be used.\n"
    if cloudflare_tunnel_specified; then
      read_tunnel_credentials
    else
      create_cloudflared_tunnel
    fi
  fi

  local generate_certs
  read -rp "Generate self-signed certificates with openssl? (y/n): " generate_certs

  case "${generate_certs,,}" in
    "y" | "yes") generate_openssl_certificates ;;
    *) prompt_certificate_paths ;;
  esac

  if "${CLOUDFLARED_ENABLED}"; then
    generate_cloudflared_config
  fi

  chmod -R 755 secrets
}

main
