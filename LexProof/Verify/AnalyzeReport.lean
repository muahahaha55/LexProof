import LexProof.Verify.AnalyzeProjected

/-!
# `analyzeReport` — `analyzeP` plus the context that stops it being misread

**Additive.** Nothing existing changes; `analyzeP` is called as is and its result is
carried **unchanged** in the `core` field (`analyzeReport_core`). Around it:

* **D47 vacuity**, per act and for the module: how many norms, which modalities, whether
  an incompatible pair exists. If no act has one, `consistentOn` is true *whatever the
  conditions say* (`not_conflict_of_noModalityClash`) and `analyzeP` cannot return
  `.conflicts` (`analyzeP_not_conflicts_of_noClash`).
* **D48 resolutions**: same-act, incompatible-modality pairs that explicit priority settles
  (`Norm.resolved`), with the winner. **Pair level only**: whether the two norms are ever
  applicable at one point (D23) is *not* part of it.
* **D49 act usage** against a caller-supplied act catalog.
* **D50 review status**, printed with the result. For `draft` the renderer prints
  «DRAFT, NOT HUMAN REVIEWED». There is no theorem for the label.

## What this does not do

It does not change what `consistentOn` means. It does not use integrity constraints. It cannot
tell whether the encoding matches the law. A report with `reviewed` status only records that
someone typed a name and a date: nothing checks it.
-/

namespace LexProof

/-! ## D50: review status -/

inductive ReviewStatus
  | draft
  | reviewed (reviewer : String) (date : Date)
  deriving Repr, DecidableEq

def ReviewStatus.label : ReviewStatus → String
  | .draft => "DRAFT, NOT HUMAN REVIEWED"
  | .reviewed who d => s!"reviewed by {who} on {d.year}-{d.month}-{d.day} (recorded, not verified by the checker)"

/-! ## D47: modalities per act -/

theorem mem_dedupStr : ∀ (l : List String) (x : String), x ∈ dedupStr l ↔ x ∈ l
  | [], x => by simp [dedupStr]
  | y :: ys, x => by
    by_cases h : ys.contains y = true
    · have hy : y ∈ ys := by simpa using h
      simp only [dedupStr, h, ite_true, mem_dedupStr ys x, List.mem_cons]
      constructor
      · exact Or.inr
      · rintro (rfl | hx)
        · exact hy
        · exact hx
    · have hy : y ∉ ys := by simpa using h
      simp [dedupStr, hy, mem_dedupStr ys x]

/-- The distinct acts used by the list. -/
def actsOf (ns : List Norm) : List Act := dedupStr (ns.map fun n => n.act)

theorem mem_actsOf {ns : List Norm} {a : Act} : a ∈ actsOf ns ↔ ∃ n ∈ ns, n.act = a := by
  simp [actsOf, mem_dedupStr]

/-- Some norm of act `a` has modality `m`. -/
def usesModality (ns : List Norm) (a : Act) (m : Modality) : Bool :=
  ns.any fun n => n.act == a && n.modality == m

theorem usesModality_iff {ns : List Norm} {a : Act} {m : Modality} :
    usesModality ns a m = true ↔ ∃ n ∈ ns, n.act = a ∧ n.modality = m := by
  simp [usesModality, List.any_eq_true]

/-- Two norms of act `a` have incompatible modalities. -/
def hasClashPair (ns : List Norm) (a : Act) : Bool :=
  ns.any fun n₁ => ns.any fun n₂ => n₁.act == a && n₂.act == a && Incompatible n₁.modality n₂.modality

/-- No act has an incompatible pair: no modality clash is possible in this module. -/
def noModalityClash (ns : List Norm) : Bool := (actsOf ns).all fun a => !hasClashPair ns a

