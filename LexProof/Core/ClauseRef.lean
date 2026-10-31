import LexProof.Core.Norm

/-!
# Structured references to a unit of a legal text

A `ClauseRef` names a unit: an article (`Điều`), optionally a clause (`khoản`), optionally a point (`điểm`),
or the heading of an article. A separate field `branch` holds **project notation** such as «nhánh (i)»: a
sub-branch of a clause that is *not* a legal unit of the document, used to split a long clause that holds
several prohibitions. It is flagged by its own field and by `isProjectNotation`.

`parseRef` accepts only the forms listed in the grammar below and rejects everything else, so a typo is an
error and not a silent new reference. `render` is the canonical spelling; `normalize` is `render ∘ parseRef`.

```
ref   ::= "Điều" N
        | "Điều" N "tiêu đề"          (also "Điều" N "(tiêu đề)", read to the same reference)
        | "Điều" N "khoản" K [ "điểm" L ] [ "nhánh" "(" ROMAN ")" ]
entry ::= ref | "Điều" N "khoản" K "," K ... "," K        (a list of clauses of one article)
```

What this does **not** do: it does not check that the unit exists in the law (the segmented text does that),
and a heading is a reference to the heading, not a norm.
-/

namespace LexProof

inductive RefPart
  | body
  | heading
  deriving Repr, DecidableEq

structure ClauseRef where
  article : Nat
  clause : Option Nat := none
  /-- The letter of the point: `"a"`, `"đ"`. -/
  point : Option String := none
  part : RefPart := .body
  /-- Project notation, NOT a legal unit: «nhánh (i)». -/
  branch : Option String := none
  deriving Repr, DecidableEq

/-- Project notation is present. -/
def ClauseRef.isProjectNotation (r : ClauseRef) : Bool := r.branch.isSome

inductive RefSeg
  | art (n : Nat)
  | head
  | cl (n : Nat)
  | pt (s : String)
  | br (s : String)
  deriving Repr, DecidableEq

/-- The path from the article down; a heading hangs under its article. -/
def ClauseRef.path (r : ClauseRef) : List RefSeg :=
  [RefSeg.art r.article] ++ (if r.part == .heading then [RefSeg.head] else []) ++
    (r.clause.map RefSeg.cl).toList ++ (r.point.map RefSeg.pt).toList ++ (r.branch.map RefSeg.br).toList

/-- `p` is a strict ancestor of `c`: its path is a proper prefix of `c`'s. A heading is never an ancestor. -/
def ClauseRef.isAncestorOf (p c : ClauseRef) : Bool :=
  p.part == .body && decide (p.path.length < c.path.length) && p.path.isPrefixOf c.path

def ClauseRef.isParentOf (p c : ClauseRef) : Bool :=
  p.isAncestorOf c && c.path.length == p.path.length + 1

theorem ClauseRef.not_isAncestorOf_self (r : ClauseRef) : r.isAncestorOf r = false := by
  simp [ClauseRef.isAncestorOf]

theorem ClauseRef.isParentOf_isAncestorOf {p c : ClauseRef} (h : p.isParentOf c = true) :
    p.isAncestorOf c = true := by
  simp only [ClauseRef.isParentOf, Bool.and_eq_true] at h; exact h.1

/-! ## Rendering -/

def ClauseRef.render (r : ClauseRef) : String :=
  match r.part with
  | .heading => s!"Điều {r.article} tiêu đề"
  | .body =>
    "Điều " ++ toString r.article ++
      (match r.clause with | some k => " khoản " ++ toString k | none => "") ++
      (match r.point with | some p => " điểm " ++ p | none => "") ++
      (match r.branch with | some b => " nhánh (" ++ b ++ ")" | none => "")

/-! ## Parsing (on `List Char`, so that the kernel can run it) -/

def digitVal? (c : Char) : Option Nat :=
  if 48 ≤ c.toNat ∧ c.toNat ≤ 57 then some (c.toNat - 48) else none

def parseNat? (s : String) : Option Nat :=
  match s.toList with
  | [] => none
  | cs => cs.foldl (fun acc c => match acc, digitVal? c with | some a, some d => some (a * 10 + d) | _, _ => none)
            (some 0)

def tokens (s : String) : List String := (s.toList.splitOn ' ').map String.ofList

/-- `"(ii)"` ↦ `"ii"`; only the roman letters `i v x` are accepted. -/
def parseBranch? (s : String) : Option String :=
  match s.toList with
  | '(' :: rest =>
    match rest.reverse with
    | ')' :: body =>
      let b := body.reverse
      if !b.isEmpty && b.all (fun c => c == 'i' || c == 'v' || c == 'x') then some (String.ofList b) else none
    | _ => none
  | _ => none

/-- A point is one lowercase letter of the Vietnamese alphabet (`đ` included). -/
def parsePoint? (s : String) : Option String :=
  match s.toList with
  | [c] => if "abcdđeghiklmnopqrstuvxy".toList.contains c then some s else none
  | _ => none

def parseRef (s : String) : Except String ClauseRef :=
  let bad : Except String ClauseRef := .error s!"không phân tích được tham chiếu «{s}»"
  match tokens s with
  | ["Điều", n] => match parseNat? n with | some a => .ok { article := a } | none => bad
  | ["Điều", n, "tiêu", "đề"] | ["Điều", n, "(tiêu", "đề)"] =>
    match parseNat? n with | some a => .ok { article := a, part := .heading } | none => bad
  | "Điều" :: n :: "khoản" :: k :: rest =>
    match parseNat? n, parseNat? k with
    | some a, some kk =>
      match rest with
      | [] => .ok { article := a, clause := some kk }
      | ["điểm", p] =>
        match parsePoint? p with | some pp => .ok { article := a, clause := some kk, point := some pp } | none => bad
      | ["nhánh", b] =>
        match parseBranch? b with | some bb => .ok { article := a, clause := some kk, branch := some bb } | none => bad
      | ["điểm", p, "nhánh", b] =>
        match parsePoint? p, parseBranch? b with
        | some pp, some bb => .ok { article := a, clause := some kk, point := some pp, branch := some bb }
        | _, _ => bad
      | _ => bad
    | _, _ => bad
  | _ => bad

/-- A single reference, or a list of clauses of one article: `"Điều 32 khoản 3, 5, 7"`. -/
def parseEntry (s : String) : Except String (List ClauseRef) :=
  let bad : Except String (List ClauseRef) := .error s!"không phân tích được mục «{s}»"
  match tokens s with
  | "Điều" :: n :: "khoản" :: k1 :: more@(_ :: _) =>
    if k1.toList.getLast? == some ',' then
      match parseNat? n with
      | none => bad
      | some a =>
        let ks := (k1 :: more).map fun t => if t.toList.getLast? == some ',' then String.ofList t.toList.dropLast else t
        let ns := ks.map parseNat?
        let lastPlain := (more.getLast?).all fun t => t.toList.getLast? != some ','
        if ns.all Option.isSome && lastPlain then .ok (ns.filterMap fun o => o.map fun kk => { article := a, clause := some kk })
        else bad
    else (parseRef s).map fun r => [r]
  | _ => (parseRef s).map fun r => [r]

def normalize (s : String) : Except String String := (parseRef s).map ClauseRef.render

end LexProof
