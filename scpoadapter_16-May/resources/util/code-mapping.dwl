%dw 2.0
output application/java
var codeMapPayload = payload."code-map-configuration".*"code-map" map {($.@name): $.*code map {($.@key): $.@value}}
---
{
	UOMIsoConversion: flatten (codeMapPayload.UOMIsoConversion),
	UOMConversion: flatten (codeMapPayload.UOMConversion),
	hierarchyLevelConversion: flatten (codeMapPayload.hierarchyLevelConversion),
	histStreamConversion: flatten (codeMapPayload.histStreamConversion),
	typeCodeToLocTypeConversion: flatten (codeMapPayload.typeCodeToLocTypeConversion),
	parentRoleToLocTypeConversion: flatten (codeMapPayload.parentRoleToLocTypeConversion),
	uomToCategoryTypeConversion: flatten (codeMapPayload.uomToCategoryTypeConversion),
	calendartypeCodeToSCPOTypeConversion: flatten (codeMapPayload.calendartypeCodeToSCPOTypeConversion),
	uomCategoryToSCPOTypeConversion: flatten (codeMapPayload.uomCategoryToSCPOTypeConversion),
	hierarchyLevels: flatten(codeMapPayload.hierarchyLevels)
}