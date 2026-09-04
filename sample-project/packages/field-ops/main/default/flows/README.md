# Flows in this package

The record-triggered flow for this course is built in Flow Builder, not hand-authored,
because hand-written Flow XML breaks in ways that are painful to debug.

Build it once in your scratch org, then retrieve it into this folder:

    sf project retrieve start --metadata Flow:Ops_Set_Due_Date --target-org dev1

## Flow spec: `Ops_Set_Due_Date`

* Object: `Service_Request__c`
* Trigger: **A record is created**  (fast field update / before-save)
* Entry condition: `Due_Date__c` is null
* Action: assign `Due_Date__c` = `{!$Record.Requested_On__c}` + SLA days

Notes for packaging:

* A subscriber **cannot edit** a packaged flow. Anything you expect customers to
  change belongs in Custom Metadata (see `Ops_Setting__mdt`), not in flow logic.
* A packaged active flow is deployed active in the subscriber org. Deactivating a
  flow in a later package version is allowed; deleting it is not straightforward.
* Prefer before-save flows for field defaulting: no DML, far cheaper than a trigger.