/-- Per-act vacuity: if act `a` has no incompatible pair, no two of its norms conflict, at any
point and under any atoms, whatever their conditions say. -/
theorem not_conflict_of_noClashAct {S P : Type} {A : Atoms S P} {ns : List Norm} {a : Act}
    (h : hasClashPair ns a = false) {n₁ n₂ : Norm} (h₁ : n₁ ∈ ns) (h₂ : n₂ ∈ ns)
    (ha₁ : n₁.act = a) (ha₂ : n₂.act = a) (π : P) (s : S) : ¬ Conflict A n₁ n₂ π s := by
  intro hc
  have hinc := hc.2.2.2.1
  have : hasClashPair ns a = true :=
    List.any_eq_true.2 ⟨n₁, h₁, List.any_eq_true.2 ⟨n₂, h₂, by simp [ha₁, ha₂, hinc]⟩⟩
  rw [h] at this
  exact absurd this (by simp)

/-- Module-level vacuity: if `noModalityClash`, no two norms of the list conflict anywhere,
independent of every condition. -/
theorem not_conflict_of_noModalityClash {S P : Type} {A : Atoms S P} {ns : List Norm}
    (h : noModalityClash ns = true) {n₁ n₂ : Norm} (h₁ : n₁ ∈ ns) (h₂ : n₂ ∈ ns)
    (π : P) (s : S) : ¬ Conflict A n₁ n₂ π s := by
  intro hc
  have hact : n₂.act = n₁.act := hc.1.symm
  have hmem : n₁.act ∈ actsOf ns := mem_actsOf.2 ⟨n₁, h₁, rfl⟩
  have hf : hasClashPair ns n₁.act = false := by
    have := (List.all_eq_true.1 h) _ hmem
    simpa using this
  exact not_conflict_of_noClashAct hf h₁ h₂ rfl hact π s hc

/-- With no clash possible, `analyzeP` can never report a conflict: only `.invalid` or
`.consistentOn`, and the latter then carries no information about the conditions. -/
theorem analyzeP_not_conflicts_of_noClash {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm} (h : noModalityClash ns = true)
    {hits : List ProjHit} {sc : ProjScope} :
    analyzeP ts tp rs rp catalog ns ≠ .conflicts hits sc := by
  intro hc
  obtain ⟨hne, hall⟩ := conflicts_sound hc
  cases hits with
  | nil => exact hne rfl
  | cons hit rest =>
    obtain ⟨n₁, h₁, n₂, h₂, _, _, _, _, _, π, s, _, hconf⟩ := hall hit (by simp)
    exact not_conflict_of_noModalityClash h h₁ h₂ π s hconf

structure ActInfo where
  act : Act
  normCount : Nat
  hasObligation : Bool
  hasProhibition : Bool
  hasPermission : Bool
  hasClash : Bool
  deriving Repr, DecidableEq

def actInfo (ns : List Norm) (a : Act) : ActInfo :=
  { act := a, normCount := (ns.filter fun n => n.act == a).length
  , hasObligation := usesModality ns a .obligation, hasProhibition := usesModality ns a .prohibition
  , hasPermission := usesModality ns a .permission, hasClash := hasClashPair ns a }

/-! ## D48: resolutions (pair level) -/

/-- Same-act, incompatible-modality pairs that `Norm.resolved` settles, with the winner. -/
def resolvedPairs (ns : List Norm) : List Resolution :=
  (pairsOf ns).filterMap fun p =>
    if p.1.act == p.2.act && Incompatible p.1.modality p.2.modality && Norm.resolved p.1 p.2 then
      match Norm.winner? p.1 p.2 with
      | some w => some { winner := w, loser := if w == p.1.id then p.2.id else p.1.id }
      | none => none
    else none

