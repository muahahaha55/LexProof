import LexProof.Verify.AnalyzeReport

/-!
# Concrete cases: what does the encoding say about a situation written from the law?

A **case** is one concrete situation (values of atoms, by atom code and band label), one act, the
status a reader of the clause expects, the clause it comes from and a short verbatim quote. The runner
computes the status the *encoding* gives and compares. Everything is DRAFT until a human reviews it.

The evaluator is defined **through `Norm.applies`** (`mem_applyingNorms`) and `Conflict`
(`hasClash_iff_conflict`); it re-implements no semantics.

**`noNormApplies` means only "no norm of this module applies".** It is never a claim that the act is
lawful: the module encodes a handful of clauses, and the output text says so.

**Fail closed.** A case that does not fix every atom read by the norms of the tested act is
`underspecified`, with the missing atom names; no atom ever defaults to a value. Atoms that the act's
norms do not read may be left out (they cannot change the answer, `Cond.eval_congr`). A key that matches
no atom, or a label that is not a band of the atom, is `malformed`.
-/

namespace LexProof

inductive CaseStatus
  | forbidden
  | required
  | explicitlyPermitted
  | clash
  | noNormApplies
  deriving Repr, DecidableEq

def CaseStatus.text : CaseStatus → String
  | .forbidden => "forbidden (bị cấm)"
  | .required => "required (bắt buộc)"
  | .explicitlyPermitted => "explicitlyPermitted (được phép rõ ràng)"
  | .clash => "clash (hai norm khắc nhau cùng áp dụng, chưa giải quyết)"
  | .noNormApplies => "noNormApplies (không norm nào CỦA MÔ-ĐUN NÀY áp dụng; KHÔNG có nghĩa là hợp pháp)"

inductive CaseKind
  | positive
  | negativeControl
  | boundary
  | exception
  deriving Repr, DecidableEq

inductive Confidence
  | high
  | medium
  | low
  deriving Repr, DecidableEq

structure Case where
  id : String
  description : String
  /-- (atom code or full name, band label); a `Bool` atom takes «đúng» / «sai». -/
  situation : List (String × String)
  params : List (String × String)
  act : Act
  expected : CaseStatus
  clause : String
  quote : String
  kind : CaseKind
  confidence : Confidence
  note : String := ""
  status : ReviewStatus := .draft
  deriving Repr, DecidableEq

/-! ## Reading a case against a table -/

/-- The code of an atom: its name up to the first space (`"S04 tuổi ..."` ↦ `"S04"`). -/
def atomCode (n : String) : String := String.ofList (n.toList.takeWhile (· != ' '))

def atomMatches (a : Atom) (k : String) : Bool := k == a.name || k == atomCode a.name

inductive Look
  | unset
  | bad (msg : String)
  | val (v : Nat)

def Look.isUnset : Look → Bool
  | .unset => true
  | _ => false

def lookAtom (a : Atom) (es : List (String × String)) : Look :=
  match es.find? fun e => atomMatches a e.1 with
  | none => .unset
  | some e =>
    match a.domain with
    | .bool =>
      if e.2 == "đúng" then .val 1 else if e.2 == "sai" then .val 0
      else .bad s!"giá trị «{e.2}» không hợp lệ cho atom Bool {atomCode a.name} (chỉ «đúng» hoặc «sai»)"
    | .enum bs =>
      match bs.findIdx? fun b => b.label == e.2 with
      | some i => .val i
      | none => .bad s!"«{e.2}» không phải dải nào của atom {atomCode a.name}"

/-- The first problem with the keys or labels of a case, if any. -/
def keyProblem (t : AtomTable) (es : List (String × String)) : Option String :=
  match es.find? fun e => !(t.any fun a => atomMatches a e.1) with
  | some e => some s!"khóa «{e.1}» không khớp atom nào của bảng"
  | none => (t.filterMap fun a => match lookAtom a es with | .bad m => some m | _ => none).head?

/-- The valuation a case describes; atoms it leaves out get index `0` — only sound for atoms the tested act
does not read, which `missingAtoms` checks first. -/
def buildVal (t : AtomTable) (es : List (String × String)) : Option (Valuation t) :=
  let vs := t.map fun a => match lookAtom a es with | .val v => v | _ => 0
  if h : legalVals t.sizes vs = true then some ⟨vs, h⟩ else none

/-- Names of the atoms read by the norms of the case's act that the case does not fix. -/
def missingAtoms (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) (c : Case) : List String :=
  let mine := ns.filter fun n => n.act == c.act
  let miss (t : AtomTable) (es : List (String × String)) (idx : List Nat) : List String :=
    (idx.filterMap fun i => t[i]?).filterMap fun a => if (lookAtom a es).isUnset then some a.name else none
  miss ts c.situation (readAtoms rs (mine.flatMap Norm.sitIdxs)) ++
    miss tp c.params (readAtoms rp (mine.flatMap Norm.paramIdxs))

