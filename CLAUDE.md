# LexProof

Lean 4 system that checks the logical consistency of legal texts.
Graduation thesis project; research follow-up later (ASE / NeurIPS 2027 considered).

## Scope
- Level 1 only: consistency WITHIN a single document (conflicting obligation /
  prohibition / permission for the same situation with no clear priority;
  dangling references).
- Level 2 (consistency ACROSS documents, hierarchy of legal force) is a later
  extension. Do not implement it, but keep `doc_id`, document type and
  effective date fields in schemas.
- Domain: legal texts in general (Vietnamese). Not university training regulations.

## Top priority: correctness
- Two kinds of correctness: soundness (Lean kernel accepts the proof) and
  faithfulness (the encoding matches the law; checked only by human review and
  expert test cases). Do not blur them.
- Results are three-valued: conflict found / consistent on the encoded part /
  unknown. Never claim a whole document is "correct". Always report what was
  encoded and reviewed.
- Fail closed: if unsure, return unknown. Never silently skip a provision.
- Open-textured concepts ("hợp lý", "nghiêm trọng") are explicit parameters.
  The system never decides them.
- No `sorry`, no extra axioms, no `native_decide` in anything that backs a
  conclusion. Allowed axioms: propext, Classical.choice, Quot.sound
  (check with `#print axioms`).
- Every formalized rule keeps the ID of its source article.

## Layout
- `LexProof/` (Lean library): `Core` (Norm, modality, condition, exception,
  priority, source), `Laws` (one module per document), `Verify` (conflict
  checks, counterexamples), `Cert` (axiom audit).
- `pipeline/` (Python, untrusted): segmenter, LLM translation.
- `data/`, `review/`, `eval/`, `reports/`, `docs/`.
- Trust boundary: everything outside Lean is untrusted. LLM output must be
  approved by a human before it enters `Laws`.

## Working decisions (not final)
- Situations are modeled over a finite domain (Bool / enum / bounded values) so
  conflicts can be found automatically. Keep `Core` extensible beyond this.
- No Mathlib for now.

## Working rules
- Run `lake build` before saying a change is done.
- Keep changes small and targeted. Do not generate code beyond what was asked.
- Ask before adding dependencies, restructuring directories, or editing
  `lakefile.toml` / `lean-toolchain`.
- Explain Lean errors in plain Vietnamese. Code and identifiers in English.
- Environment: Windows, PowerShell, repo at D:\LexProof.