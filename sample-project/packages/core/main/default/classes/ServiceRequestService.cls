/**
 * Business logic for service requests. This is the class other packages call,
 * so its global surface is an API contract that must live forever.
 */
global with sharing class ServiceRequestService {

    global class ServiceRequestException extends Exception {}

    /** Simple DTO so callers (LWC, other packages) never depend on our SObject shape. */
    global class RequestInput {
        global String summary;
        global String priority;
        global Id accountId;
        global Date dueDate;
    }

    global static Id createRequest(RequestInput input) {
        if (input == null || String.isBlank(input.summary)) {
            throw new ServiceRequestException(Label.Ops_Summary_Required);
        }
        Service_Request__c sr = new Service_Request__c(
            Summary__c      = input.summary.trim(),
            Priority__c     = String.isBlank(input.priority) ? OpsSettings.defaultPriority() : input.priority,
            Status__c       = 'New',
            Account__c      = input.accountId,
            Requested_On__c = Date.today(),
            Due_Date__c     = input.dueDate != null ? input.dueDate : Date.today().addDays(OpsSettings.slaDays())
        );
        // USER_MODE makes the platform enforce CRUD + FLS on the DML for us.
        Database.SaveResult result = Database.insert(sr, true, AccessLevel.USER_MODE);
        return result.getId();
    }

    global static void complete(Set<Id> requestIds) {
        if (requestIds == null || requestIds.isEmpty()) {
            return;
        }
        List<Service_Request__c> toUpdate = new List<Service_Request__c>();
        for (Id requestId : requestIds) {
            toUpdate.add(new Service_Request__c(Id = requestId, Status__c = 'Completed'));
        }
        Database.update(toUpdate, true, AccessLevel.USER_MODE);
    }

    /** Convenience for other packages: is the running user able to use this app at all? */
    global static Boolean currentUserCanUse() {
        return Schema.SObjectType.Service_Request__c.isAccessible()
            && Schema.SObjectType.Service_Request__c.isCreateable();
    }
}