/-! ## The evaluator, defined through `Norm.applies` and `Conflict` -/

def applyingNorms {S P : Type} (A : Atoms S P) (ns : List Norm) (act : Act) (π : P) (s : S) : List Norm :=
  ns.filter fun n => n.act == act && n.applies A π s == some true

/-- The link to `Norm.applies`, for one norm. -/
theorem mem_applyingNorms {S P : Type} {A : Atoms S P} {ns : List Norm} {act : Act} {π : P} {s : S}
    {n : Norm} : n ∈ applyingNorms A ns act π s ↔ n ∈ ns ∧ n.act = act ∧ n.applies A π s = some true := by
  simp [applyingNorms, List.mem_filter]

/-- Two applying norms with incompatible modalities and no one-sided priority. -/
def hasClash (xs : List Norm) : Bool :=
  xs.any fun n₁ => xs.any fun n₂ => Incompatible n₁.modality n₂.modality && !Norm.resolved n₁ n₂

/-- `clash` is exactly `Conflict` between two norms of the tested act. -/
theorem hasClash_iff_conflict {S P : Type} {A : Atoms S P} {ns : List Norm} {act : Act} {π : P} {s : S} :
    hasClash (applyingNorms A ns act π s) = true ↔
      ∃ n₁ ∈ ns, ∃ n₂ ∈ ns, n₁.act = act ∧ n₂.act = act ∧ Conflict A n₁ n₂ π s := by
  constructor
  · intro h
    obtain ⟨n₁, h₁, h⟩ := List.any_eq_true.1 h
    obtain ⟨n₂, h₂, h⟩ := List.any_eq_true.1 h
    obtain ⟨m₁, a₁, p₁⟩ := mem_applyingNorms.1 h₁
    obtain ⟨m₂, a₂, p₂⟩ := mem_applyingNorms.1 h₂
    simp only [Bool.and_eq_true, Bool.not_eq_true'] at h
    exact ⟨n₁, m₁, n₂, m₂, a₁, a₂, ⟨a₁.trans a₂.symm, p₁, p₂, h.1, h.2⟩⟩
  · rintro ⟨n₁, m₁, n₂, m₂, a₁, a₂, hc⟩
    refine List.any_eq_true.2 ⟨n₁, mem_applyingNorms.2 ⟨m₁, a₁, hc.2.1⟩,
      List.any_eq_true.2 ⟨n₂, mem_applyingNorms.2 ⟨m₂, a₂, hc.2.2.1⟩, ?_⟩⟩
    simp [hc.2.2.2.1, hc.2.2.2.2]

/-- Ids of norms that lose a one-sided priority against another applying norm. -/
def loserIds (xs : List Norm) : List NormId :=
  xs.flatMap fun n₁ => xs.filterMap fun n₂ =>
    if Incompatible n₁.modality n₂.modality && Norm.resolved n₁ n₂ && Norm.winner? n₁ n₂ == some n₁.id
    then some n₂.id else none

def statusOfApplying (xs : List Norm) : CaseStatus :=
  if xs.isEmpty then .noNormApplies
  else if hasClash xs then .clash
  else
    let eff := xs.filter fun n => !(loserIds xs).contains n.id
    if eff.any fun n => n.modality == .prohibition then .forbidden
    else if eff.any fun n => n.modality == .obligation then .required
    else if eff.any fun n => n.modality == .permission then .explicitlyPermitted
    else .noNormApplies

/-! ## The runner -/

inductive CaseOutcome
  | pass
  | fail (got : CaseStatus)
  | underspecified (missing : List String)
  | malformed (why : String)
  deriving Repr, DecidableEq

structure CaseResult where
  id : String
  outcome : CaseOutcome
  applying : List NormId
  deriving Repr, DecidableEq

def runCase (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) (c : Case) : CaseResult :=
  match keyProblem ts c.situation, keyProblem tp c.params with
  | some why, _ => ⟨c.id, .malformed why, []⟩
  | none, some why => ⟨c.id, .malformed why, []⟩
  | none, none =>
    if (missingAtoms ts tp rs rp ns c).isEmpty then
      match buildVal ts c.situation, buildVal tp c.params with
      | some s, some π =>
        let xs := applyingNorms (atomsOf ts tp rs rp) ns c.act π s
        let got := statusOfApplying xs
        ⟨c.id, if got == c.expected then .pass else .fail got, xs.map fun n => n.id⟩
      | _, _ => ⟨c.id, .malformed "tổ hợp giá trị không hợp lệ (miền rỗng?)", []⟩
    else ⟨c.id, .underspecified (missingAtoms ts tp rs rp ns c), []⟩

/-- A passing case really has the expected status, computed from `Norm.applies`, with every atom of the
tested act fixed by the case. -/
theorem runCase_pass_sound (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) (c : Case)
    (h : (runCase ts tp rs rp ns c).outcome = .pass) :
    missingAtoms ts tp rs rp ns c = [] ∧
    ∃ (π : Valuation tp) (s : Valuation ts), buildVal ts c.situation = some s ∧ buildVal tp c.params = some π ∧
      statusOfApplying (applyingNorms (atomsOf ts tp rs rp) ns c.act π s) = c.expected := by
  unfold runCase at h
  split at h
  · simp at h
  · simp at h
  · by_cases hm : (missingAtoms ts tp rs rp ns c).isEmpty = true
    · simp only [hm, ite_true] at h
      cases hs : buildVal ts c.situation with
      | none => simp [hs] at h
      | some s =>
        cases hπ : buildVal tp c.params with
        | none => simp [hs, hπ] at h
        | some π =>
          simp only [hs, hπ] at h
          refine ⟨by simpa using hm, π, s, rfl, rfl, ?_⟩
          by_cases hg : (statusOfApplying (applyingNorms (atomsOf ts tp rs rp) ns c.act π s) == c.expected) = true
          · simpa using hg
          · simp [hg] at h
    · simp [hm] at h

def passIds (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) (cs : List Case) : List String :=
  (cs.map (runCase ts tp rs rp ns)).filterMap fun r =>
    match r.outcome with
    | .pass => some r.id
    | _ => none

def CaseOutcome.text : CaseOutcome → String
  | .pass => "PASS"
  | .fail g => s!"FAIL — mô-đun cho {g.text}"
  | .underspecified m => s!"UNDERSPECIFIED — thiếu atom: {", ".intercalate m}"
  | .malformed w => s!"MALFORMED — {w}"

def CaseResult.line (r : CaseResult) : String :=
  s!"{r.id} | {r.outcome.text} | norm áp dụng: {", ".intercalate r.applying}"

/-- Runtime listing of every case that is not a pass, in the order of the list. -/
def notPassing (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) (cs : List Case) :
    List CaseResult :=
  (cs.map (runCase ts tp rs rp ns)).filter fun r => r.outcome != .pass

/-! ## Non-vacuity (a three-atom toy module) -/

private def exT : AtomTable :=
  [⟨"A1 một", .bool, "Điều 1"⟩, ⟨"B2 hai", .enum [⟨"x", "Điều 1"⟩, ⟨"y", "Điều 1"⟩], "Điều 1"⟩,
   ⟨"C3 ba", .bool, "Điều 1"⟩]
private def exRS : List ReaderSpec := [("A1", 0, 1), ("B2=y", 1, 1)]
private def exN (m : Modality) (id : String) (c : Cond) : Norm :=
  { id := id, modality := m, act := "a", condition := c, exceptions := [], priority := none
  , source := { docId := "EX", docType := .law, effective := ⟨2020, 1, 1⟩, article := "Điều 1" }
  , references := [] }
private def exNs : List Norm := [exN .prohibition "p" (.and (.sit 0) (.sit 1))]
private def exC (s : List (String × String)) (e : CaseStatus) : Case :=
  { id := "t", description := "", situation := s, params := [], act := "a", expected := e, clause := "",
    quote := "", kind := .positive, confidence := .high }

example : (runCase exT [] exRS [] exNs (exC [("A1", "đúng"), ("B2", "y")] .forbidden)).outcome = .pass := by
  decide +kernel

example : (runCase exT [] exRS [] exNs (exC [("A1", "đúng"), ("B2", "x")] .noNormApplies)).outcome = .pass := by
  decide +kernel

/-- Fail closed: `B2` is not fixed, so the case is underspecified, not defaulted. `C3` is not read: no complaint. -/
example : (runCase exT [] exRS [] exNs (exC [("A1", "đúng")] .forbidden)).outcome =
    .underspecified ["B2 hai"] := by decide +kernel

example : (runCase exT [] exRS [] exNs (exC [("A1", "đúng"), ("B2", "z")] .forbidden)).outcome =
    .malformed "«z» không phải dải nào của atom B2" := by decide +kernel

example : (runCase exT [] exRS [] exNs (exC [("A1", "sai"), ("B2", "y")] .forbidden)).outcome =
    .fail .noNormApplies := by decide +kernel

end LexProof
