# -*- coding: utf-8 -*-
"""Generate the scratch Lean files of the V-lite cost experiment.

For each pair and each encoding the *same* atoms, the same readers (same order,
same indices) and the same two norms are emitted, so both encodings cover the
same set of points and the same norms.

  A = current design: situation structure, atoms are field readers
  B = V-lite: atoms are a table (name, domain, source); a situation is a valuation
      (list of value indices) and a reader is a list lookup

The files are NOT part of the lake library. Run one with
    lake env lean eval/situation-model/lean/<file>.lean
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "lean")

# ---------------------------------------------------------------------------
# Specs.  atoms: (id, label, values, source clause)   values == ["sai","đúng"] means Bool
# readers: (name, atom index, value index)
# ---------------------------------------------------------------------------
BOOL = ["sai", "đúng"]


def S(i): return "(Cond.sit %d)" % i
def Pm(i): return "(Cond.param %d)" % i
def AND(a, b): return "(Cond.and %s %s)" % (a, b)
def OR(a, b): return "(Cond.or %s %s)" % (a, b)
def NOT(a): return "(Cond.not %s)" % a


PAIR_A = dict(
    name="a",
    title="12.3.c x 13.2",
    atoms_s=[
        ("S01", "loại đồ uống", ["rượu", "bia"],
         "Điều 2 khoản 1-2 (định nghĩa rượu, bia); Điều 13 đoạn dẫn"),
        ("S02", "dải độ cồn", ["dưới 5,5 độ", "từ 5,5 đến dưới 15 độ", "từ 15 độ trở lên"],
         "Điều 13 đoạn dẫn (rượu 5,5 đến dưới 15; bia từ 5,5); Điều 12 (dưới 5,5); Điều 5 khoản 7 (từ 15)"),
        ("S24", "quảng cáo trên báo nói/báo hình", BOOL, "Điều 12 khoản 3 điểm c"),
        ("S25", "quảng cáo trên phương tiện ngoài trời", BOOL, "Điều 13 khoản 2"),
        ("S28", "phương tiện là biển hiệu của cơ sở kinh doanh rượu, bia", BOOL, "Điều 13 khoản 2 (ngoại lệ)"),
        ("S29", "ngay trước/trong/sau chương trình dành cho trẻ em", BOOL, "Điều 12 khoản 3 điểm c"),
        ("S30", "trong khung 18 đến 21 giờ", BOOL, "Điều 12 khoản 3 điểm c"),
        ("S31", "quảng cáo có sẵn trong chương trình thể thao tiếp sóng từ nước ngoài", BOOL,
         "Điều 12 khoản 3 điểm c (ngoại lệ)"),
    ],
    atoms_p=[
        ("P11", "chương trình 'dành cho' trẻ em", BOOL, "Điều 12 khoản 3 điểm c (khái niệm mở)"),
        ("P13", "'trường hợp khác theo quy định của Chính phủ'", BOOL, "Điều 12 khoản 3 điểm c (khe ủy quyền)"),
    ],
    readers_s=[
        ("S01=rượu", 0, 0), ("S01=bia", 0, 1),
        ("S02<5,5", 1, 0), ("S02 5,5..<15", 1, 1), ("S02>=15", 1, 2),
        ("S24", 2, 1), ("S25", 3, 1), ("S28", 4, 1), ("S29", 5, 1), ("S30", 6, 1), ("S31", 7, 1),
    ],
    readers_p=[("P11", 0, 1), ("P13", 1, 1)],
    # B13 = (rượu and 5,5..<15) or (bia and (5,5..<15 or >=15))
    norms=[
        ("12.3.c", "prohibition", "qc_o_noi",
         AND(S(5), OR(AND(S(8), Pm(0)), S(9))),
         [S(10), Pm(1)], "Điều 12 khoản 3 điểm c"),
        ("13.2", "prohibition", "qc_o_noi",
         AND(OR(AND(S(0), S(3)), AND(S(1), OR(S(3), S(4)))), S(6)),
         [S(7)], "Điều 13 khoản 2"),
    ],
)

PAIR_B = dict(
    name="b",
    title="5.5 x 10.6",
    atoms_s=[
        ("S06", "người uống thuộc nhóm ở 5.5", BOOL, "Điều 5 khoản 5"),
        ("S07", "thời điểm uống so với giờ làm việc/học tập",
         ["ngay trước", "trong giờ", "nghỉ giữa giờ", "ngoài"], "Điều 5 khoản 5"),
        ("S19", "địa điểm là nơi làm việc của cơ quan nhà nước/tổ chức chính trị/...", BOOL, "Điều 10 khoản 6"),
        ("S20", "địa điểm được phép kinh doanh rượu, bia", BOOL, "Điều 10 khoản 6 (ngoại lệ)"),
        ("S22", "đang trong thời gian làm việc", BOOL, "Điều 10 khoản 6"),
    ],
    atoms_p=[("P01", "'ngay trước' (uống)", BOOL, "Điều 5 khoản 5 (khái niệm mở)")],
    readers_s=[
        ("S06", 0, 1),
        ("S07=ngay trước", 1, 0), ("S07=trong giờ", 1, 1), ("S07=nghỉ giữa giờ", 1, 2), ("S07=ngoài", 1, 3),
        ("S19", 2, 1), ("S20", 3, 1), ("S22", 4, 1),
    ],
    readers_p=[("P01", 0, 1)],
    norms=[
        ("5.5", "prohibition", "uong",
         AND(S(0), OR(OR(S(2), S(3)), AND(S(1), Pm(0)))), [], "Điều 5 khoản 5"),
        ("10.6", "prohibition", "uong",
         AND(S(5), S(7)), [S(6)], "Điều 10 khoản 6"),
    ],
)

PAIRS = {"a": PAIR_A, "b": PAIR_B}


def is_bool(a): return a[2] == BOOL


def lit(s):  # Lean string literal
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def with_extra(spec, k):
    atoms_s = list(spec["atoms_s"]) + [("X%d" % i, "atom thêm (không norm nào đọc)", BOOL,
                                        "không có: chỉ để nhân số điểm") for i in range(1, k + 1)]
    return dict(spec, atoms_s=atoms_s)


COMMON = '''
def nrm (id : String) (m : Modality) (act : String) (c : Cond) (ex : List Cond)
    (art : String) : Norm :=
  { id := id, modality := m, act := act, condition := c, exceptions := ex
  , priority := none
  , source := { docId := "44/2019/QH14", docType := .law
              , effective := ⟨2020, 1, 1⟩, article := art }
  , references := [] }

def catalog : List String := []
'''


def norms_text(spec):
    items = []
    for (nid, mod, act, c, ex, art) in spec["norms"]:
        items.append("  nrm %s .%s %s %s [%s] %s" % (lit(nid), mod, lit(act), c, ", ".join(ex), lit(art)))
    return "def norms : List Norm :=\n  [\n" + ",\n".join(items) + "\n  ]\n"


def claim_text(mode, kind):
    tac = {"kernel": "decide +kernel", "plain": "decide"}[mode]
    if kind == "search1":
        return ("theorem search : (analyze atoms catalog norms).isConsistentOn = true := by\n  %s\n\n"
                "#print axioms search\n") % tac
    if kind == "search":
        return ("theorem search : (analyze atoms catalog norms).isConsistentOn = true := by\n  %s\n\n"
                "theorem strong : ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ (π : Params) (s : Sit),\n"
                "    atoms.valid π s = true → ¬ Conflict atoms n₁ n₂ π s := by\n"
                "  cases hr : analyze atoms catalog norms with\n"
                "  | consistentOn sc au => exact not_conflict_of_consistentOn hr\n"
                "  | _ => have h := search; simp [Result.isConsistentOn, hr] at h\n"
                "\n#print axioms search\n#print axioms strong\n") % tac
    else:  # full
        return ("theorem full : analyze atoms catalog norms =\n"
                "    .consistentOn (scopeOf Sit Params atoms norms) (auditOf atoms norms) := by\n  %s\n\n"
                "#print axioms full\n") % tac


def gen_A(spec, mode, kind, prof):
    L = ["import LexProof.Verify.Conflict", "open LexProof", "",
         "/-! Encoding A (current design). Pair %s. Scratch file, not part of the library. -/" % spec["title"],
         "namespace ExpA", ""]
    if prof:
        L += ["set_option profiler true", "set_option profiler.threshold 1", ""]

    def side(atoms, tname, prefix):
        out = []
        for i, a in enumerate(atoms):
            if not is_bool(a):
                k = len(a[2])
                out.append("/-- %s: %s. Giá trị: %s. Nguồn: %s -/" % (a[0], a[1], "; ".join(a[2]), a[3]))
                out.append("inductive %s%s | %s deriving DecidableEq, Repr" % (
                    prefix, a[0], " | ".join("v%d" % j for j in range(k))))
                out.append("instance : Finite %s%s where\n  enum := [%s]\n  complete := by intro a; cases a <;> simp"
                           % (prefix, a[0], ", ".join(".v%d" % j for j in range(k))))
        out.append("structure %s where" % tname)
        for a in atoms:
            ty = "Bool" if is_bool(a) else "%s%s" % (prefix, a[0])
            out.append("  f%s : %s   -- %s: %s (nguồn: %s)" % (a[0], ty, a[0], a[1], a[3]))
        out.append("  deriving DecidableEq, Repr")
        names = ["f" + a[0] for a in atoms]
        gens = []
        binders = []
        for a, nm in zip(atoms, names):
            ty = "Bool" if is_bool(a) else "%s%s" % (prefix, a[0])
            gens.append("(Finite.enum (α := %s)).flatMap fun %s =>" % (ty, nm))
        body = "\n    ".join(gens)
        mk = "⟨%s⟩" % ", ".join(names)
        # innermost must be a map; rewrite last flatMap to map
        last = gens[-1].replace(".flatMap fun", ".map fun")
        gens2 = gens[:-1] + [last]
        body = "\n    ".join(gens2)
        out.append("instance : Finite %s where\n  enum :=\n    %s\n      %s" % (tname, body, mk))
        out.append("  complete := by\n    intro s\n    obtain %s := s\n"
                   "    simp [List.mem_flatMap, List.mem_map, Finite.complete]" % mk)
        return out

    L += side(spec["atoms_s"], "Sit", "T")
    L += [""]
    L += side(spec["atoms_p"], "Params", "Q")
    L += [""]

    def reader(r, atoms, prefix):
        name, ai, vi = r
        a = atoms[ai]
        if is_bool(a):
            return "(%s, fun s => s.f%s)" % (lit(name), a[0])
        return "(%s, fun s => s.f%s == %s%s.v%d)" % (lit(name), a[0], prefix, a[0], vi)

    L.append("def atoms : Atoms Sit Params where")
    L.append("  sit := [%s]" % ",\n    ".join(reader(r, spec["atoms_s"], "T") for r in spec["readers_s"]))
    L.append("  param := [%s]" % ",\n    ".join(reader(r, spec["atoms_p"], "Q").replace("fun s", "fun s") for r in spec["readers_p"]))
    L.append(COMMON)
    L.append(norms_text(spec))
    L.append(claim_text(mode, kind))
    L.append("end ExpA")
    return "\n".join(L) + "\n"


def gen_B(spec, mode, kind, prof):
    L = ["import LexProof.Verify.Conflict", "open LexProof", "",
         "/-! Encoding B (V-lite). Pair %s. Scratch file, not part of the library. -/" % spec["title"],
         "namespace ExpB", ""]
    if prof:
        L += ["set_option profiler true", "set_option profiler.threshold 1", ""]

    def table(atoms, nm):
        rows = []
        for a in atoms:
            rows.append("  (%s, [%s],\n    %s)" % (lit(a[0] + " " + a[1]), ", ".join(lit(v) for v in a[2]), lit(a[3])))
        return ("/-- Bảng atom: (tên, các dải/giá trị, khoản luật nguồn). -/\n"
                "def table%s : List (String × List String × String) :=\n  [\n%s\n  ]\n"
                "def %sdoms : List Nat := table%s.map fun a => a.2.1.length\n") % (nm, ",\n".join(rows), nm.lower(), nm)

    L.append(table(spec["atoms_s"], "S"))
    L.append(table(spec["atoms_p"], "P"))
    L.append('''def legal : List Nat → List Nat → Bool
  | [], [] => true
  | d :: ds, v :: vs => decide (v < d) && legal ds vs
  | _, _ => false

def allVals : List Nat → List (List Nat)
  | [] => [[]]
  | d :: ds => (List.range d).flatMap fun v => (allVals ds).map (v :: ·)

theorem mem_allVals : ∀ (doms vs : List Nat), vs ∈ allVals doms ↔ legal doms vs = true
  | [], vs => by cases vs <;> simp [allVals, legal]
  | d :: ds, vs => by
    cases vs with
    | nil => simp [allVals, legal]
    | cons v vs =>
      simp [allVals, legal, List.mem_flatMap, List.mem_map, List.mem_range, mem_allVals ds vs]

/-- A situation (or a parameter assignment) is a valuation: one value index per atom. -/
structure Val (doms : List Nat) where
  vs : List Nat
  h : legal doms vs = true
  deriving DecidableEq

instance (doms : List Nat) : Finite (Val doms) where
  enum := (allVals doms).attach.map fun x => ⟨x.1, (mem_allVals doms x.1).1 x.2⟩
  complete := by
    intro a
    exact List.mem_map.2 ⟨⟨a.vs, (mem_allVals doms a.vs).2 a.h⟩, List.mem_attach _ _, rfl⟩

abbrev Sit := Val sdoms
abbrev Params := Val pdoms

/-- Reader: atom `i` has value index `v`. -/
def rd {d : List Nat} (i v : Nat) (s : Val d) : Bool := s.vs.getD i 0 == v
''')
    L.append("def atoms : Atoms Sit Params where")
    L.append("  sit := [%s]" % ",\n    ".join("(%s, rd %d %d)" % (lit(r[0]), r[1], r[2]) for r in spec["readers_s"]))
    L.append("  param := [%s]" % ",\n    ".join("(%s, rd %d %d)" % (lit(r[0]), r[1], r[2]) for r in spec["readers_p"]))
    L.append(COMMON)
    L.append(norms_text(spec))
    L.append(claim_text(mode, kind))
    L.append("end ExpB")
    return "\n".join(L) + "\n"


def points(spec):
    n = 1
    for a in spec["atoms_s"] + spec["atoms_p"]:
        n *= len(a[2])
    return n


def write(name, text):
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, name), "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def main():
    files = []
    for pk in ("a", "b"):
        for extra in (0, 1, 2, 3) if pk == "a" else (0, 1, 2):
            spec = with_extra(PAIRS[pk], extra)
            for enc, g in (("A", gen_A), ("B", gen_B)):
                for mode in ("kernel",):
                    nm = "%s_%s_x%d.lean" % (enc, pk, extra)
                    write(nm, g(spec, mode, "search", False))
                    write(nm.replace(".lean", "_one.lean"), g(spec, mode, "search1", False))
                    files.append((nm, points(spec)))
                if extra == 0:
                    write("%s_%s_x0_prof.lean" % (enc, pk), g(spec, "kernel", "search", True))
                    write("%s_%s_x0_plain.lean" % (enc, pk), g(spec, "plain", "search", False))
                    write("%s_%s_x0_full.lean" % (enc, pk), g(spec, "kernel", "full", False))
    write("baseline.lean", "import LexProof.Verify.Conflict\nopen LexProof\ntheorem baseline : True := trivial\n")
    for f, p in files:
        print(f, p)


if __name__ == "__main__":
    main()
