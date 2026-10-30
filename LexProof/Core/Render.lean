import LexProof.Core.AtomTable

/-!
# Deterministic rendering of a `Norm` (for the human reviewer)

Prints a `Norm` using the **names, band labels and source strings of the atom
tables** it reads. No LLM, no interpretation, no paraphrase: the reviewer reads
what the checker actually sees. Every function is structural and total.

A reader `(name, atom, value)` is shown as the atom with the value it tests
(`atom = band label`, or the atom's name for a `Bool` atom tested for `true`);
the reader's own `name` is **not** shown, because the checker never looks at it.
A missing reader or atom is shown as `‹…›` instead of being hidden.
-/

namespace LexProof.Render

/-- Everything a `Cond` index refers to. -/
structure Ctx where
  ts : AtomTable
  tp : AtomTable
  rs : List ReaderSpec
  rp : List ReaderSpec

def modalityText : Modality → String
  | .obligation => "nghĩa vụ"
  | .prohibition => "cấm"
  | .permission => "cho phép"

/-- Label of value `v` of atom `a`. -/
def valueText (a : Atom) (v : Nat) : String :=
  match a.domain with
  | .bool => if v == 1 then "đúng" else "sai"
  | .enum bs =>
    match bs[v]? with
    | some b => b.label
    | none => s!"‹giá trị {v} ngoài miền›"

/-- A reader as the checker sees it. -/
def readerText (t : AtomTable) (rs : List ReaderSpec) (i : Nat) : String :=
  match rs[i]? with
  | none => s!"‹bộ đọc {i} không tồn tại›"
  | some r =>
    match t[r.2.1]? with
    | none => s!"‹atom {r.2.1} không tồn tại›"
    | some a =>
      match a.domain with
      | .bool => if r.2.2 == 1 then a.name else s!"không ({a.name})"
      | .enum _ => s!"{a.name} = {valueText a r.2.2}"

/-- A condition tree, fully parenthesised. -/
def Ctx.cond (c : Ctx) : Cond → String
  | .tt => "luôn đúng"
  | .ff => "luôn sai"
  | .sit i => readerText c.ts c.rs i
  | .param i => "[tham số] " ++ readerText c.tp c.rp i
  | .not x => "KHÔNG (" ++ c.cond x ++ ")"
  | .and x y => "(" ++ c.cond x ++ " VÀ " ++ c.cond y ++ ")"
  | .or x y => "(" ++ c.cond x ++ " HOẶC " ++ c.cond y ++ ")"

/-- Exceptions: the norm does not apply if **any** of them holds. -/
def Ctx.exceptions (c : Ctx) : List Cond → String
  | [] => "không có"
  | es => String.intercalate "; " (es.map c.cond)

/-- One norm as the checker sees it, as lines of text. -/
def Ctx.norm (c : Ctx) (n : Norm) : List String :=
  [ s!"[{n.id}] act = {n.act} | loại = {modalityText n.modality} | nguồn = {n.source.docId}, {n.source.article}"
  , s!"  điều kiện: {c.cond n.condition}"
  , s!"  ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): {c.exceptions n.exceptions}"
  , s!"  ưu tiên: {if n.overrideIds.isEmpty then "không khai báo" else String.intercalate ", " n.overrideIds}" ]

/-- An atom table: each atom with its source, each band with its own source. -/
def table (t : AtomTable) : List String :=
  t.flatMap fun a =>
    match a.domain with
    | .bool => [s!"{a.name} [Bool] — nguồn: {a.source}"]
    | .enum bs =>
      s!"{a.name} [enum {bs.length}] — nguồn: {a.source}" ::
        bs.map fun b => s!"    · {b.label} — nguồn: {b.source}"

/-- Every reader as the checker sees it, with its index. -/
def readers (t : AtomTable) (rs : List ReaderSpec) : List String :=
  (List.range rs.length).map fun i => s!"{i}: {readerText t rs i}"

end LexProof.Render
