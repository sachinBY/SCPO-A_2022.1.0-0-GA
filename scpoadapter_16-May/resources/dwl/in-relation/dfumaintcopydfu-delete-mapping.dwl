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
    (ACTION_GROUP_SET_ID: relation.ACTION_GROUP_SET_ID) if not relation.ACTION_GROUP_SET_ID == null,
    (ACTION_NUMBER: relation.ACTION_NUMBER) if not relation.ACTION_NUMBER == null,
	FROMDISCDATE: relation.FROMDISCDATE,
	FROMHISTSTART: relation.FROMHISTSTART,
	REQUESTID: relation.REQUESTID,
	TODISCDATE: relation.TODISCDATE,
	TOEFFDATE: relation.TOEFFDATE,
	TONPIINDDATE: relation.TONPIINDDATE,
	TONPISCALINGFACTOR: relation.TONPISCALINGFACTOR,
	HISTSTREAM: relation.HISTSTREAM,
	(FROMDMDGROUP: relation.FROMDMDGROUP) if not relation.FROMDMDGROUP == null,
	TODMDGROUP: relation.TODMDGROUP,
	(FROMDMDUNIT: relation.FROMDMDUNIT) if not relation.FROMDMDUNIT == null,
	TODMDUNIT: relation.TODMDUNIT,
	(FROMLOC: relation.FROMLOC) if not relation.FROMLOC == null,
	TOLOC: relation.TOLOC,
	(FROMMODEL: relation.FROMMODEL) if not relation.FROMMODEL == null,
	(REQUESTID: relation.REQUESTID) if not relation.REQUESTID == null,
	(TODMDGROUP: relation.TODMDGROUP) if not relation.TODMDGROUP == null,
	(TODMDUNIT: relation.TODMDUNIT) if not relation.TODMDUNIT == null,
	(TOLOC: relation.TOLOC) if not relation.TOLOC == null,
	(TOMODEL: relation.TOMODEL) if not relation.TOMODEL == null,
	(vars.deleteudc): 'Y'
  })