/-- Soundness: every listed resolution is a real pair of the list with the same act,
incompatible modalities, resolved by priority, and the listed winner and loser. -/
theorem resolvedPairs_sound {ns : List Norm} {r : Resolution} (h : r ∈ resolvedPairs ns) :
    ∃ p ∈ pairsOf ns, p.1.act = p.2.act ∧ Incompatible p.1.modality p.2.modality = true ∧
      Norm.resolved p.1 p.2 = true ∧ Norm.winner? p.1 p.2 = some r.winner ∧
      r.loser = (if r.winner == p.1.id then p.2.id else p.1.id) := by
  obtain ⟨p, hp, hr⟩ := List.mem_filterMap.1 h
  by_cases hc : (p.1.act == p.2.act && Incompatible p.1.modality p.2.modality &&
      Norm.resolved p.1 p.2) = true
  · simp only [hc, ite_true] at hr
    cases hw : Norm.winner? p.1 p.2 with
    | none => simp [hw] at hr
    | some w =>
      simp only [hw, Option.some.injEq] at hr
      subst hr
      simp only [Bool.and_eq_true, beq_iff_eq] at hc
      exact ⟨p, hp, hc.1.1, hc.1.2, hc.2, hw, rfl⟩
  · simp [hc] at hr

/-- Completeness: every same-act, incompatible, resolved pair of the list is listed. -/
theorem resolvedPairs_complete {ns : List Norm} {p : Norm × Norm} (hp : p ∈ pairsOf ns)
    (hact : p.1.act = p.2.act) (hinc : Incompatible p.1.modality p.2.modality = true)
    (hres : Norm.resolved p.1 p.2 = true) :
    ∃ r ∈ resolvedPairs ns, Norm.winner? p.1 p.2 = some r.winner ∧
      ((r.winner = p.1.id ∧ r.loser = p.2.id) ∨ (r.winner = p.2.id ∧ r.loser = p.1.id)) := by
  have hw : ∃ w, Norm.winner? p.1 p.2 = some w := by
    simp only [Norm.resolved] at hres
    cases h1 : p.1.overridesOther p.2 <;> cases h2 : p.2.overridesOther p.1 <;>
      simp [h1, h2] at hres <;> simp [Norm.winner?, h1, h2]
  obtain ⟨w, hw⟩ := hw
  have hc : (p.1.act == p.2.act && Incompatible p.1.modality p.2.modality &&
      Norm.resolved p.1 p.2) = true := by simp [hact, hinc, hres]
  refine ⟨{ winner := w, loser := if w == p.1.id then p.2.id else p.1.id },
    List.mem_filterMap.2 ⟨p, hp, by simp [hc, hw]⟩, hw, ?_⟩
  have : w = p.1.id ∨ w = p.2.id := by
    unfold Norm.winner? at hw
    split at hw
    · exact Or.inl (Option.some.inj hw).symm
    · split at hw
      · exact Or.inr (Option.some.inj hw).symm
      · simp at hw
  rcases this with rfl | rfl
  · exact Or.inl ⟨rfl, by simp⟩
  · by_cases e : p.2.id == p.1.id
    · exact Or.inl ⟨by simpa using (beq_iff_eq.1 e), by simp [e]⟩
    · exact Or.inr ⟨rfl, by simp [e]⟩

/-- A resolved pair never conflicts, at any point. -/
theorem not_conflict_of_resolved {S P : Type} {A : Atoms S P} {n₁ n₂ : Norm}
    (h : Norm.resolved n₁ n₂ = true) (π : P) (s : S) : ¬ Conflict A n₁ n₂ π s := by
  intro hc
  rw [hc.2.2.2.2] at h
  exact absurd h (by simp)

/-! ## D49: act usage against a caller-supplied catalog -/

inductive ActFinding
  | unknownAct (norm : NormId) (act : Act)
  deriving Repr, DecidableEq

def actCount (ns : List Norm) (a : Act) : Nat := (ns.filter fun n => n.act == a).length

/-- Acts used by exactly one norm. -/
def singleUseActs (ns : List Norm) : List Act := (actsOf ns).filter fun a => actCount ns a == 1

/-- Catalog acts no norm uses. -/
def unusedCatalogActs (ns : List Norm) (cat : List Act) : List Act :=
  cat.filter fun a => !(ns.any fun n => n.act == a)

