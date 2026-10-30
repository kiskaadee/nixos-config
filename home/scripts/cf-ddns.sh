#!/usr/bin/env bash
# 🌐 Cloudflare DDNS Quick Updater for roadtotech.me

ZONE="roadtotech.me"
TARGET_RECORDS=("roadtotech.me" "mail.roadtotech.me")

# 1. Load Cloudflare credentials via SOPS if not already present in environment
if [[ -z "${CF_API_TOKEN:-}" ]]; then
  secrets_file="${HOME}/Config/secrets.yaml"
  if [[ -f "${secrets_file}" ]] && command -v sops >/dev/null 2>&1; then
    CF_API_TOKEN="$(sops -d --extract '["cloudflare"]["api_token"]' "${secrets_file}")"
    export CF_API_TOKEN
    CF_ACCOUNT_ID="$(sops -d --extract '["cloudflare"]["account_id"]' "${secrets_file}")"
    export CF_ACCOUNT_ID
  fi
fi

if [[ -z "${CF_API_TOKEN:-}" ]]; then
  echo "Error: CF_API_TOKEN is not set and could not be extracted from secrets.yaml." >&2
  exit 1
fi

# 2. Determine target public WAN IP
if [[ -n "${1:-}" ]]; then
  NEW_IP="$1"
  echo "Using manually specified IP: ${NEW_IP}"
else
  echo "Detecting current public WAN IP..."
  NEW_IP="$(curl -s --max-time 5 https://api.ipify.org || curl -s --max-time 5 https://icanhazip.com || true)"
  NEW_IP="$(echo "${NEW_IP}" | tr -d '[:space:]')"
  echo "Detected WAN IP: ${NEW_IP}"
fi

# Validate IPv4 format
if [[ ! "${NEW_IP}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  echo "Error: Invalid IPv4 address '${NEW_IP}'" >&2
  exit 1
fi

# 3. Query Cloudflare for existing records
echo "Fetching active DNS records for ${ZONE}..."
DNS_JSON="$(flarectl --json dns list --zone "${ZONE}")"

# 4. Iterate and update target A records
UPDATED=0
for RECORD_NAME in "${TARGET_RECORDS[@]}"; do
  RECORD_INFO="$(echo "${DNS_JSON}" | jq -r --arg name "${RECORD_NAME}" '.[] | select(.Name == $name and .Type == "A")')"

  if [[ -z "${RECORD_INFO}" ]]; then
    echo "Warning: Record '${RECORD_NAME}' (Type A) not found in zone ${ZONE}." >&2
    continue
  fi

  RECORD_ID="$(echo "${RECORD_INFO}" | jq -r '.ID')"
  CURRENT_IP="$(echo "${RECORD_INFO}" | jq -r '.Content')"

  if [[ "${CURRENT_IP}" == "${NEW_IP}" ]]; then
    echo "✓ ${RECORD_NAME} is already up to date (${CURRENT_IP})."
  else
    echo "Updating ${RECORD_NAME}: ${CURRENT_IP} -> ${NEW_IP}..."
    flarectl dns update --zone "${ZONE}" --id "${RECORD_ID}" --content "${NEW_IP}"
    echo "✓ ${RECORD_NAME} updated successfully."
    UPDATED=1
  fi
done

# 5. Verification
if [[ "${UPDATED}" -eq 1 ]]; then
  echo "Verifying resolution on Cloudflare nameservers..."
  sleep 2
  RESOLVED_IP="$(dig @pam.ns.cloudflare.com "${ZONE}" +short | tail -n1)"
  echo "Authoritative pam.ns.cloudflare.com resolves ${ZONE} -> ${RESOLVED_IP}"
fi

echo "Done."
