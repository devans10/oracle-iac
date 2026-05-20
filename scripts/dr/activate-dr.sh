#!/usr/bin/env bash
set -euo pipefail

# Activates the DR site via Oracle Data Guard switchover (planned, graceful)
# or failover (emergency, primary unavailable).
#
# Usage: activate-dr.sh --mode switchover|failover [--primary DB] [--standby DB]
#
#   --mode switchover  Graceful planned switchover. Both sites must be reachable.
#                      Data loss = zero. Recommended for planned maintenance.
#   --mode failover    Emergency activation. Primary may be lost or unreachable.
#                      Potential data loss depends on DG protection mode
#                      (MAXAVAILABILITY as configured in oracle-data-guard role).
#                      Requires explicit typed confirmation before proceeding.
#
#   --primary   DG database name for the current primary (default: CCB — matches
#               dg_primary_db in oracle-data-guard role defaults)
#   --standby   DG database name for the target standby  (default: CCB_DR — matches
#               dg_standby_db in oracle-data-guard role defaults)
#
# Run as the oracle OS user. dgmgrl uses OS (/) authentication — no password is
# passed on the command line or written to disk.
#
# After activation run validate-dr.sh to confirm the new primary is healthy,
# then update Ansible inventory to dr.yml and restart application services.

MODE=""
PRIMARY_DB="CCB"
STANDBY_DB="CCB_DR"
ORACLE_BASE="${ORACLE_BASE:-/u01/oracle}"
DGMGRL="${DGMGRL_BIN:-${ORACLE_BASE}/products/db_client/bin/dgmgrl}"

usage() {
  echo "Usage: $0 --mode switchover|failover [--primary CCB] [--standby CCB_DR]"
  echo ""
  echo "  --mode       switchover  Graceful planned switchover (both sites up)"
  echo "               failover   Emergency failover (primary lost)"
  echo "  --primary    DG name of the current primary DB (default: CCB)"
  echo "  --standby    DG name of the target standby DB  (default: CCB_DR)"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)     MODE="$2";       shift 2 ;;
    --primary)  PRIMARY_DB="$2"; shift 2 ;;
    --standby)  STANDBY_DB="$2"; shift 2 ;;
    -h|--help)  usage ;;
    *)          echo "ERROR: Unknown argument: $1"; usage ;;
  esac
done

[[ -z "${MODE}" ]] && { echo "ERROR: --mode is required"; usage; }
[[ "${MODE}" != "switchover" && "${MODE}" != "failover" ]] && \
  { echo "ERROR: --mode must be 'switchover' or 'failover'"; usage; }

if [[ ! -x "${DGMGRL}" ]]; then
  echo "ERROR: dgmgrl not found or not executable at ${DGMGRL}"
  echo "       Set ORACLE_BASE or DGMGRL_BIN to the correct DB client home."
  exit 1
fi

echo "=== Data Guard ${MODE^^}: ${PRIMARY_DB} -> ${STANDBY_DB} ==="
echo "    dgmgrl  : ${DGMGRL}"
echo "    mode    : ${MODE}"
echo ""

# Idempotency guard: if the target standby is already PRIMARY, nothing to do.
CURRENT_ROLE=$("${DGMGRL}" -silent / "show database ${STANDBY_DB}" 2>&1 \
  | grep -i "^  Role:" | awk '{print $NF}' || echo "unknown")
if echo "${CURRENT_ROLE}" | grep -qi "primary"; then
  echo "INFO: ${STANDBY_DB} is already PRIMARY — no action needed."
  exit 0
fi

# Run pre-activation readiness checks.
# For switchover: failures are fatal — do not risk an unclean switchover.
# For failover:   failures are warnings — primary may be unreachable by design.
echo "Running pre-activation readiness checks..."
VALIDATE_SCRIPT="$(dirname "$0")/validate-dr.sh"
if [[ -x "${VALIDATE_SCRIPT}" ]]; then
  if ! bash "${VALIDATE_SCRIPT}" "${STANDBY_DB}" 2>&1; then
    if [[ "${MODE}" == "switchover" ]]; then
      echo ""
      echo "ERROR: Readiness checks failed. Aborting switchover."
      echo "       Resolve the issues above or use --mode failover for emergency activation."
      exit 1
    else
      echo ""
      echo "WARN: Readiness checks failed but proceeding with emergency failover."
    fi
  fi
else
  echo "WARN: validate-dr.sh not found at ${VALIDATE_SCRIPT} — skipping pre-checks."
fi
echo ""

if [[ "${MODE}" == "switchover" ]]; then
  echo "Step 1: Initiating switchover to ${STANDBY_DB}..."
  echo "        Both databases will briefly enter mount-only state during role transition."
  "${DGMGRL}" / "switchover to ${STANDBY_DB}"

else
  # Failover requires explicit typed confirmation — "YES" in uppercase only.
  echo "WARNING: Failover is irreversible without a subsequent 'reinstate' of the"
  echo "         original primary. Data committed after the last applied redo may be lost."
  echo "         Protection mode: MAXAVAILABILITY (see oracle-data-guard role defaults)."
  echo ""
  echo "  Current primary : ${PRIMARY_DB}"
  echo "  New primary     : ${STANDBY_DB}"
  echo ""
  read -r -p "Type YES to confirm emergency failover to ${STANDBY_DB}: " confirm
  [[ "${confirm}" != "YES" ]] && { echo "Aborted."; exit 1; }

  echo ""
  echo "Step 1: Initiating failover to ${STANDBY_DB}..."
  "${DGMGRL}" / "failover to ${STANDBY_DB}"
fi

echo ""
echo "=== ${MODE^^} complete ==="
echo ""
echo "Next steps:"
echo "  1. Verify new primary health:"
echo "       bash $(dirname "$0")/validate-dr.sh ${STANDBY_DB}"
echo "  2. Update Ansible inventory — point app servers at the DR site:"
echo "       ansible/inventories/dr.yml"
echo "  3. Restart application services against the DR site:"
echo "       ansible-playbook ansible/playbooks/site/site.yml \\"
echo "         -i ansible/inventories/dr.yml --tags configure"
if [[ "${MODE}" == "failover" ]]; then
  echo "  4. Once the original primary is repaired, reinstate it and failback:"
  echo "       bash $(dirname "$0")/failback.sh \\"
  echo "         --original-primary ${PRIMARY_DB} --current-primary ${STANDBY_DB}"
fi
