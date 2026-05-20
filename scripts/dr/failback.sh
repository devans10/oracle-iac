#!/usr/bin/env bash
set -euo pipefail

# Reverses a DR activation by reinstating the original primary as a physical
# standby, then switching back to it via dgmgrl switchover.
#
# Usage: failback.sh [--original-primary DB] [--current-primary DB]
#
#   --original-primary  DG database name of the site that was primary before DR
#                       activation (default: CCB — matches dg_primary_db in the
#                       oracle-data-guard role defaults). Will be reinstated as
#                       a standby first, then promoted back to primary.
#   --current-primary   DG database name of the site currently acting as primary
#                       (the DR site, default: CCB_DR — matches dg_standby_db).
#
# Prerequisites (verify before running):
#   - Original primary host is powered on and reachable via SCAN listener.
#   - Oracle instance on the original primary is started (MOUNT mode acceptable;
#     dgmgrl reinstate handles further recovery).
#   - DG observer is running if dg_observer_enabled=true in role defaults.
#   - Application workload is quiesced on the current primary before switchover.
#
# Run as the oracle OS user on the current primary (DR site).
# dgmgrl uses OS (/) authentication — no password is passed on the command line
# or written to disk.

ORIGINAL_PRIMARY="CCB"
CURRENT_PRIMARY="CCB_DR"
ORACLE_BASE="${ORACLE_BASE:-/u01/oracle}"
DGMGRL="${DGMGRL_BIN:-${ORACLE_BASE}/products/db_client/bin/dgmgrl}"

usage() {
  echo "Usage: $0 [--original-primary CCB] [--current-primary CCB_DR]"
  echo ""
  echo "  --original-primary  DB name of the site that was primary before DR activation"
  echo "                      (will be reinstated as standby, then promoted back)"
  echo "  --current-primary   DB name of the site currently acting as primary (DR site)"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --original-primary) ORIGINAL_PRIMARY="$2"; shift 2 ;;
    --current-primary)  CURRENT_PRIMARY="$2";  shift 2 ;;
    -h|--help)          usage ;;
    *)                  echo "ERROR: Unknown argument: $1"; usage ;;
  esac
done

if [[ ! -x "${DGMGRL}" ]]; then
  echo "ERROR: dgmgrl not found or not executable at ${DGMGRL}"
  echo "       Set ORACLE_BASE or DGMGRL_BIN to the correct DB client home."
  exit 1
fi

echo "=== Data Guard Failback: ${CURRENT_PRIMARY} -> ${ORIGINAL_PRIMARY} ==="
echo "    dgmgrl           : ${DGMGRL}"
echo "    current primary  : ${CURRENT_PRIMARY} (DR site)"
echo "    original primary : ${ORIGINAL_PRIMARY} (Site A — being reinstated)"
echo ""

# Idempotency guard: if original primary is already PRIMARY, nothing to do.
ORIG_ROLE=$("${DGMGRL}" -silent / "show database ${ORIGINAL_PRIMARY}" 2>&1 \
  | grep -i "^  Role:" | awk '{print $NF}' || echo "unknown")
if echo "${ORIG_ROLE}" | grep -qi "primary"; then
  echo "INFO: ${ORIGINAL_PRIMARY} is already PRIMARY — no failback action needed."
  exit 0
fi

# Step 1: Reinstate original primary as a physical standby.
# dgmgrl reinstate uses flashback database or RMAN-based duplicate as appropriate.
# This step may take several minutes while accumulated redo is applied.
echo "Step 1: Reinstating ${ORIGINAL_PRIMARY} as physical standby..."
echo "        This may take several minutes while redo is applied."
"${DGMGRL}" / "reinstate database ${ORIGINAL_PRIMARY}"

# Step 2: Verify the overall DG configuration is healthy before proceeding.
echo ""
echo "Step 2: Verifying Data Guard configuration after reinstate..."
DG_STATUS=$("${DGMGRL}" -silent / "show configuration" 2>&1 || true)
echo "${DG_STATUS}"
if ! echo "${DG_STATUS}" | grep -q "SUCCESS"; then
  echo ""
  echo "ERROR: Data Guard configuration is not SUCCESS after reinstate."
  echo "       Review the output above and resolve issues before proceeding."
  echo "       Do NOT run switchover until 'show configuration' reports SUCCESS."
  exit 1
fi

# Step 3: Switchover back to the original primary.
# Applications must be quiesced before this point to avoid in-flight transaction loss.
echo ""
echo "Step 3: Switching back to ${ORIGINAL_PRIMARY}..."
echo "        Ensure all application workload is quiesced before confirming."
read -r -p "Confirm switchover to ${ORIGINAL_PRIMARY}? [yes/NO] " confirm
[[ "${confirm}" != "yes" ]] && { echo "Aborted. Re-run when ready."; exit 1; }

"${DGMGRL}" / "switchover to ${ORIGINAL_PRIMARY}"

echo ""
echo "=== Failback complete ==="
echo ""
echo "Next steps:"
echo "  1. Verify Site A (original primary) is healthy:"
echo "       bash $(dirname "$0")/validate-dr.sh ${ORIGINAL_PRIMARY}"
echo "  2. Update Ansible inventory back to the primary site:"
echo "       ansible/inventories/primary.yml"
echo "  3. Verify all application services against primary site:"
echo "       bash scripts/validation/smoke-test-all.sh primary"
echo "  4. Confirm ${CURRENT_PRIMARY} is now standby in DG configuration:"
echo "       ${DGMGRL} / \"show configuration\""
