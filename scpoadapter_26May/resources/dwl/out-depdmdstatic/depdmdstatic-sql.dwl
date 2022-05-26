%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM DEPDMDSTATIC"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ " order by ITEM,LOC,PARENT,STARTDATE,FIRMSW,BOMNUM,PARENTSEQNUM,PARENTSCHEDDATE,PARENTEXPDATE,PARENTORDERTYPE,SUPERSEDESW,PARENTSTARTDATE,SEQNUM offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
  else 
  	sql ++ " order by ITEM,LOC,PARENT,STARTDATE,FIRMSW,BOMNUM,PARENTSEQNUM,PARENTSCHEDDATE,PARENTEXPDATE,PARENTORDERTYPE,SUPERSEDESW,PARENTSTARTDATE,SEQNUM offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"