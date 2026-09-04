/**
 * Read-only accessor for packaged configuration held in Ops_Setting__mdt.
 *
 * Why Custom Metadata and not a Custom Setting?
 *  - CMDT rows are deployable and packageable, so defaults ship WITH the package
 *    and can be updated by a package upgrade.
 *  - CMDT reads do not count against SOQL limits when accessed via getInstance().
 *
 * `global` is deliberate: subscriber orgs and downstream packages call this, and
 * anything not marked global is invisible outside the package namespace.
 * Remember: once global is released, its signature can never change.
 */
global with sharing class OpsSettings {
    @TestVisible
    private static Ops_Setting__mdt overrideForTest;

    global static Integer slaDays() {
        Ops_Setting__mdt s = current();
        return s == null || s.SLA_Days__c == null ? 5 : Integer.valueOf(s.SLA_Days__c);
    }

    global static String defaultPriority() {
        Ops_Setting__mdt s = current();
        return s == null || String.isBlank(s.Default_Priority__c) ? 'Medium' : s.Default_Priority__c;
    }

    private static Ops_Setting__mdt current() {
        if (overrideForTest != null) {
            return overrideForTest;
        }
        // getInstance() does not consume a SOQL query.
        return Ops_Setting__mdt.getInstance('Default');
    }
}
