import LexProof.Verify.Cases

/-!
# Scoped cases: «no norm applies» versus «the clause is not encoded»

`runCase` answers `noNormApplies` both when the clause is encoded and its condition is false, and when the
clause is not encoded at all (case C24). `runCaseScoped` separates them. It takes the module's list of
clauses it does **not** encode. If the case's source clause is in that list the result is
`outOfScope clause`, never a pass and never a fail; otherwise the result is exactly `runCase`'s.

`outOfScope` says nothing about the law. A clause that is in neither the encoded norms nor the not-encoded
list is a finding (`unmentionedKeys`): the module does not say what it does with that clause.

The clause of a case is read through `keyOf` because `Case.clause` can be coarser than the entries of the
not-encoded list (a whole «khoản» against one «nhánh»); the module supplies the finer key, in the open.
-/

namespace LexProof

inductive ScopedOutcome
  | ran (o : CaseOutcome)
  | outOfScope (clause : String)
  deriving Repr, DecidableEq

structure ScopedResult where
  id : String
  outcome : ScopedOutcome
  applying : List NormId
  deriving Repr, DecidableEq

/-- The entry of the not-encoded list equal to the key, if any. -/
def listedAs (ne : List String) (k : String) : Option String := ne.find? (· == k)

def runCaseScoped (ne : List String) (keyOf : Case → String) (ts tp : AtomTable) (rs rp : List ReaderSpec)
    (ns : List Norm) (c : Case) : ScopedResult :=
  match listedAs ne (keyOf c) with
  | some k => ⟨c.id, .outOfScope k, []⟩
  | none => ⟨c.id, .ran (runCase ts tp rs rp ns c).outcome, (runCase ts tp rs rp ns c).applying⟩

/-- Half 1: a case whose clause is listed as not encoded is `outOfScope`, whatever `runCase` says. -/
theorem runCaseScoped_outOfScope {ne : List String} {keyOf : Case → String} {ts tp : AtomTable}
    {rs rp : List ReaderSpec} {ns : List Norm} {c : Case} {k : String}
    (h : listedAs ne (keyOf c) = some k) :
    (runCaseScoped ne keyOf ts tp rs rp ns c).outcome = .outOfScope k := by
  simp [runCaseScoped, h]

/-- Half 2: otherwise the result is exactly `runCase`'s outcome. -/
theorem runCaseScoped_ran {ne : List String} {keyOf : Case → String} {ts tp : AtomTable}
    {rs rp : List ReaderSpec} {ns : List Norm} {c : Case} (h : listedAs ne (keyOf c) = none) :
    (runCaseScoped ne keyOf ts tp rs rp ns c).outcome = .ran (runCase ts tp rs rp ns c).outcome := by
  simp [runCaseScoped, h]

/-- An out-of-scope case is not a pass. -/
theorem outOfScope_not_pass {ne : List String} {keyOf : Case → String} {ts tp : AtomTable}
    {rs rp : List ReaderSpec} {ns : List Norm} {c : Case} {k : String}
    (h : listedAs ne (keyOf c) = some k) :
    (runCaseScoped ne keyOf ts tp rs rp ns c).outcome ≠ .ran .pass := by
  rw [runCaseScoped_outOfScope h]; intro e; cases e

/-- Only a case that is in scope can pass. -/
theorem scoped_pass_iff {ne : List String} {keyOf : Case → String} {ts tp : AtomTable}
    {rs rp : List ReaderSpec} {ns : List Norm} {c : Case} :
    (runCaseScoped ne keyOf ts tp rs rp ns c).outcome = .ran .pass ↔
      listedAs ne (keyOf c) = none ∧ (runCase ts tp rs rp ns c).outcome = .pass := by
  constructor
  · intro h
    cases hl : listedAs ne (keyOf c) with
    | some k => exact absurd h (outOfScope_not_pass hl)
    | none => rw [runCaseScoped_ran hl] at h; exact ⟨rfl, ScopedOutcome.ran.inj h⟩
  · rintro ⟨hl, h⟩; rw [runCaseScoped_ran hl, h]

