%dw 2.0
output application/java  
---
 (payload map (relation, indexOfrelation) -> {
 	MS_BULK_REF: relation.MS_BULK_REF,
	MS_REF: relation.MS_REF,	
 	INTEGRATION_STAMP: relation.INTEGRATION_STAMP,
 	MESSAGE_TYPE: relation.MESSAGE_TYPE,
  	MESSAGE_ID: relation.MESSAGE_ID,
  	SENDER: relation.SENDER,
    (ALTITEM: relation.ALTITEM) if not relation.ALTITEM == null,
    (DISC: relation.DISC) if not relation.DISC == null,
	(DMDGROUP: relation.DMDGROUP) if not relation.DMDGROUP == null,
	(EFF: relation.EFF) if not relation.EFF == null,
	(ITEM: relation.ITEM) if not relation.ITEM == null,
	(LOC: relation.LOC) if not relation.LOC == null,
	(vars.deleteudc): 'Y'
  })