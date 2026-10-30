#!/usr/bin/env bash
# Coverage check for the build-time audits (D44).
#
# The audits in LexProof/Cert/Audit.lean only see modules that Audit.lean
# imports. This script fails if any .lean file under LexProof/ (other than
# Cert/Audit.lean itself) is not imported by it. Needs no Lean toolchain.
set -uo pipefail

audit="LexProof/Cert/Audit.lean"
missing=0
total=0

while IFS= read -r f; do
  [ "$f" = "$audit" ] && continue
  total=$((total + 1))
  mod="${f%.lean}"
  mod="${mod//\//.}"
  if ! grep -qE "^import[[:space:]]+${mod//./\.}[[:space:]]*$" "$audit"; then
    echo "NOT AUDITED: $f  (add 'import $mod' to $audit)"
    missing=$((missing + 1))
  fi
done < <(find LexProof -name '*.lean' | sort)

if [ "$missing" -ne 0 ]; then
  echo "AUDIT COVERAGE FAILED: $missing of $total module(s) are not imported by $audit."
  exit 1
fi
echo "AUDIT COVERAGE OK: all $total modules under LexProof/ are imported by $audit."
