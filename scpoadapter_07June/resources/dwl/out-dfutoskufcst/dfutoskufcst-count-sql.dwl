%dw 2.0
output application/json
---
using (
    sql = "SELECT COUNT(*) FROM (select ITEM,SKULOC,DMDGROUP,TYPE,STARTDATE,DUR,sum(TOTFCST) as TOTFCST from DFUTOSKUFCST"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++  "  GROUP BY ITEM,SKULOC,DMDGROUP,TYPE,STARTDATE,DUR)"
  else 
  	sql ++ "  GROUP BY ITEM,SKULOC,DMDGROUP,TYPE,STARTDATE,DUR)"