/-- Norms whose act is not in the catalog. -/
def actFindings (ns : List Norm) (cat : List Act) : List ActFinding :=
  (ns.filter fun n => !cat.contains n.act).map fun n => ActFinding.unknownAct n.id n.act

theorem singleUseActs_sound {ns : List Norm} {a : Act} (h : a ∈ singleUseActs ns) :
    (∃ n ∈ ns, n.act = a) ∧ actCount ns a = 1 := by
  obtain ⟨hm, hc⟩ := List.mem_filter.1 h
  exact ⟨mem_actsOf.1 hm, by simpa using hc⟩

theorem unusedCatalogActs_sound {ns : List Norm} {cat : List Act} {a : Act}
    (h : a ∈ unusedCatalogActs ns cat) : a ∈ cat ∧ ∀ n ∈ ns, n.act ≠ a := by
  obtain ⟨hm, hc⟩ := List.mem_filter.1 h
  refine ⟨hm, fun n hn hna => ?_⟩
  have : (ns.any fun n => n.act == a) = true :=
    List.any_eq_true.2 ⟨n, hn, by simp [hna]⟩
  rw [this] at hc
  exact absurd hc (by simp)

theorem actFindings_sound {ns : List Norm} {cat : List Act} {f : ActFinding}
    (h : f ∈ actFindings ns cat) :
    ∃ n ∈ ns, f = ActFinding.unknownAct n.id n.act ∧ n.act ∉ cat := by
  obtain ⟨n, hn, rfl⟩ := List.mem_map.1 h
  obtain ⟨hm, hc⟩ := List.mem_filter.1 hn
  exact ⟨n, hm, rfl, by simpa using hc⟩

/-! ## The report -/

structure AnalysisReport where
  status : ReviewStatus
  /-- Exactly `analyzeP`'s result. -/
  core : ProjResult
  acts : List ActInfo
  noModalityClash : Bool
  resolutions : List Resolution
  singleUseActs : List Act
  unusedCatalogActs : List Act
  actFindings : List ActFinding
  deriving Repr, DecidableEq

def analyzeReport (status : ReviewStatus) (actCatalog : List Act) (ts tp : AtomTable)
    (rs rp : List ReaderSpec) (catalog : List String) (ns : List Norm) : AnalysisReport :=
  { status := status
  , core := analyzeP ts tp rs rp catalog ns
  , acts := (actsOf ns).map (actInfo ns)
  , noModalityClash := noModalityClash ns
  , resolutions := resolvedPairs ns
  , singleUseActs := singleUseActs ns
  , unusedCatalogActs := unusedCatalogActs ns actCatalog
  , actFindings := actFindings ns actCatalog }

/-- The core of the report is exactly `analyzeP`. -/
theorem analyzeReport_core (status : ReviewStatus) (actCatalog : List Act) (ts tp : AtomTable)
    (rs rp : List ReaderSpec) (catalog : List String) (ns : List Norm) :
    (analyzeReport status actCatalog ts tp rs rp catalog ns).core = analyzeP ts tp rs rp catalog ns :=
  rfl

/-! ## Rendering (deterministic text) -/

def ProjResult.lines : ProjResult → List String
  | .invalid fs =>
    s!"KẾT QUẢ: INVALID — {fs.length} finding; chưa kiểm xung đột nào" ::
      fs.map fun f => s!"  · {(repr f).pretty}"
  | .conflicts hs sc =>
    s!"KẾT QUẢ: XUNG ĐỘT hình thức — {hs.length} cặp (đã kiểm {sc.pairsChecked} cặp cùng act)" ::
      hs.map fun h => s!"  · {h.left} × {h.right}"
  | .consistentOn sc =>
    [s!"KẾT QUẢ: consistentOn trên phần ĐÃ MÃ HÓA — {sc.pairsChecked} cặp đã kiểm, {sc.pairsSkipped} cặp bỏ qua do khác act"]

