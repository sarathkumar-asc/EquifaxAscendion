public class AccountFieldMetadata {
  @AuraEnabled(cacheable=true)
    public static List<String> getAccountFields() {
        List<String> fieldNames = new List<String>();
    Set<String> durableIds = new Set<String>();
        
        List<Clone_Field_Set__mdt> metadataRecords = [SELECT Field_Name__c FROM Clone_Field_Set__mdt WHERE Object_Name__c = 'Account'];

        for (Clone_Field_Set__mdt record : metadataRecords) {
            if (String.isNotBlank(record.Field_Name__c) && record.Field_Name__c.contains('.')) {
                durableIds.add(record.Field_Name__c);
            }
        }
        
        if (!durableIds.isEmpty()) {
            for (FieldDefinition fieldDef : [SELECT Id, QualifiedApiName, DurableId 
                                            FROM FieldDefinition 
                                            WHERE EntityDefinition.QualifiedApiName = 'Account' 
                                            AND DurableId IN :durableIds]) {
        fieldNames.add(fieldDef.QualifiedApiName);
            }
        }
        //system.debug('Extracted Field Names: ' + fieldNames);
        return fieldNames;
    }
}