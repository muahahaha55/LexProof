import LexProof
/-! Scratch (not part of the library, not imported anywhere): prints what `pipeline/report.py` needs from
`Laws/AlcoholSale.lean` as JSON. It only RUNS existing definitions; it proves nothing. Run:
`lake env lean --run eval/report/Dump.lean`

The report command combines this output with `data/segmented` and the coverage ledger. -/
open LexProof LexProof.Laws.AlcoholSale LexProof.Laws.AlcoholSaleCases LexProof.Laws.AlcoholSaleRefs
  LexProof.Laws.AlcoholSaleBands

def esc (s : String) : String :=
  let bs := Char.ofNat 92
  let dq := Char.ofNat 34
  String.ofList (s.toList.flatMap fun c =>
    if c == dq || c == bs then [bs, c] else if c == Char.ofNat 10 then [bs, 'n'] else [c])

def q (s : String) : String := "\"" ++ esc s ++ "\""
def arr (xs : List String) : String := "[" ++ ", ".intercalate xs ++ "]"
def qs (xs : List String) : String := arr (xs.map q)
def obj (kvs : List (String × String)) : String := "{" ++ ", ".intercalate (kvs.map fun (k, v) => q k ++ ": " ++ v) ++ "}"
def jb (b : Bool) : String := if b then "true" else "false"

def statusKey : CaseStatus → String
  | .forbidden => "forbidden" | .required => "required" | .explicitlyPermitted => "explicitlyPermitted"
  | .clash => "clash" | .noNormApplies => "noNormApplies"

def kindKey : CaseKind → String
  | .positive => "positive" | .negativeControl => "negativeControl" | .boundary => "boundary" | .exception => "exception"

def confKey : Confidence → String | .high => "high" | .medium => "medium" | .low => "low"

def outcomeJson : CaseOutcome → List (String × String)
  | .pass => [("outcome", q "pass")]
  | .fail g => [("outcome", q "fail"), ("got", q (statusKey g))]
  | .underspecified m => [("outcome", q "underspecified"), ("missing", qs m)]
  | .malformed w => [("outcome", q "malformed"), ("why", q w)]

def scopeJson : RefScoped → String
  | .ran _ => obj [("kind", q "ran")]
  | .outOfScope e => obj [("kind", q "outOfScope"), ("entry", q e)]
  | .badRef w => obj [("kind", q "badRef"), ("why", q w)]

def oldScopeJson (c : Case) : String :=
  match runCaseScoped notEncodedKeys clauseKey tS tP rS rP norms c |>.outcome with
  | .ran _ => obj [("kind", q "ran")]
  | .outOfScope e => obj [("kind", q "outOfScope"), ("entry", q e)]

def caseJson (c : Case) : String :=
  let r := runCase tS tP rS rP norms c
  let sc := runCaseRefScoped (refEntries notEncoded) tS tP rS rP norms c
  obj ([("id", q c.id), ("description", q c.description), ("act", q c.act), ("expected", q (statusKey c.expected))
      , ("clause", q c.clause), ("kind", q (kindKey c.kind)), ("confidence", q (confKey c.confidence))
      , ("applying", qs r.applying), ("scope", scopeJson sc), ("old_scope", oldScopeJson c)] ++ outcomeJson r.outcome)

def numJson (n : NumCase) : String :=
  match runNum n with
  | .outOfRange => obj [("id", q n.id), ("description", q n.description), ("expected", q (statusKey n.expected)), ("outcome", q "outOfRange")]
  | .ran o => obj ([("id", q n.id), ("description", q n.description), ("expected", q (statusKey n.expected))] ++ outcomeJson o)

def actJson (a : ActInfo) : String :=
  obj [("act", q a.act), ("norms", toString a.normCount), ("obligation", jb a.hasObligation)
      , ("prohibition", jb a.hasProhibition), ("permission", jb a.hasPermission), ("clash", jb a.hasClash)]

def actCatalog : List Act :=
  ["ban_ruou_bia", "cung_cap_ruou_bia", "khuyen_mai_ruou_bia", "dung_ruou_bia_lam_qua_khuyen_mai",
   "ban_ruou_bia_bang_may_tu_dong"]

def analyzeJson : String :=
  let rep := analyzeReport .draft actCatalog tS tP rS rP catalog norms
  let core : List (String × String) :=
    match rep.core with
    | .invalid fs => [("result", q "invalid"), ("findings", qs (fs.map fun f => (repr f).pretty))]
    | .conflicts hs sc =>
      [("result", q "conflicts"), ("hits", qs (hs.map fun h => s!"{h.left} × {h.right}")),
       ("pairs_checked", toString sc.pairsChecked), ("pairs_skipped", toString sc.pairsSkipped)]
    | .consistentOn sc =>
      [("result", q "consistentOn"), ("pairs_checked", toString sc.pairsChecked), ("pairs_skipped", toString sc.pairsSkipped),
       ("articles", qs sc.articles), ("constraints_used", jb sc.constraintsUsed),
       ("full_situations", toString sc.fullSituations), ("full_params", toString sc.fullParams)]
  obj (core ++
    [ ("status_label", q rep.status.label)
    , ("no_modality_clash", jb rep.noModalityClash)
    , ("acts", arr (rep.acts.map actJson))
    , ("resolutions", qs (rep.resolutions.map fun r => s!"{r.winner} thắng {r.loser}"))
    , ("single_use_acts", qs rep.singleUseActs)
    , ("unused_catalog_acts", qs rep.unusedCatalogActs)
    , ("act_findings", qs (rep.actFindings.map fun f => (repr f).pretty))
    , ("render", qs rep.render)
    , ("module_findings", qs ((pfindings tS tP rS rP catalog norms).map fun f => (repr f).pretty)) ])

def normJson (n : Norm) : String :=
  obj [("id", q n.id), ("act", q n.act), ("source", q n.source.article)]

def main : IO Unit := do
  let diff := (cases.filter fun c =>
    match runCaseRefScoped (refEntries notEncoded) tS tP rS rP norms c,
          runCaseScoped notEncodedKeys clauseKey tS tP rS rP norms c |>.outcome with
    | .outOfScope _, .outOfScope _ => false
    | .ran _, .ran _ => false
    | _, _ => true).map (·.id)
  IO.println (obj
    [ ("module", q "alcohol-sale")
    , ("doc_id", q "44/2019/QH14")
    , ("norms", arr (norms.map normJson))
    , ("analyze", analyzeJson)
    , ("ref_findings", qs findings)
    , ("cases", arr (cases.map caseJson))
    , ("scoping_diff", qs diff)
    , ("num_cases", arr (numCases.map numJson))
    , ("assumed_bounds", qs assumedBounds)
    , ("not_encoded", arr (notEncoded.map fun e => obj [("clause", q e.clause), ("reason", q e.reason)])) ])
