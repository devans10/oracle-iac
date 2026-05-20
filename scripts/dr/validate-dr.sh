#!/usr/bin/env bash
set -euo pipefail

# Validates Oracle Data Guard standby readiness before DR activation.
# Runs dgmgrl checks against the standby database using OS authentication.
#
# Usage: validate-dr.sh [standby_db_name] [standby_db_host]
#   standby_db_name  DG database name for the standby (default: CCB_DR — matches
#                    dg_standby_db in oracle-data-guard role defaults)
#   standby_db_host  SCAN listener hostname to probe (default: dr-rac-scan.company.internal)
#
# Exit 0 = all checks passed (ready for activation)
# Exit 1 = one or more checks failed (do NOT activate)
#
# Apply-lag warnings are non-fatal — operator must decide acceptability.
# Run as the oracle OS user; dgmgrl uses OS (/) authentication.
# No passwords are passed on the command line or written to disk.
#
# dgmgrl binary path mirrors the oracle-data-guard role default:
#   {{ oracle_base }}/products/db_client/bin/dgmgrl
# Override via ORACLE_BASE or DGMGRL_BIN environment variables.

STANDBY_DB="${1:-CCB_DR}"
STANDBY_HOST="${2:-dr-rac-scan.company.internal}"
ORACLE_BASE="${ORACLE_BASE:-/u01/oracle}"
DGMGRL="${DGMGRL_BIN:-${ORACLE_BASE}/products/db_client/bin/dgmgrl}"

PASS=0
FAIL=0

check() {
  local label="$1"; shift
  if "$@" &>/dev/null; then
    echo "  PASS  ${label}"
    ((PASS++))
  else
    echo "  FAIL  ${label}"
    ((FAIL++))
  fi
}

echo "=== Data Guard DR Validation: ${STANDBY_DB} ==="
echo "    dgmgrl  : ${DGMGRL}"
echo "    standby : ${STANDBY_DB} @ ${STANDBY_HOST}"
echo ""

# Pre-flight: dgmgrl must exist and be executable.
if [[ ! -x "${DGMGRL}" ]]; then
  echo "ERROR: dgmgrl not found or not executable at ${DGMGRL}"
  echo "       Set ORACLE_BASE or DGMGRL_BIN to the correct DB client home."
  exit 1
fi

# 1. Standby SCAN listener reachable on port 1521
check "Standby listener reachable (${STANDBY_HOST}:1521)" \
  bash -c "echo '' | nc -w 5 ${STANDBY_HOST} 1521"

# 2. dgmgrl can connect (OS auth) and the overall configuration reports SUCCESS
DG_STATUS=$("${DGMGRL}" -silent / "show configuration" 2>&1 || true)
if echo "${DG_STATUS}" | grep -q "SUCCESS"; then
  echo "  PASS  Data Guard configuration status: SUCCESS"
  ((PASS++))
else
  STATUS_LINE=$(echo "${DG_STATUS}" | grep -iE 'status|error|warning|ORA-' | head -1 \
    || echo "no status line found")
  echo "  FAIL  Data Guard configuration status (got: ${STATUS_LINE})"
  ((FAIL++))
fi

# 3. Standby database is present in DG config and is a physical standby
DB_INFO=$("${DGMGRL}" -silent / "show database verbose ${STANDBY_DB}" 2>&1 || true)
if echo "${DB_INFO}" | grep -qi "Physical standby\|Logical standby\|Snapshot standby"; then
  echo "  PASS  Standby database ${STANDBY_DB} present in DG configuration"
  ((PASS++))
else
  echo "  FAIL  Standby database ${STANDBY_DB} not found or wrong type in DG config"
  ((FAIL++))
fi

# 4. MRP (managed recovery process) / apply instance is active
MRP_STATUS=$(echo "${DB_INFO}" | grep -i "apply instance\|mrp" | head -1 || echo "")
if [[ -n "${MRP_STATUS}" ]]; then
  echo "  PASS  MRP / apply instance present: ${MRP_STATUS}"
  ((PASS++))
else
  echo "  FAIL  MRP / apply instance not detected — redo apply may not be running"
  ((FAIL++))
fi

# 5. Apply lag within acceptable threshold (warn only — operator decides)
# dgmgrl reports lag as "+DD HH:MM:SS"; lag under 10 minutes starts "+00 00:0"
APPLY_LAG=$(echo "${DB_INFO}" | grep -i "apply lag" | awk '{print $NF}' || echo "unknown")
echo "  INFO  Apply lag: ${APPLY_LAG}"
if [[ "${APPLY_LAG}" == "+00 00:0"* ]] || \
   [[ "${APPLY_LAG}" == "0 seconds" ]]   || \
   [[ "${APPLY_LAG}" == "unknown" ]]; then
  echo "  PASS  Apply lag within threshold (or unavailable — verify manually)"
  ((PASS++))
else
  # Elevated lag does not hard-fail; operator decides whether RPO is acceptable.
  echo "  WARN  Apply lag may be elevated: ${APPLY_LAG} — investigate before activating"
  ((PASS++))
fi

# 6. Idempotency check — confirm standby is not already PRIMARY
CURRENT_ROLE=$(echo "${DB_INFO}" | grep -i "^  Role:" | awk '{print $NF}' || echo "unknown")
echo "  INFO  Current role of ${STANDBY_DB}: ${CURRENT_ROLE}"
if echo "${CURRENT_ROLE}" | grep -qi "primary"; then
  echo "  WARN  ${STANDBY_DB} reports role=PRIMARY — DR may already be active"
fi

echo ""
echo "=== Result: ${PASS} passed, ${FAIL} failed ==="

if [[ ${FAIL} -gt 0 ]]; then
  echo "DR readiness check FAILED — resolve failures before activating."
  exit 1
fi

echo "Standby ${STANDBY_DB} is ready for DR activation."
exit 0
