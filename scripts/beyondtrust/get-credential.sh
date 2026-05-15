#!/bin/bash
# get-credential.sh — Retrieve a credential from BeyondTrust PasswordSafe REST API
# Usage: get-credential.sh <system_name> <account_name>
# Returns: password on stdout; exits non-zero on failure
# Credentials: reads BT_CLIENT_ID and BT_CLIENT_SECRET from Oracle Wallet or env
set -euo pipefail

SYSTEM_NAME="${1:?Usage: $0 <system_name> <account_name>}"
ACCOUNT_NAME="${2:?Usage: $0 <system_name> <account_name>}"
API_BASE="${BT_API_BASE_URL:?BT_API_BASE_URL must be set}"

# Retrieve OAuth credentials from Oracle Wallet (preferred) or environment
if [[ -f "$HOME/.bt_wallet/credentials" ]]; then
  source "$HOME/.bt_wallet/credentials"
fi
CLIENT_ID="${BT_CLIENT_ID:?BT_CLIENT_ID not set}"
CLIENT_SECRET="${BT_CLIENT_SECRET:?BT_CLIENT_SECRET not set}"

# Step 1: Authenticate
# Write JSON body to a restricted temp file so credentials are not visible in ps aux.
_tmpbody=$(mktemp)
chmod 600 "${_tmpbody}"
printf '{"client_id": "%s", "client_secret": "%s"}' "${CLIENT_ID}" "${CLIENT_SECRET}" > "${_tmpbody}"
TOKEN_RESPONSE=$(curl -sf -X POST \
  "${API_BASE}/Auth/SignAppIn" \
  -H "Content-Type: application/json" \
  --data "@${_tmpbody}")
rm -f "${_tmpbody}"
TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Step 2: Create credential release request
REQUEST_RESPONSE=$(curl -sf -X POST \
  "${API_BASE}/Requests" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"SystemName\": \"${SYSTEM_NAME}\", \"AccountName\": \"${ACCOUNT_NAME}\", \"DurationMinutes\": 5, \"Reason\": \"IaC automation\"}")
REQUEST_ID=$(echo "$REQUEST_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['RequestID'])")

# Step 3: Retrieve credential
CRED_RESPONSE=$(curl -sf -X GET \
  "${API_BASE}/Credentials/${REQUEST_ID}" \
  -H "Authorization: Bearer ${TOKEN}")
PASSWORD=$(echo "$CRED_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['Password'])")

# Step 4: Check in (release)
curl -sf -X PUT \
  "${API_BASE}/Requests/${REQUEST_ID}/Checkin" \
  -H "Authorization: Bearer ${TOKEN}" > /dev/null

echo "$PASSWORD"
