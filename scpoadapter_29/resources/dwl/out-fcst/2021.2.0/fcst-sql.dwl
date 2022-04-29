%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM FCST"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ " ORDER BY DMDUNIT,DMDGROUP,LOC,STARTDATE,TYPE,FCSTID offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
  else 
  	sql ++ " ORDER BY DMDUNIT,DMDGROUP,LOC,STARTDATE,TYPE,FCSTID offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"