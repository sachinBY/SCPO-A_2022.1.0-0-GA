%dw 2.0
output application/java
---
	(vars.entities)."entity-map-configuration".*"entity-map" map {
		($.@scpoEntityName) : $.*table map (table , index) -> { 
			((table.@name) : table.*column map {
			hostColumnName: $.@hostColumnName,
			scpoColumnName: $.@scpoColumnName,
			($.@hostColumnName) : $.@scpoColumnName,
			($.@scpoColumnName) : $.@hostColumnName,
			dataType: if ($.@dataType != null) upper($.@dataType) else null
			}) if (table.*column != null and table.@isUDT != "true" and table.@isOutBound == "true") 
		} 
	}