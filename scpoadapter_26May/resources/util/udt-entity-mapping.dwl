%dw 2.0
output application/java
---
payload."entity-map-configuration".*"entity-map" map {
	($.@scpoEntityName) : $.*table map (table , index) -> {
		((table.@name) : table.*column map (column , index) -> {
			hostColumnName: column.@hostColumnName,
			scpoColumnName: column.@scpoColumnName,
			(column.@hostColumnName) : column.@scpoColumnName,
			(column.@scpoColumnName) : column.@hostColumnName,
			isPK: if (column.@isPK != null) column.@isPK else "false",
			dataType: if (column.@dataType != null) upper(column.@dataType) else null
		})if (table.*column != null and table.@isUDT == "true")
	}
}