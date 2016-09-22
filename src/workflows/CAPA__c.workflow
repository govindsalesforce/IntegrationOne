<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_CAPA_owner_regarding_new_CAPA_creation</fullName>
        <description>Notify CAPA owner regarding new CAPA creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CAPA_Creation</template>
    </alerts>
    <fieldUpdates>
        <fullName>CAPA_Approval_Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CAPA Approval Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAPA_Approval_Status_Pending_Approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>CAPA Approval Status Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAPA_Approval_Status_Recalled</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recall</literalValue>
        <name>CAPA Approval Status Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CAPA_Approval_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>CAPA Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send email to CAPA owner upon CAPA Creation</fullName>
        <actions>
            <name>Notify_CAPA_owner_regarding_new_CAPA_creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CAPA__c.CAPA_Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
