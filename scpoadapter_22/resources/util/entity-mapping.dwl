%dw 2.0
output application/java
---
	(vars.entities)."entity-map-configuration".*"entity-map" map {
		($.@scpoEntityName) : $.*table map { 
			(($.@name) : $.*column map {
			hostColumnName: $.@hostColumnName,
			scpoColumnName: $.@scpoColumnName,
			($.@hostColumnName) : $.@scpoColumnName,
			($.@scpoColumnName) : $.@hostColumnName,
			dataType: if ($.@dataType != null) upper($.@dataType) else null
			}) if ($.*column != null and $.@isUDT != "true" and $.@isOutBound != "true") 
		} 
	}