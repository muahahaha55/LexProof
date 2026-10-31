import LexProof.Core.ClauseRef
import LexProof.Laws.AlcoholSaleBands

/-!
# DRAFT, NOT HUMAN-REVIEWED — structured references used by `Laws/AlcoholSale.lean`

Every reference string used in the module (norm sources, `catalog`, case clauses, `notEncoded`) is parsed
into a `ClauseRef`. Findings are listed, not hidden. `runCaseRefScoped` decides a case's scope from the
references only (no override table), and `render_parse_allRefs` is a kernel check that rendering then
parsing is the identity on every reference value that appears here. It is a check over those values, not a
general theorem about all references.

**Scope rule** (a design decision of this file, not a reading of the law):

1. A heading entry or heading citation never moves a case out of scope: the heading lends its modality and
   act to the clauses below it (G1), so a case about it is judged through them.
2. A not-encoded entry that is the cited reference or an ancestor of it ⇒ `outOfScope`.
3. A not-encoded entry that is a descendant of the cited reference ⇒ the clause is only partly encoded. The
   case is in scope only if some encoded norm with the **same act** cites a related reference; otherwise
   `outOfScope`.
4. Otherwise the result is exactly `runCase`'s.

`outOfScope` is not a pass and says nothing about the law.
-/

namespace LexProof.Laws.AlcoholSaleRefs

open LexProof LexProof.Laws.AlcoholSale LexProof.Laws.AlcoholSaleCases

inductive RefScoped
  | ran (o : CaseOutcome)
  | outOfScope (entry : String)
  | badRef (why : String)
  deriving Repr, DecidableEq

/-- Not-encoded entries as references, each with the entry's own spelling. Unparsable entries are findings. -/
def refEntries (ne : List NotEncoded) : List (ClauseRef × String) :=
  ne.flatMap fun e => match parseEntry e.clause with
    | .ok rs => rs.map fun r => (r, e.clause)
    | .error _ => []

private def related (a b : ClauseRef) : Bool := a == b || a.isAncestorOf b || b.isAncestorOf a

def runCaseRefScoped (ne : List (ClauseRef × String)) (ts tp : AtomTable) (rs rp : List ReaderSpec)
    (ns : List Norm) (c : Case) : RefScoped :=
  match parseRef c.clause with
  | .error why => .badRef why
  | .ok r =>
    let run := RefScoped.ran (runCase ts tp rs rp ns c).outcome
    if r.part == .heading then run
    else
      match ne.find? fun e => e.1.part == .body && (e.1 == r || e.1.isAncestorOf r) with
      | some e => .outOfScope e.2
      | none =>
        match ne.find? fun e => e.1.part == .body && r.isAncestorOf e.1 with
        | none => run
        | some e =>
          let served := ns.any fun n => n.act == c.act &&
            match parseRef n.source.article with
            | .ok s => related r s
            | .error _ => false
          if served then run else .outOfScope e.2

