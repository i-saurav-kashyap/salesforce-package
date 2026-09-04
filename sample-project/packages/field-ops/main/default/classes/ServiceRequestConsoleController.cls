/**
 * Controller for the serviceRequestConsole LWC.
 *
 * This class lives in the FIELD OPS package and calls global classes that live in
 * the CORE package. That single fact is what makes Field Ops depend on Core:
 * Salesforce resolves `ServiceRequestService` at compile time when the Field Ops
 * package version is built, and the version create fails if Core is not installed
 * into the build environment - which only happens because we declared the
 * dependency in sfdx-project.json.
 */
public with sharing class ServiceRequestConsoleController {

    @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> getOpenRequests(Integer maxRows) {
        try {
            if (!ServiceRequestService.currentUserCanUse()) {
                throw new AuraHandledException(Label.Ops_No_Access);
            }
            return new ServiceRequestSelector().openRequests(maxRows);
        } catch (Exception e) {
            // Never leak a raw stack trace to the UI of a subscriber org.
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createRequest(String summary, String priority, Id accountId, Date dueDate) {
        try {
            ServiceRequestService.RequestInput input = new ServiceRequestService.RequestInput();
            input.summary   = summary;
            input.priority  = priority;
            input.accountId = accountId;
            input.dueDate   = dueDate;
            return ServiceRequestService.createRequest(input);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void completeRequests(List<Id> requestIds) {
        try {
            ServiceRequestService.complete(new Set<Id>(requestIds));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
