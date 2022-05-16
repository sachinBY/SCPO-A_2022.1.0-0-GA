%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM FCSTORDER"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ " ORDER BY ITEM,LOC,SEQNUM offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
  else 
  	sql ++ " ORDER BY ITEM,LOC,SEQNUM offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"