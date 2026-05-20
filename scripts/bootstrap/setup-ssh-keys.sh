#!/usr/bin/env bash
set -euo pipefail

# Generates an ed25519 SSH key pair for oracle-iac automation and copies the
# public key to KVM hosts listed as arguments or parsed from the primary
# inventory example.
#
# Usage: setup-ssh-keys.sh [kvm-host-1 kvm-host-2 ...]
#
# If no hosts are supplied the script parses ansible_host values from
# ansible/inventories/primary.yml.example (kvm_hosts group only).
#
# The generated private key path is written to stdout so callers can reference
# it in terraform.tfvars (ssh_public_key variable).
#
# Note: ssh-copy-id uses StrictHostKeyChecking=no for first-run bootstrap only.
# After initial distribution, host key verification should be enforced.

KEY_PATH="${HOME}/.ssh/oracle_iac_ed25519"
KEY_COMMENT="oracle-iac-automation"
# Resolve repo root regardless of cwd.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
INVENTORY="${REPO_ROOT}/ansible/inventories/primary.yml.example"

# ---------------------------------------------------------------------------
# 1. Generate key pair (idempotent — skipped if key already exists)
# ---------------------------------------------------------------------------
if [[ ! -f "${KEY_PATH}" ]]; then
  echo "Generating SSH key pair at ${KEY_PATH}..."
  ssh-keygen -t ed25519 -f "${KEY_PATH}" -C "${KEY_COMMENT}" -N ""
  chmod 600 "${KEY_PATH}"
  chmod 644 "${KEY_PATH}.pub"
  echo "Key generated."
else
  echo "Key already exists at ${KEY_PATH} — skipping generation."
fi

echo ""
echo "Public key (${KEY_PATH}.pub):"
cat "${KEY_PATH}.pub"
echo ""

# ---------------------------------------------------------------------------
# 2. Resolve target KVM hosts
# ---------------------------------------------------------------------------
if [[ $# -gt 0 ]]; then
  # Hosts passed explicitly on the command line.
  KVM_HOSTS=("$@")
else
  # Parse ansible_host values from the kvm_hosts section of the inventory.
  # The awk range prints lines between 'kvm_hosts:' and the next top-level key
  # (a line that starts with a non-space, non-hash character after the match).
  if [[ ! -f "${INVENTORY}" ]]; then
    echo "ERROR: No hosts provided and inventory example not found at:"
    echo "       ${INVENTORY}"
    echo "Usage: $0 kvm-host-1 kvm-host-2 ..."
    exit 1
  fi

  mapfile -t KVM_HOSTS < <(
    awk '
      /^    kvm_hosts:/ { in_block=1; next }
      in_block && /^[a-zA-Z]/ { exit }
      in_block && /ansible_host:/ { print $2 }
    ' "${INVENTORY}"
  )

  # Fallback: use FQDN hostnames from the kvm_hosts group if no ansible_host
  # entries are present (they are optional in the primary example).
  if [[ ${#KVM_HOSTS[@]} -eq 0 ]]; then
    mapfile -t KVM_HOSTS < <(
      awk '
        /^    kvm_hosts:/ { in_block=1; next }
        in_block && /^[a-zA-Z]/ { exit }
        in_block && /hosts:/ { in_hosts=1; next }
        in_hosts && /^          [a-zA-Z]/ { gsub(/:.*/, ""); print $1 }
      ' "${INVENTORY}"
    )
  fi
fi

if [[ ${#KVM_HOSTS[@]} -eq 0 ]]; then
  echo "ERROR: No KVM hosts could be determined."
  echo "       Provide host names/IPs as arguments or populate ansible_host entries"
  echo "       in ${INVENTORY}."
  exit 1
fi

# ---------------------------------------------------------------------------
# 3. Distribute public key
# ---------------------------------------------------------------------------
echo "Distributing public key to ${#KVM_HOSTS[@]} KVM host(s)..."
FAILED_HOSTS=()

for host in "${KVM_HOSTS[@]}"; do
  echo "  -> ${host}"
  if ssh-copy-id \
       -i "${KEY_PATH}.pub" \
       -o StrictHostKeyChecking=no \
       -o ConnectTimeout=10 \
       "root@${host}" 2>/dev/null; then
    echo "     OK"
  else
    echo "     FAILED (check connectivity and that sshd is running on ${host})"
    FAILED_HOSTS+=("${host}")
  fi
done

echo ""
if [[ ${#FAILED_HOSTS[@]} -gt 0 ]]; then
  echo "WARNING: Key distribution failed for ${#FAILED_HOSTS[@]} host(s):"
  for h in "${FAILED_HOSTS[@]}"; do
    echo "  - ${h}"
  done
  echo ""
fi

echo "Done."
echo ""
echo "Add the following to your environment terraform.tfvars:"
echo "  ssh_public_key = \"$(cat "${KEY_PATH}.pub")\""
echo ""
echo "Ansible inventory ssh_private_key_file value:"
echo "  ansible_ssh_private_key_file: ${KEY_PATH}"
