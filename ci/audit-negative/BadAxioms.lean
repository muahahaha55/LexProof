import LexProof.Cert.Audit

/-!
# Negative test for the axiom audit — NOT part of the library

This file lives outside `LexProof/`, so `lake build` never compiles it and the
library stays clean. CI runs it on purpose and **expects it to fail**: if the
audit ever accepts these three declarations, the audit itself is broken.

The three cases are the ones the policy exists for:
`sorry`, `native_decide`, and a hand-declared `axiom`.
-/

namespace LexProof.AuditNegative

axiom badAxiom : (1 : Nat) = 2

theorem badSorry : (1 : Nat) = 1 := by sorry

theorem badNativeDecide : (List.range 5).length = 5 := by native_decide

end LexProof.AuditNegative

#audit_axioms
