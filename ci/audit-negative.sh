#!/usr/bin/env bash
# Negative test for the axiom audit (R15).
#
# Runs a file that deliberately uses `sorry`, `native_decide` and a declared
# `axiom`, and requires the audit to reject all three. The file is outside the
# library, so a plain `lake build` never sees it.
#
# Exits non-zero if the audit accepts the file, or if any of the three
# rejections is missing from its output.
set -uo pipefail

target="ci/audit-negative/BadAxioms.lean"

echo "== running the audit against $target (it must FAIL) =="
output="$(lake env lean "$target" 2>&1)"
status=$?
echo "$output"
echo "== audit exit status: $status =="

if [ "$status" -eq 0 ]; then
  echo "NEGATIVE TEST FAILED: the audit accepted a file with sorry, native_decide and an axiom."
  exit 1
fi

fail=0
check() {
  if echo "$output" | grep -qF "$1"; then
    echo "  ok: rejected -- $2"
  else
    echo "  MISSING: $2  (expected to find: $1)"
    fail=1
  fi
}

check "badAxiom is a declared axiom"   "a hand-declared axiom"
check "badSorry depends on [sorryAx]"  "sorry"
check "native_decide.ax"               "the per-theorem native_decide axiom"

if [ "$fail" -ne 0 ]; then
  echo "NEGATIVE TEST FAILED: the audit did not reject all three cases."
  exit 1
fi

echo "NEGATIVE TEST PASSED: the audit rejected all three cases."
