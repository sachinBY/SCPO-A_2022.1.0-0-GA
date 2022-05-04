%dw 2.0
fun replaceWithDefaultValue(metadata, column_name) = metadata.columns[column_name]["DATA_DEFAULT"]
---
replaceWithDefaultValue: replaceWithDefaultValue 