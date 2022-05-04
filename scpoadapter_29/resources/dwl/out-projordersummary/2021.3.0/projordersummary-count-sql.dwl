%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT COUNT(*) FROM (SELECT PROJORDERSUMMARY.*,NETWORKBRACKET.UOM FROM PROJORDERSUMMARY,NETWORKBRACKET WHERE PROJORDERSUMMARY.SOURCE=NETWORKBRACKET.SOURCE and PROJORDERSUMMARY.DEST=NETWORKBRACKET.DEST and PROJORDERSUMMARY.TRANSMODE=NETWORKBRACKET.TRANSMODE" ++ " AND " ++ vars.filterCondition ++ ")"
else	
	"SELECT COUNT(*) FROM (SELECT PROJORDERSUMMARY.*,NETWORKBRACKET.UOM FROM PROJORDERSUMMARY,NETWORKBRACKET WHERE PROJORDERSUMMARY.SOURCE=NETWORKBRACKET.SOURCE and PROJORDERSUMMARY.DEST=NETWORKBRACKET.DEST and PROJORDERSUMMARY.TRANSMODE=NETWORKBRACKET.TRANSMODE)"
