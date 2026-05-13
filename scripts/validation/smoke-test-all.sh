#!/bin/bash
# smoke-test-all.sh — Post-install validation
# Usage: smoke-test-all.sh <environment>
set -euo pipefail
ENV="${1:-primary}"
PASS=0; FAIL=0

check() {
  local name="$1"; local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    echo "  ✓ $name"; ((PASS++))
  else
    echo "  ✗ $name (FAILED)"; ((FAIL++))
  fi
}

echo "=== Smoke Tests: $ENV ==="
echo ""
echo "--- CC&B ---"
check "CCB Web cluster HTTP 200"   "curl -sf -o /dev/null -w '%{http_code}' https://ccb.company.com/ouaf/ | grep -q 200"
check "CCB IWS WSDL reachable"     "curl -sf -o /dev/null https://ccb.company.com/ccb-iws/webservices?WSDL"
echo ""
echo "--- MDM ---"
check "MDM Web cluster HTTP 200"   "curl -sf -o /dev/null -w '%{http_code}' https://mdm.company.com/ouaf/ | grep -q 200"
echo ""
echo "--- SOA ---"
check "SOA-INT composite console"  "curl -sf -o /dev/null https://soa-int.company.internal:8002/soa-infra"
check "SOA-SGG composite console"  "curl -sf -o /dev/null https://soa-sgg.company.internal:8032/soa-infra"
echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
