%dw 2.0
output application/java
---
flatten(flatten(vars.sourcingData map(sourcingvalue,sourcingindex)->{
	csv: payload map(csvvalue,csvindex)-> {
		ITEM:    if(sourcingvalue.ITEM == csvvalue."plannedSupplyId.item.primaryId")
			  sourcingvalue.ITEM
			     else null,
	    SOURCE: if(sourcingvalue.SOURCE == csvvalue."plannedSupplyId.shipFrom.primaryId")
	          sourcingvalue.SOURCE
	    		else null,
	    DEST:   if(sourcingvalue.DEST == csvvalue."plannedSupplyId.shipTo.primaryId")
	          sourcingvalue.DEST
	            else null,   
		SOURCING: if(sourcingvalue.SOURCING != null and (sourcingvalue.ITEM == csvvalue."plannedSupplyId.item.primaryId" or
			         sourcingvalue.SOURCE == csvvalue."plannedSupplyId.shipFrom.primaryId" or
			         sourcingvalue.DEST == csvvalue."plannedSupplyId.shipTo.primaryId"))
			   sourcingvalue.SOURCING
			else null,
	    FACTOR: if(sourcingvalue.FACTOR != null and (sourcingvalue.ITEM == csvvalue."plannedSupplyId.item.primaryId" or
			         sourcingvalue.SOURCE == csvvalue."plannedSupplyId.shipFrom.primaryId" or
			         sourcingvalue.DEST == csvvalue."plannedSupplyId.shipTo.primaryId"))
			sourcingvalue.FACTOR
			else null,
	    TRANSMODE: if(sourcingvalue.TRANSMODE != null and (sourcingvalue.ITEM == csvvalue."plannedSupplyId.item.primaryId" or
			         sourcingvalue.SOURCE == csvvalue."plannedSupplyId.shipFrom.primaryId"  or
			         sourcingvalue.DEST == csvvalue."plannedSupplyId.shipTo.primaryId"))
			sourcingvalue.TRANSMODE
			else null
	}
}pluck($)))filter($.ITEM !=null)distinctBy $.ITEM