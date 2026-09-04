@IsTest
private class ServiceRequestConsoleControllerTest {

    @TestSetup
    static void seed() {
        insert new List<Service_Request__c>{
            new Service_Request__c(Summary__c = 'Tower light out', Status__c = 'New',       Requested_On__c = Date.today(), Due_Date__c = Date.today().addDays(2)),
            new Service_Request__c(Summary__c = 'Done already',    Status__c = 'Completed', Requested_On__c = Date.today())
        };
    }

    @IsTest
    static void consoleReturnsOpenRequestsOnly() {
        List<Service_Request__c> rows = ServiceRequestConsoleController.getOpenRequests(50);
        Assert.areEqual(1, rows.size(), 'Only open requests reach the console');
    }

    @IsTest
    static void createFromConsole() {
        Test.startTest();
        Id newId = ServiceRequestConsoleController.createRequest('Broken gate', 'High', null, null);
        Test.stopTest();
        Assert.isNotNull(newId, 'Controller returns the new record id');
    }

    @IsTest
    static void blankSummarySurfacesAsAuraHandledException() {
        try {
            ServiceRequestConsoleController.createRequest('  ', 'High', null, null);
            Assert.fail('Expected AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e, 'LWC receives a handled exception, never a raw stack trace');
        }
    }

    @IsTest
    static void completeFromConsole() {
        Service_Request__c open = [SELECT Id FROM Service_Request__c WHERE Status__c = 'New' LIMIT 1];
        ServiceRequestConsoleController.completeRequests(new List<Id>{ open.Id });
        Assert.areEqual('Completed', [SELECT Status__c FROM Service_Request__c WHERE Id = :open.Id].Status__c);
    }
}
