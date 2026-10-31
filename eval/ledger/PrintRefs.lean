import LexProof
open LexProof LexProof.Laws.AlcoholSaleRefs
#eval IO.println ("\n".intercalate findings)
#eval IO.println (repr refOutOfScopeIds)
#eval IO.println (repr (refScoped.filter fun (_, r) => match r with | .ran .pass => false | _ => true))
#eval IO.println (repr refPassIds.length)
#eval IO.println (repr (allRefs.map ClauseRef.render))
#print axioms LexProof.ClauseRef.not_isAncestorOf_self
#print axioms LexProof.ClauseRef.isParentOf_isAncestorOf
#print axioms LexProof.Laws.AlcoholSaleRefs.runCaseRefScoped_heading
#print axioms LexProof.Laws.AlcoholSaleRefs.runCaseRefScoped_covered
#print axioms LexProof.Laws.AlcoholSaleRefs.RefScoped.outOfScope_ne_ran
#print axioms LexProof.Laws.AlcoholSaleRefs.render_parse_allRefs
#print axioms LexProof.Laws.AlcoholSaleRefs.unparsable_none
#print axioms LexProof.Laws.AlcoholSaleRefs.notInCatalog_none
#print axioms LexProof.Laws.AlcoholSaleRefs.sameRef_c37
#print axioms LexProof.Laws.AlcoholSaleRefs.refOutOfScope_set
#print axioms LexProof.Laws.AlcoholSaleRefs.ref_c37_in_scope
#print axioms LexProof.Laws.AlcoholSaleRefs.ref_c22_in_scope
