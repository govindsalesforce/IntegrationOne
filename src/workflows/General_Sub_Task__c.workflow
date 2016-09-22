<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_alert_when_Action_Plan_is_in_Pending</fullName>
        <description>Email alert when Action Plan is in Pending</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/Email_for_Action_Plan_Status_update_as_Pending</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_when_disposition_is_in_pending_status</fullName>
        <description>Email alert when disposition is in pending status</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/Pending_Disposition</template>
    </alerts>
    <fieldUpdates>
        <fullName>Completed_Status</fullName>
        <description>Completed Status</description>
        <field>Action_Plan_Status__c</field>
        <literalValue>Complete</literalValue>
        <name>Completed Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_Status</fullName>
        <field>Action_Plan_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Pending Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Action Plan Status Update as Completed</fullName>
        <actions>
            <name>Completed_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>General_Sub_Task__c.Complete__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>General_Sub_Task__c.Pend_Save_ActionPlan__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>General_Sub_Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Action Plan</value>
        </criteriaItems>
        <description>Action Plan Status Update as Completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Action Plan Status update as Pending</fullName>
        <actions>
            <name>Pending_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>General_Sub_Task__c.Complete__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>General_Sub_Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Action Plan</value>
        </criteriaItems>
        <description>Action Plan Status update as Pending</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pending Action Plan for CAPA</fullName>
        <active>true</active>
        <description>Pending Action Plan for CAPA</description>
        <formula>AND(OR( AND( General_Task__r.Approval_Process_Complete__c , ISPICKVAL(Complete__c,&apos;No&apos;) , ISPICKVAL(Submit_WithOut_Approval__c ,&apos;NO&apos;)),AND(ISPICKVAL( General_Task__r.Approval_Required__c,&apos;No&apos;),ISPICKVAL( Complete__c ,&apos;No&apos;),ISPICKVAL(Submit_WithOut_Approval__c ,&apos;Yes&apos;),ISPICKVAL( General_Task__r.isSubmitted__c ,&apos;True&apos;)) ), true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pending Action Plan%2E</fullName>
        <actions>
            <name>Email_alert_when_Action_Plan_is_in_Pending</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email for Pending Action Plan.</description>
        <formula>AND(OR( AND( General_Task__r.Approval_Process_Complete__c , ISPICKVAL(Complete__c,&apos;No&apos;) , ISPICKVAL(Submit_WithOut_Approval__c ,&apos;NO&apos;)),AND(ISPICKVAL( General_Task__r.Approval_Required__c,&apos;No&apos;),ISPICKVAL( Complete__c ,&apos;No&apos;),ISPICKVAL(Submit_WithOut_Approval__c ,&apos;Yes&apos;),ISPICKVAL( General_Task__r.isSubmitted__c ,&apos;True&apos;)) ) , RecordType.Id == $Setup.QC_settings__c.Action_Plan_RecordTypeId__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pending Disposition</fullName>
        <actions>
            <name>Email_alert_when_disposition_is_in_pending_status</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(OR(AND(General_Task__r.Approval_Process_Complete__c ,  ISPICKVAL(Disposition_Type_Status__c , &apos;Pending&apos;) , ISPICKVAL(Approval_Completed__c,&apos;Yes&apos;) ), AND(  ISPICKVAL(General_Task__r.Approval_Required__c,&apos;No&apos;) ,ISPICKVAL(Disposition_Type_Status__c , &apos;Pending&apos;), ISPICKVAL(General_Task__r.isSubmitted__c,&apos;True&apos;) ,ISPICKVAL(Approval_Completed__c,&apos;No&apos;)) ), RecordType.Id == $Setup.QC_settings__c.Disposition_Section_RecordTypeId__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
