@isTest
private class AccountCloneController_Test {
    @isTest
    static void testAccountCloneController() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Patron_Code__c = '123123',
            Account_633__c = 'BNSFLOGLLC',
            Gov_t_Entity__c = true,
            Owns_Equipment__c = true,
            Elevated_Account__c = 'Y',
            DUNS_Number_HQ__c = '001024314',
            DB_Parent_Name__c = 'Test INC',
            Agency_Name__c = 'Test INC',
            Agency_Id__c = '100091'
        );
        insert testAccount;

        // Set the record ID in the VF page context
        Test.setCurrentPageReference(new PageReference('/apex/AccountCloneController ?recordId=' + testAccount.Id));

        // Create the Standard Controller and Custom Controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        AccountCloneController  controller = new AccountCloneController (sc);
        Integer initialAccountCount = [SELECT COUNT() FROM Account];
        
        // Simulate Saving the Cloned Account
        Test.startTest();
        PageReference result = controller.saveRecord();
        Test.stopTest();

        //Validate that a new Account has been inserted and test whether the fields cloned correctly using asserts 
        Integer finalAccountCount = [SELECT COUNT() FROM Account];
        System.assertEquals(initialAccountCount + 1, finalAccountCount, 'A new cloned Account should be inserted');

        Account clonedRecord = [SELECT Id, Name, Account_633__c FROM Account WHERE Id != :testAccount.Id ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(testAccount.Account_633__c, clonedRecord.Account_633__c, 'Account_633__c should be cloned correctly');
    }
    @isTest
    static void testCancelMethod() {
        Account testAccount = new Account(Name = 'Test Account1', Patron_Code__c = '123123');
        insert testAccount;

        Test.setCurrentPageReference(new PageReference('/apex/AccountCloneController?recordId=' + testAccount.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        AccountCloneController controller = new AccountCloneController(sc);
        PageReference result1 = controller.cancel();
        System.assertEquals(result1.getUrl(), '/' + testAccount.Id, 'Cancel method should redirect to record page');
    }
}