def ActInfo.line (a : ActInfo) : String :=
  let mods := (if a.hasObligation then ["nghĩa vụ"] else []) ++ (if a.hasProhibition then ["cấm"] else []) ++
    (if a.hasPermission then ["cho phép"] else [])
  s!"  · {a.act}: {a.normCount} norm; modality: {String.intercalate ", " mods}; có cặp khắc nhau: {if a.hasClash then "có" else "KHÔNG"}"

def AnalysisReport.render (r : AnalysisReport) : List String :=
  [s!"TRẠNG THÁI DUYỆT: {r.status.label}"] ++ r.core.lines ++
  (match r.core with
   | .consistentOn _ =>
     (if r.noModalityClash then
        ["CẢNH BÁO: không act nào có hai modality khắc nhau, nên consistentOn đúng với MỌI nội dung điều kiện (rỗng về xung đột modality)"]
      else []) ++
     ["Không dùng ràng buộc toàn vẹn; không nói gì về việc bản mã hóa có khớp luật."]
   | _ => []) ++
  ["ACT:"] ++ r.acts.map ActInfo.line ++
  [s!"ƯU TIÊN (mức cặp, KHÔNG xét đồng áp dụng tại một điểm): {r.resolutions.length} cặp"] ++
  r.resolutions.map (fun x => s!"  · {x.winner} thắng {x.loser}") ++
  [s!"ACT CHỈ DÙNG MỘT LẦN: {String.intercalate ", " r.singleUseActs}",
   s!"ACT TRONG DANH MỤC NHƯNG KHÔNG DÙNG: {String.intercalate ", " r.unusedCatalogActs}"] ++
  r.actFindings.map fun f => s!"FINDING ACT: {(repr f).pretty}"

/-! ## Non-vacuity -/

example : ReviewStatus.draft.label = "DRAFT, NOT HUMAN REVIEWED" := by decide

private def exT : AtomTable := [⟨"A", .bool, "Điều 1"⟩]
private def exRS : List ReaderSpec := [("A", 0, 1)]
private def exN (id : String) (m : Modality) (act : String) (ov : List String) : Norm :=
  { id := id, modality := m, act := act, condition := .sit 0, exceptions := []
  , priority := if ov.isEmpty then none else some ⟨ov⟩
  , source := { docId := "EX", docType := .law, effective := ⟨2020, 1, 1⟩, article := "Điều 1" }
  , references := [] }

/-- act x clashes (obligation vs prohibition) and is settled by priority; act y is one
prohibition; act z (used by `o3`) is not in the catalog. -/
private def exNs : List Norm :=
  [exN "o1" .obligation "x" [], exN "p1" .prohibition "x" ["o1"], exN "p2" .prohibition "y" [],
   exN "o3" .prohibition "z" []]

example : (analyzeReport .draft ["x", "y", "w"] exT [] exRS [] [] exNs).noModalityClash = false := by
  decide

example : (analyzeReport .draft ["x", "y", "w"] exT [] exRS [] [] exNs).resolutions =
    [{ winner := "p1", loser := "o1" }] := by decide

example : (analyzeReport .draft ["x", "y", "w"] exT [] exRS [] [] exNs).singleUseActs = ["y", "z"] := by
  decide

example : (analyzeReport .draft ["x", "y", "w"] exT [] exRS [] [] exNs).unusedCatalogActs = ["w"] := by
  decide

example : (analyzeReport .draft ["x", "y", "w"] exT [] exRS [] [] exNs).actFindings =
    [ActFinding.unknownAct "o3" "z"] := by decide

example : noModalityClash [exN "a" .prohibition "x" [], exN "b" .prohibition "x" []] = true := by decide

example : ((analyzeReport .draft [] exT [] exRS [] [] exNs).render.head?) =
    some "TRẠNG THÁI DUYỆT: DRAFT, NOT HUMAN REVIEWED" := by decide

end LexProof
