%dw 2.0
output text/plain
var keys = vars.headers
var seqs = (vars.sequencesMap[vars.tableName] map (table , index) -> {
	'nextvals': (table mapObject {
		'value': ($$) ++ ' "' ++ p('scpo.db.oracle.user') ++ '.' ++ ($) ++ '.NEXTVAL"'
	}).value
}.nextvals) default []
var columns = (keys map (key , index) -> 
{'key': if(key == 'INTEGRATION_STAMP')
			key ++ "\" TO_DATE(SUBSTR(:" ++ key ++ ",1,19), 'YYYY/MM/DD HH24:MI:SS')\""
		else if(key == 'MS_BULK_REF' or key == 'MS_REF' or key == 'PROMOTION' or key == 'MESSAGE_TYPE' or key == 'SENDER' or key == 'MESSAGE_ID') 
			key ++ " FILLER "
		else if(vars.metadata.columns[key]['DATA_TYPE'] == 'DATE' and !isEmpty(vars.metadata.columns[key]['DATA_TYPE'])) 
			key ++ "\" TO_DATE(SUBSTR(:" ++ key ++ ",1,10), 'YYYY/MM/DD')\"" 
		else if(vars.metadata.columns[key]['DATA_DEFAULT'] != null and vars.metadata.columns[key]['DATA_TYPE'] == 'VARCHAR2') 
			key ++ " " ++ "\"nvl(:" ++ key ++ ", '" ++ vars.metadata.columns[key]['DATA_DEFAULT'] ++ "')\"" 
		else if(vars.metadata.columns[key]['DATA_DEFAULT'] == null and vars.metadata.columns[key]['DATA_TYPE'] == 'VARCHAR2' and vars.metadata.columns[key]['IS_NULLABLE'] == 'N') 
			key ++ " " ++ "\"nvl(:" ++ key ++ ", ' ')\""	
		else 
			key
	}
).*key joinBy (',')
var result = (seqs map {
	'vals': columns ++ ',' ++ ($)
}).vals joinBy (',') default columns
---
"options(skip = 1, errors=999999999," ++ "bindsize=" ++ p("sqlldr.bindsize") ++ ",readsize=" ++ p("sqlldr.readsize") ++", parallel=true) load data CHARACTERSET " ++ p("sqlldr.charactersetname") ++ " infile '" ++ (vars.deleteCSVPath) ++ "' " ++ " append into table " ++ p('scpo.schema.staging.' ++ lower(vars.tableName) ++ '.update') ++ " fields terminated by ',' optionally enclosed by '|' TRAILING NULLCOLS (" ++ result ++ ")"
