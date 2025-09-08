public class AccountCloneController { 
    
    public Metadata.Layout accLayout {get; set;} //layout
    public Account myAcc {get;set;}
    public Id idToClone;
    
    public Metadata.UiBehavior editEnum {
        get{ return Metadata.UiBehavior.Edit; }
    }
    public Metadata.UiBehavior requiredEnum {
        get{ return Metadata.UiBehavior.Required; }
    }
    public Metadata.UiBehavior readOnlyEnum {
        get{ return Metadata.UiBehavior.Readonly; }
    }
    public List<String> billingAddressFields {get; set;}
    public List<String> shippingAddressFields {get; set;}
    
    public AccountCloneController(ApexPages.StandardController controller){
        idToClone = ((Account)controller.getRecord()).Id;
        
        try{
            myAcc = new Account();
            billingAddressFields = new List<String>{'BillingStreet','BillingCity','BillingState','BillingPostalCode','BillingCountry'};
            shippingAddressFields = new List<String>{'ShippingStreet','ShippingCity','ShippingState','ShippingPostalCode','ShippingCountry'};
            
            List<String> accFieldsToClone = AccountFieldMetadata.getAccountFields();
            //system.debug('accFieldsToClone'+accFieldsToClone);
            String query = 'SELECT ' + String.join(accFieldsToClone, ', ')
                + ' FROM Account'
                + ' WHERE Id = :idToClone LIMIT 1';
            
            List<Account> oldAcc = Database.query(String.escapeSingleQuotes(query), AccessLevel.SYSTEM_MODE);
            if(oldAcc.size() > 0 && accFieldsToClone.size() > 0){
                for(String fieldName : accFieldsToClone){
                    myAcc.put(fieldName, oldAcc[0].get(fieldName));                    
                }
                myAcc.put('Clone_Account_Id__c', idToClone); 
            }
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(
                Metadata.MetadataType.Layout, 
                new String[]{ System.Label.Account_Layout }
            );
            accLayout = (Metadata.Layout) layouts.get(0);
            
            List<Metadata.LayoutSection> sections = new  List<Metadata.LayoutSection>();
            sections.addAll(accLayout.layoutSections);
            
            for(Metadata.LayoutSection section: sections){
                Integer firstColLength = 0;
                Integer secondColLength = 0;
                Integer colIndex = 1;
                if (section.layoutColumns != null && section.layoutColumns.size() > 0) { 
                    for(Metadata.LayoutColumn col: section.layoutColumns){
                        List<Metadata.LayoutItem> itemList = col.layoutItems;
                        if(itemList != null && itemList.size() > 0){
                            if(colIndex == 1)
                                firstColLength = col.layoutItems.size();
                            if(colIndex == 2)
                                secondColLength = col.layoutItems.size();
                            colIndex = colIndex + 1;
                        }
                    }
                }
                Integer finalLength = (math.max(firstColLength, secondColLength)) * 2;
                if(finalLength == 0){
                    continue;
                }
                Metadata.LayoutColumn columns = new  Metadata.LayoutColumn();
                List<Metadata.LayoutItem> colItems = new  Metadata.LayoutItem[finalLength+10];
                integer i = 0;
                firstColLength = 0;
                secondColLength = 0;
                
                for(integer itemNo=0;itemNo < finalLength ; itemNo++){
                    colItems.set(itemNo, newLayoutItem());
                }
                
                for(Metadata.LayoutColumn col: section.layoutColumns){
                    if (col != null && col.layoutItems != null && !col.layoutItems.isEmpty()) {
                        for(Metadata.LayoutItem item: col.layoutItems){
                            if(item.field == 'BillingAddress'){
                                for(String str : billingAddressFields){
                                    Metadata.LayoutItem curItem = newLayoutItem();
                                    curItem.field = str;
                                    curItem.emptySpace = null;
                                    curItem.behavior = Metadata.UiBehavior.Edit;
                                    colItems.set(i, curItem);
                                    i = i+2;
                                }
                            }
                            else if(item.field == 'ShippingAddress'){
                                for(String str : shippingAddressFields){
                                    Metadata.LayoutItem curItem = newLayoutItem();
                                    curItem.field = str;
                                    curItem.emptySpace = null;
                                    curItem.behavior = Metadata.UiBehavior.Edit;
                                    colItems.set(i, curItem);
                                    i = i+2;
                                }
                            }
                            else{
                                colItems.set(i, item);
                                i = i+2;
                            }
                        }
                        if(math.mod(i,2) == 0){
                            firstColLength = i;
                        }
                        else{
                            secondColLength = i;
                        }
                        i=1;
                    }
                }
                Integer maxLength = math.max(firstColLength, secondColLength);
                Integer colItemLength = colItems.size();
                
                while (maxLength <= colItemLength) {
                    //System.debug(colItemLength);
                    colItemLength--;
                    colItems.remove(colItemLength);
                }
                
                columns.layoutItems = colItems;
                section.layoutColumns = new  List<Metadata.LayoutColumn>();
                section.layoutColumns.add(columns);
            }
            
            accLayout.layoutSections = sections;
        }catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
        }
    }
    
    public Metadata.LayoutItem newLayoutItem(){
        Metadata.LayoutItem layoutItem = new Metadata.LayoutItem();
        layoutItem.analyticsCloudComponent=null;
        layoutItem.behavior=null;
        layoutItem.canvas=null;
        layoutItem.component=null;
        layoutItem.customLink=null;
        layoutItem.emptySpace=true;
        layoutItem.field=null;
        layoutItem.height=null;
        layoutItem.page_x=null;
        layoutItem.reportChartComponent=null;
        layoutItem.scontrol=null;
        layoutItem.showLabel=null;
        layoutItem.showScrollbars=null;
        layoutItem.width=null;
        
        return layoutItem;
    }
    
    public pagereference saveRecord(){
        try {
            insert myAcc;
            // Send the user to the detail page for the new account.
            PageReference acctPage = new ApexPages.StandardController(myAcc).view();
            acctPage.setRedirect(true);
            return acctPage;
        } catch (Exception e) {
            String errormsg = e.getMessage().substringAfterLast(',').substringBeforeLast(':');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + errormsg ));
            return null;  
        }
    }
    // Cancel method - Redirects to Account record page
    public PageReference cancel() {
        // Redirect to the Account home page or record view
        PageReference pageRef = new PageReference('/' + idToClone); // Redirect to specific Account record
        pageRef.setRedirect(true);
        return pageRef;
    }
}