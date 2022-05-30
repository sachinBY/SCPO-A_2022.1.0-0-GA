%dw 2.0
var sql2 = " GROUP BY ITEM,SKULOC,DMDGROUP,TYPE,STARTDATE,DUR"
output application/json
---
using (
    sql = "select ITEM,SKULOC,DMDGROUP,TYPE,STARTDATE,DUR,sum(TOTFCST) as TOTFCST from DFUTOSKUFCST" 
	
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ sql2 ++ " ORDER BY ITEM,SKULOC,DMDGROUP,STARTDATE,DUR,TYPE" ++ " OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
  else 
  	sql ++ sql2 ++ " ORDER BY ITEM,SKULOC,DMDGROUP,STARTDATE,DUR,TYPE" ++ " OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"