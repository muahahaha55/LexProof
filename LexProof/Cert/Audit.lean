import Lean
import LexProof.Verify.Tests

/-!
# Build-time audits

Two checks that run as part of a plain `lake build`, because `LexProof.lean`
imports this module. Both **fail the build** rather than print a warning.

1. `#audit_axioms` — every declaration of every `LexProof.*` module may depend
   only on `{propext, Classical.choice, Quot.sound}`. Anything else is rejected:
   `sorryAx`, the per-theorem axioms `native_decide` and `bv_decide` generate,
   and any `axiom` declared in our own modules.
2. `#audit_encapsulation` — nothing outside `LexProof.Verify.{Conflict,Tests,
   Smoke}` may mention a `LexProof.Internal.*` constant, so no caller can reach
   the search and skip validation.

Both derive their list of declarations **from the environment**, so there is no
hand-written name list that can rot: a new module or theorem is covered the
moment it is added.

Neither check trusts names. The axiom audit compares the *set* of collected
axioms against the whitelist; it never pattern-matches on axiom names, which
matters because the axiom `native_decide` generates is named after the theorem
it came from, not after any fixed prefix.
-/

open Lean Elab Command

namespace LexProof.Cert

/-- The only axioms a LexProof declaration may rest on. -/
def allowedAxioms : List Name := [``propext, ``Classical.choice, ``Quot.sound]

/-- Modules the audits cover: everything under `LexProof`. -/
def isAuditedModule (m : Name) : Bool :=
  m == `LexProof || (`LexProof).isPrefixOf m

/-- Modules allowed to mention `LexProof.Internal.*`. -/
def internalCallers : List Name :=
  [`LexProof.Verify.Conflict, `LexProof.Verify.Tests, `LexProof.Verify.Smoke]

/-- Every declaration to audit: all declarations of the imported `LexProof.*`
modules, plus everything declared in the file being elaborated (those have no
module index yet). Read off the environment, never a written list. -/
def auditedDecls (env : Environment) : Array (Name × Option Name) := Id.run do
  let hdr := env.header
  let mut out : Array (Name × Option Name) := #[]
  for i in [0 : hdr.moduleNames.size] do
    let m := hdr.moduleNames[i]!
    if isAuditedModule m then
      for d in hdr.moduleData[i]!.constNames do
        out := out.push (d, some m)
  for (d, _) in env.constants.map₂.toList do
    out := out.push (d, none)
  return out

/-! ## 1. Axiom audit -/

elab "#audit_axioms" : command => do
  let env ← getEnv
  let decls := auditedDecls env
  let mut failures : Array MessageData := #[]
  for (d, _) in decls do
    -- An `axiom` declared in our own modules is itself a violation, whatever
    -- it is called.
    if let some (.axiomInfo _) := env.find? d then
      unless allowedAxioms.contains d do
        failures := failures.push m!"  {d} is a declared axiom"
        continue
    let used ← collectAxioms d
    let bad := used.filter fun a => !(allowedAxioms.contains a)
    unless bad.isEmpty do
      failures := failures.push m!"  {d} depends on {bad.toList}"
  if failures.isEmpty then
    logInfo m!"axiom audit: {decls.size} declarations, all within {allowedAxioms}"
  else
    throwError m!"axiom audit FAILED ({failures.size} declaration(s)):\n{
      MessageData.joinSep failures.toList "\n"}"

/-! ## 2. Encapsulation audit -/

/-- Constants a declaration mentions, in its type and in its value. -/
def mentionedConstants (env : Environment) (d : Name) : Array Name :=
  match env.find? d with
  | none => #[]
  | some ci =>
    let fromType := ci.type.getUsedConstants
    match ci.value? with
    | none => fromType
    | some v => fromType ++ v.getUsedConstants

elab "#audit_encapsulation" : command => do
  let env ← getEnv
  let mut failures : Array MessageData := #[]
  for (d, m?) in auditedDecls env do
    -- The Internal namespace may of course mention itself.
    if (`LexProof.Internal).isPrefixOf d then continue
    match m? with
    | some m => if internalCallers.contains m then continue
    | none => pure ()
    let leaks := (mentionedConstants env d).filter fun c =>
      (`LexProof.Internal).isPrefixOf c
    unless leaks.isEmpty do
      failures := failures.push m!"  {d} mentions {leaks.toList}"
  if failures.isEmpty then
    logInfo m!"encapsulation audit: no LexProof.Internal use outside {internalCallers}"
  else
    throwError m!"encapsulation audit FAILED ({failures.size} declaration(s)):\n{
      MessageData.joinSep failures.toList "\n"}"

end LexProof.Cert

#audit_axioms
#audit_encapsulation
