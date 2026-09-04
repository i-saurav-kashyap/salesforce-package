/**
 * All SOQL for Service_Request__c lives here.
 *
 * Security notes that matter for the AppExchange Security Review:
 *  - `with sharing` so record-level sharing of the SUBSCRIBER org is respected.
 *  - `WITH USER_MODE` makes the platform enforce object and field level security
 *    on the query itself, so a user without FLS on Due_Date__c gets an error
 *    rather than silently reading data they should not see.
 *  - Bind variables (:accountId) instead of string concatenation: no SOQL injection.
 */
public with sharing class ServiceRequestSelector {

    private static final Set<String> SORTABLE = new Set<String>{
        'Name', 'Status__c', 'Priority__c', 'Due_Date__c', 'Requested_On__c'
    };

    public List<Service_Request__c> openRequests(Integer maxRows) {
        Integer safeLimit = maxRows == null || maxRows <= 0 || maxRows > 200 ? 50 : maxRows;
        return [
            SELECT Id, Name, Summary__c, Status__c, Priority__c,
                   Due_Date__c, Requested_On__c, Is_Overdue__c,
                   Account__c, Account__r.Name
            FROM Service_Request__c
            WHERE Status__c NOT IN ('Completed', 'Cancelled')
            WITH USER_MODE
            ORDER BY Due_Date__c ASC NULLS LAST
            LIMIT :safeLimit
        ];
    }

    public List<Service_Request__c> byAccount(Id accountId) {
        return [
            SELECT Id, Name, Summary__c, Status__c, Priority__c, Due_Date__c
            FROM Service_Request__c
            WHERE Account__c = :accountId
            WITH USER_MODE
            ORDER BY Requested_On__c DESC
            LIMIT 200
        ];
    }

    /**
     * Dynamic sorting done safely: the ORDER BY column is validated against an
     * allow-list, never taken from user input directly. String.escapeSingleQuotes
     * alone does NOT protect an ORDER BY clause.
     */
    public List<Service_Request__c> openRequestsSorted(String sortField, Boolean ascending) {
        String field = SORTABLE.contains(sortField) ? sortField : 'Due_Date__c';
        String direction = ascending == false ? 'DESC' : 'ASC';
        String soql =
            'SELECT Id, Name, Summary__c, Status__c, Priority__c, Due_Date__c ' +
            'FROM Service_Request__c ' +
            'WHERE Status__c NOT IN (\'Completed\', \'Cancelled\') ' +
            'ORDER BY ' + field + ' ' + direction + ' NULLS LAST LIMIT 200';
        return Database.query(soql, AccessLevel.USER_MODE);
    }
}
