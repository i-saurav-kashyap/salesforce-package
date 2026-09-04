@IsTest
private class ServiceRequestServiceTest {

    @IsTest
    static void createsRequestWithSlaDueDate() {
        ServiceRequestService.RequestInput input = new ServiceRequestService.RequestInput();
        input.summary = 'Generator will not start';

        Test.startTest();
        Id newId = ServiceRequestService.createRequest(input);
        Test.stopTest();

        Service_Request__c saved = [
            SELECT Status__c, Priority__c, Due_Date__c, Requested_On__c
            FROM Service_Request__c WHERE Id = :newId
        ];
        Assert.areEqual('New', saved.Status__c, 'New requests start in New');
        Assert.areEqual(OpsSettings.defaultPriority(), saved.Priority__c, 'Falls back to configured default priority');
        Assert.areEqual(Date.today().addDays(OpsSettings.slaDays()), saved.Due_Date__c, 'Due date is derived from the SLA setting');
    }

    @IsTest
    static void rejectsBlankSummary() {
        ServiceRequestService.RequestInput input = new ServiceRequestService.RequestInput();
        input.summary = '   ';
        try {
            ServiceRequestService.createRequest(input);
            Assert.fail('Expected a ServiceRequestException');
        } catch (ServiceRequestService.ServiceRequestException e) {
            Assert.areEqual(Label.Ops_Summary_Required, e.getMessage(), 'User-facing message comes from a custom label');
        }
    }

    @IsTest
    static void completeMarksRequestsCompleted() {
        Service_Request__c sr = new Service_Request__c(
            Summary__c = 'Replace filter', Status__c = 'New', Requested_On__c = Date.today()
        );
        insert sr;

        Test.startTest();
        ServiceRequestService.complete(new Set<Id>{ sr.Id });
        Test.stopTest();

        Assert.areEqual('Completed', [SELECT Status__c FROM Service_Request__c WHERE Id = :sr.Id].Status__c);
    }

    @IsTest
    static void selectorReturnsOnlyOpenRequests() {
        insert new List<Service_Request__c>{
            new Service_Request__c(Summary__c = 'Open one',  Status__c = 'New',       Requested_On__c = Date.today()),
            new Service_Request__c(Summary__c = 'Closed one', Status__c = 'Completed', Requested_On__c = Date.today())
        };

        List<Service_Request__c> open = new ServiceRequestSelector().openRequests(10);

        Assert.areEqual(1, open.size(), 'Completed requests must be excluded');
        Assert.areEqual('Open one', open[0].Summary__c);
    }

    @IsTest
    static void sortFieldIsAllowListed() {
        insert new Service_Request__c(Summary__c = 'Sortable', Status__c = 'New', Requested_On__c = Date.today());
        // A hostile sort field must be ignored rather than injected into the query.
        List<Service_Request__c> rows =
            new ServiceRequestSelector().openRequestsSorted('Name FROM Account WHERE Id != null--', true);
        Assert.areEqual(1, rows.size(), 'Query still runs against Service_Request__c only');
    }

    @IsTest
    static void settingsFallBackWhenNoRecord() {
        OpsSettings.overrideForTest = new Ops_Setting__mdt(SLA_Days__c = null, Default_Priority__c = null);
        Assert.areEqual(5, OpsSettings.slaDays());
        Assert.areEqual('Medium', OpsSettings.defaultPriority());
    }
}
