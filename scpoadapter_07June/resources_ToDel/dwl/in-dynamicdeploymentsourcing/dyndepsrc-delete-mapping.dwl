%dw 2.0
output application/java
---
payload map(dynamicDeploymentSourcing, dynamicDeploymentSourcingIndex) -> {
	MS_BULK_REF: dynamicDeploymentSourcing.MS_BULK_REF,
	MS_REF: dynamicDeploymentSourcing.MS_REF,
	INTEGRATION_STAMP: dynamicDeploymentSourcing.INTEGRATION_STAMP,
	MESSAGE_TYPE: dynamicDeploymentSourcing.MESSAGE_TYPE,
  	MESSAGE_ID: dynamicDeploymentSourcing.MESSAGE_ID,
  	SENDER: dynamicDeploymentSourcing.SENDER,
	DEST:dynamicDeploymentSourcing.DEST,
	
	EFF:dynamicDeploymentSourcing.EFF,
	ITEM:dynamicDeploymentSourcing.ITEM,
	
	SOURCE:dynamicDeploymentSourcing.SOURCE,
	
		
	TRANSMODE:dynamicDeploymentSourcing.TRANSMODE,
	(vars.deleteudc): 'Y'

		
	  
		
}