/-- Keys of cases that appear neither as the article of an encoded norm nor in the not-encoded list. -/
def unmentionedKeys (ne : List String) (keyOf : Case → String) (ns : List Norm) (cs : List Case) :
    List String :=
  (cs.map keyOf).filter (fun k => !(ne.contains k) && !(ns.any fun n => n.source.article == k)) |>.eraseDups

def ScopedOutcome.text : ScopedOutcome → String
  | .ran o => o.text
  | .outOfScope k => s!"OUT OF SCOPE — điều khoản «{k}» KHÔNG được mã hóa; kết quả này không nói gì về luật, và không phải PASS"

def ScopedResult.line (r : ScopedResult) : String :=
  s!"{r.id} | {r.outcome.text} | norm áp dụng: {", ".intercalate r.applying}"

/-- Ids of the cases that are out of scope, listed apart from passes and failures. -/
def outOfScopeIds (ne : List String) (keyOf : Case → String) (ts tp : AtomTable) (rs rp : List ReaderSpec)
    (ns : List Norm) (cs : List Case) : List String :=
  (cs.map (runCaseScoped ne keyOf ts tp rs rp ns)).filterMap fun r =>
    match r.outcome with
    | .outOfScope _ => some r.id
    | _ => none

def scopedPassIds (ne : List String) (keyOf : Case → String) (ts tp : AtomTable) (rs rp : List ReaderSpec)
    (ns : List Norm) (cs : List Case) : List String :=
  (cs.map (runCaseScoped ne keyOf ts tp rs rp ns)).filterMap fun r =>
    match r.outcome with
    | .ran .pass => some r.id
    | _ => none

/-- The module-level text. Out-of-scope cases come after, apart, with their warning. -/
def scopedReport (ne : List String) (keyOf : Case → String) (ts tp : AtomTable) (rs rp : List ReaderSpec)
    (ns : List Norm) (cs : List Case) : String :=
  let rs' := cs.map (runCaseScoped ne keyOf ts tp rs rp ns)
  let inScope := rs'.filter fun r => match r.outcome with | .outOfScope _ => false | _ => true
  let outs := rs'.filter fun r => match r.outcome with | .outOfScope _ => true | _ => false
  let un := unmentionedKeys ne keyOf ns cs
  "\n".intercalate (
    [s!"ca trong phạm vi mã hóa: {inScope.length}; OUT OF SCOPE: {outs.length}"] ++
    inScope.map ScopedResult.line ++
    [s!"--- {outs.length} ca OUT OF SCOPE: điều khoản không được mã hóa; các ca này không nói gì về luật, không phải PASS ---"] ++
    outs.map ScopedResult.line ++
    (un.map fun k => s!"FINDING: điều khoản «{k}» không có trong norm đã mã hóa lẫn danh sách notEncoded"))

/-! ## Non-vacuity on the toy module of `Cases.lean` -/

private def exT : AtomTable := [⟨"A1 một", .bool, "Điều 1"⟩]
private def exN : Norm :=
  { id := "p", modality := .prohibition, act := "a", condition := .sit 0, exceptions := [], priority := none
  , source := { docId := "EX", docType := .law, effective := ⟨2020, 1, 1⟩, article := "Điều 1" }
  , references := [] }
private def exC (cl : String) : Case :=
  { id := "t", description := "", situation := [("A1", "sai")], params := [], act := "a",
    expected := .noNormApplies, clause := cl, quote := "", kind := .positive, confidence := .high }

example : (runCaseScoped ["Điều 2"] (·.clause) exT [] [("A1", 0, 1)] [] [exN] (exC "Điều 2")).outcome =
    .outOfScope "Điều 2" := by decide +kernel

example : (runCaseScoped ["Điều 2"] (·.clause) exT [] [("A1", 0, 1)] [] [exN] (exC "Điều 1")).outcome =
    .ran .pass := by decide +kernel

example : unmentionedKeys ["Điều 2"] (·.clause) [exN] [exC "Điều 3", exC "Điều 1", exC "Điều 2"] = ["Điều 3"] := by
  decide +kernel

end LexProof