/-- Rule 1. -/
theorem runCaseRefScoped_heading {ne : List (ClauseRef × String)} {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {ns : List Norm} {c : Case} {r : ClauseRef} (h : parseRef c.clause = .ok r) (hh : r.part = .heading) :
    runCaseRefScoped ne ts tp rs rp ns c = .ran (runCase ts tp rs rp ns c).outcome := by
  simp [runCaseRefScoped, h, hh]

/-- Rule 2. -/
theorem runCaseRefScoped_covered {ne : List (ClauseRef × String)} {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {ns : List Norm} {c : Case} {r : ClauseRef} (h : parseRef c.clause = .ok r) (hb : r.part = .body)
    {e : ClauseRef × String} (he : e ∈ ne) (hp : e.1.part = .body) (hc : e.1 = r ∨ e.1.isAncestorOf r = true) :
    ∃ name, runCaseRefScoped ne ts tp rs rp ns c = .outOfScope name := by
  have hs : (ne.find? fun e => e.1.part == .body && (e.1 == r || e.1.isAncestorOf r)).isSome = true := by
    apply List.find?_isSome.2
    refine ⟨e, he, ?_⟩
    rcases hc with hc | hc <;> simp [hp, hc, hb]
  cases hf : ne.find? fun e => e.1.part == .body && (e.1 == r || e.1.isAncestorOf r) with
  | none => rw [hf] at hs; simp at hs
  | some e' => exact ⟨e'.2, by simp [runCaseRefScoped, h, hb, hf]⟩

/-- An out-of-scope case is not a pass. -/
theorem RefScoped.outOfScope_ne_ran (n : String) (o : CaseOutcome) : RefScoped.outOfScope n ≠ .ran o := by
  intro h; cases h

/-! ## What the module cites -/

def catalogNums : List (Option Nat) := catalog.map fun s => (parseRef s).toOption.map (·.article)

/-- (origin, string) for every reference string used in the module. -/
def usedStrings : List (String × String) :=
  norms.map (fun n => ("norm " ++ n.id, n.source.article)) ++
  cases.map (fun c => ("ca " ++ c.id, c.clause)) ++
  notEncoded.map (fun e => ("notEncoded", e.clause)) ++
  catalog.map (fun s => ("catalog", s))

def unparsable : List String :=
  usedStrings.filterMap fun (o, s) => match parseEntry s with | .error m => some s!"{o}: {m}" | .ok _ => none

def refsOf (s : String) : List ClauseRef := match parseEntry s with | .ok rs => rs | .error _ => []

/-- Every reference value that appears in the module. -/
def allRefs : List ClauseRef := (usedStrings.flatMap fun (_, s) => refsOf s).eraseDups

theorem render_parse_allRefs : allRefs.all (fun r => (parseRef r.render).toOption == some r) = true := by
  decide +kernel

/-- Pairs of different strings that normalise to the same reference. -/
def sameRef : List (String × String) :=
  let ss := (usedStrings.map (·.2)).eraseDups
  (ss.flatMap fun a => ss.filterMap fun b => if a < b && !(refsOf a).isEmpty && refsOf a == refsOf b then some (a, b) else none)

/-- Cited references (norm sources and case clauses) that have a not-encoded descendant. -/
def partlyOutOfScope : List String :=
  let es := refEntries notEncoded
  (usedStrings.filter fun (o, _) => o.startsWith "norm " || o.startsWith "ca ").filterMap fun (o, s) =>
    match parseRef s with
    | .ok r => (es.find? fun e => e.1.part == .body && r.isAncestorOf e.1).map fun e => s!"{o}: «{s}» ⊃ «{e.2}»"
    | .error _ => none

/-- Cited references whose article is not in `catalog`. -/
def notInCatalog : List String :=
  (usedStrings.filter fun (o, _) => o != "catalog").filterMap fun (o, s) =>
    (refsOf s).filterMap (fun r => if catalogNums.contains (some r.article) then none else some s!"{o}: «{s}»") |>.head?

def findings : List String :=
  unparsable.map ("không phân tích được — " ++ ·) ++
  sameRef.map (fun (a, b) => s!"hai chuỗi khác nhau cùng một tham chiếu: «{a}» và «{b}»") ++
  partlyOutOfScope.map ("một phần ngoài phạm vi — " ++ ·) ++
  notInCatalog.map ("không có trong catalog — " ++ ·)

def refScoped : List (String × RefScoped) :=
  cases.map fun c => (c.id, runCaseRefScoped (refEntries notEncoded) tS tP rS rP norms c)

def refOutOfScopeIds : List String := (refScoped.filter fun (_, r) => match r with | .outOfScope _ => true | _ => false).map (·.1)

def refPassIds : List String := (refScoped.filter fun (_, r) => r == .ran .pass).map (·.1)

/-! ## What the kernel records (the current state, not a claim about the law) -/

theorem unparsable_none : unparsable = [] := by decide +kernel
theorem notInCatalog_none : notInCatalog = [] := by decide +kernel
/-- C37 cites the heading «Điều 19 (tiêu đề)»; the not-encoded list spells it «Điều 19 tiêu đề». -/
theorem sameRef_c37 : sameRef = [("Điều 19 (tiêu đề)", "Điều 19 tiêu đề")] := by decide +kernel
/-- C24 is out of scope because khoản 11 has the not-encoded branch (i) and no encoded norm of its act cites it.
C23 is out of scope for the same reason (act `ban_ruou_bia`): references and acts cannot tell whether C23's
situation falls under branch (i). C22 stays in scope: norm 5.11-ii has its act. -/
theorem refOutOfScope_set : refOutOfScopeIds = ["C23", "C24"] := by decide +kernel
theorem ref_c37_in_scope : refScoped.lookup "C37" = some (.ran .pass) := by decide +kernel
theorem ref_c22_in_scope : refScoped.lookup "C22" = some (.ran .pass) := by decide +kernel

end LexProof.Laws.AlcoholSaleRefs
