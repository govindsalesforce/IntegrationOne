<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_NC_Owner_regarding_new_NC_Creation</fullName>
        <description>Notify NC Owner regarding new NC Creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/NC_Creation</template>
    </alerts>
    <fieldUpdates>
        <fullName>NC_Status_update_to_NC_Workflow</fullName>
        <field>NC_Status__c</field>
        <literalValue>NC Workflow</literalValue>
        <name>NC Status update to NC Workflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_NC_Stage_to_Closed</fullName>
        <field>NC_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Update NC Stage to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>NC Status update</fullName>
        <actions>
            <name>Update_NC_Stage_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Non_Conformance__c.NC_Resolution_Code__c</field>
            <operation>equals</operation>
            <value>No Action Required,Discarded,Addressed through CAPA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Non_Conformance__c.NC_Status__c</field>
            <operation>notEqual</operation>
            <value>Closed,Reopened</value>
        </criteriaItems>
        <description>If NC resolution code is No Action Required,Discarded or Addressed through CAPA option is selected, then NC is closed with Status changed to “CLOSED”</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send email to NC Owner upon NC creation</fullName>
        <actions>
            <name>Notify_NC_Owner_regarding_new_NC_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Non_Conformance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Conformance</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
