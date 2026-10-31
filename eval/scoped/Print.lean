import LexProof
open LexProof LexProof.Laws.AlcoholSaleBands
#eval IO.println scopedReportNow
#eval IO.println ("\n".intercalate assumedBounds)
#eval numCases.map fun n => (n.id, repr (runNum n))
#print axioms LexProof.runCaseScoped_outOfScope
#print axioms LexProof.runCaseScoped_ran
#print axioms LexProof.outOfScope_not_pass
#print axioms LexProof.scoped_pass_iff
#print axioms LexProof.tiles_unique_band
#print axioms LexProof.tiles_bandOf_none
#print axioms LexProof.Laws.AlcoholSaleBands.age_tiles
#print axioms LexProof.Laws.AlcoholSaleBands.alcohol_tiles
#print axioms LexProof.Laws.AlcoholSaleBands.age_labels
#print axioms LexProof.Laws.AlcoholSaleBands.alcohol_labels
#print axioms LexProof.Laws.AlcoholSaleBands.out_of_scope_set
#print axioms LexProof.Laws.AlcoholSaleBands.scoped_pass_set
#print axioms LexProof.Laws.AlcoholSaleBands.unmentioned_set
#print axioms LexProof.Laws.AlcoholSaleBands.num_pass_all
#print axioms LexProof.Laws.AlcoholSaleBands.num_out_of_range
