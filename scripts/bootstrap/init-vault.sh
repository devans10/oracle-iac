#!/bin/bash
# init-vault.sh — One-time bootstrap: initialize Ansible Vault and verify BeyondTrust connectivity
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "=== Oracle IaC Bootstrap ==="
echo ""

# 1. Vault password
if [[ ! -f ~/.vault_pass ]]; then
  echo "Create Ansible Vault password file at ~/.vault_pass"
  read -rs -p "Enter vault password: " vp && echo
  echo "$vp" > ~/.vault_pass
  chmod 600 ~/.vault_pass
  echo "✓ Vault password stored"
else
  echo "✓ Vault password file already exists"
fi

# 2. BeyondTrust credentials
if [[ ! -f ~/.bt_wallet/credentials ]]; then
  echo ""
  echo "Configure BeyondTrust PasswordSafe API credentials"
  mkdir -p ~/.bt_wallet && chmod 700 ~/.bt_wallet
  read -p "BT API Base URL: " bt_url
  read -p "BT Client ID: " bt_id
  read -rs -p "BT Client Secret: " bt_secret && echo
  cat > ~/.bt_wallet/credentials << CREDS
export BT_API_BASE_URL="${bt_url}"
export BT_CLIENT_ID="${bt_id}"
export BT_CLIENT_SECRET="${bt_secret}"
CREDS
  chmod 600 ~/.bt_wallet/credentials
  echo "✓ BeyondTrust credentials stored"
else
  echo "✓ BeyondTrust credentials already configured"
fi

# 3. Verify BeyondTrust API connectivity
source ~/.bt_wallet/credentials
echo ""
echo "Testing BeyondTrust API connectivity..."
HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" \
  "${BT_API_BASE_URL}/Auth/SignAppIn" \
  -H "Content-Type: application/json" \
  -d "{\"client_id\": \"${BT_CLIENT_ID}\", \"client_secret\": \"${BT_CLIENT_SECRET}\"}" || echo "000")
if [[ "$HTTP_CODE" == "200" ]]; then
  echo "✓ BeyondTrust API reachable and credentials valid"
else
  echo "⚠ BeyondTrust API returned HTTP ${HTTP_CODE} — check connectivity and credentials"
fi

# 4. Vault yml
if [[ ! -f "$REPO_ROOT/group_vars/all/vault.yml" ]]; then
  echo ""
  echo "Creating vault.yml from example..."
  cp "$REPO_ROOT/group_vars/all/vault.yml.example" "$REPO_ROOT/group_vars/all/vault.yml"
  echo "✓ Created group_vars/all/vault.yml — edit it with real values then run:"
  echo "  ansible-vault encrypt group_vars/all/vault.yml"
else
  echo "✓ vault.yml already exists"
fi

echo ""
echo "=== Bootstrap complete ==="
echo "Next steps:"
echo "  1. Edit group_vars/all/vault.yml with bootstrap credentials"
echo "  2. ansible-vault encrypt group_vars/all/vault.yml"
echo "  3. Copy ansible/inventories/primary.yml.example → ansible/inventories/primary.yml and fill in hostnames"
echo "  4. Run: ansible-playbook ansible/playbooks/site/site.yml -i ansible/inventories/primary.yml"
