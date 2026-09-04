// Sample data for a development scratch org. NEVER ship data like this in the package.
Account a = new Account(Name = 'Northwind Utilities');
insert a;

insert new List<Service_Request__c>{
    new Service_Request__c(Summary__c = 'Generator will not start', Status__c = 'New',
        Priority__c = 'Critical', Account__c = a.Id, Requested_On__c = Date.today(),
        Due_Date__c = Date.today().addDays(1)),
    new Service_Request__c(Summary__c = 'Replace air filter', Status__c = 'Scheduled',
        Priority__c = 'Low', Account__c = a.Id, Requested_On__c = Date.today().addDays(-3),
        Due_Date__c = Date.today().addDays(4)),
    new Service_Request__c(Summary__c = 'Annual inspection', Status__c = 'Completed',
        Priority__c = 'Medium', Account__c = a.Id, Requested_On__c = Date.today().addDays(-30))
};
System.debug(LoggingLevel.INFO, 'Seeded ' + [SELECT COUNT() FROM Service_Request__c] + ' requests');
