<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Date_of_Purge_is_Today</fullName>
        <description>Date of Purge is Today</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Purge_Date</template>
    </alerts>
    <alerts>
        <fullName>Doc_Record_approved</fullName>
        <description>Doc Record approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Approved</template>
    </alerts>
    <alerts>
        <fullName>Doc_Record_recalled</fullName>
        <description>Doc Record recalled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Approval_Recall</template>
    </alerts>
    <alerts>
        <fullName>Doc_Record_rejected</fullName>
        <description>Doc Record rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Doc_change_owner_approved</fullName>
        <description>Doc change owner approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Change_Owner_approved</template>
    </alerts>
    <alerts>
        <fullName>Doc_change_owner_recalled</fullName>
        <description>Doc change owner recalled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_ChangeOwnerRecall</template>
    </alerts>
    <alerts>
        <fullName>Doc_change_owner_rejected</fullName>
        <description>Doc change owner rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_ChangeOwnerRejection</template>
    </alerts>
    <alerts>
        <fullName>Document_made_current</fullName>
        <description>Document made current</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Made_Current</template>
    </alerts>
    <alerts>
        <fullName>Email_is_sent_out_to_the_document_owner_when_the_Effectiveness_Review_task_start</fullName>
        <description>Email is sent out to the document owner when the Effectiveness Review task start date is today’s date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Effectiveness_Review_Task</template>
    </alerts>
    <alerts>
        <fullName>Notify_DOC_owner_on_creation_of_DOC</fullName>
        <description>Notify DOC owner on creation of DOC</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Creation</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Authorize_user_and_doc_owner_when_security_is_enabled</fullName>
        <description>Send email to Authorize user and doc owner when security is enabled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Security_Enabled</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Document_owner_when_collaboration_review_starts</fullName>
        <description>Send email to Document owner when collaboration review starts</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Collaboration_Review</template>
    </alerts>
    <alerts>
        <fullName>Send_email_when_effectiveness_review_started</fullName>
        <description>Send email when effectiveness review started</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/DOC_Effectiveness_Review_Task</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Process_Change_Owner</fullName>
        <field>ApprovalProcess__c</field>
        <literalValue>Change Owner</literalValue>
        <name>Approval Process Change Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Process_Document_Approval</fullName>
        <field>ApprovalProcess__c</field>
        <literalValue>Document Approval</literalValue>
        <name>Approval Process Document Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Pending_Approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Approval Status Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Recalled</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recall</literalValue>
        <name>Approval Status Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Approval Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Custom_Lock</fullName>
        <field>isLocked__c</field>
        <literalValue>1</literalValue>
        <name>Custom Lock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Custom_Unlock</fullName>
        <field>isLocked__c</field>
        <literalValue>0</literalValue>
        <name>Custom Unlock</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Doc_pending_approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Doc pending approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Document_status_Recalled</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recall</literalValue>
        <name>Document status Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Document_status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Document status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Document_status_approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Document status approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>On_Recall_SequenceNumber</fullName>
        <field>CurrentApprovalSequenceNumber__c</field>
        <formula>99999</formula>
        <name>On Recall SequenceNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PreReleasedDateCalculation1</fullName>
        <field>PreRelease_Duration_Date__c</field>
        <formula>Submitted_Date__c + Grace_Period_for_Release__c</formula>
        <name>PreReleasedDateCalculation1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PreReleasedDateCalculation2</fullName>
        <field>PreRelease_Duration_Date__c</field>
        <formula>Approved_Date__c + Grace_Period_for_Release__c</formula>
        <name>PreReleasedDateCalculation2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PreReleasedDateCalculation3</fullName>
        <field>PreRelease_Duration_Date__c</field>
        <formula>Submitted_Date__c</formula>
        <name>PreReleasedDateCalculation3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusNewUpdate</fullName>
        <field>Status__c</field>
        <literalValue>Prerelease</literalValue>
        <name>StatusNewUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusNewUpdateCurrent</fullName>
        <field>Status__c</field>
        <literalValue>Current</literalValue>
        <name>StatusNewUpdateCurrent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>onrejectionSequenceNumber</fullName>
        <field>CurrentApprovalSequenceNumber__c</field>
        <formula>999999</formula>
        <name>onrejectionSequenceNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatestatus</fullName>
        <field>Status__c</field>
        <literalValue>Prerelease</literalValue>
        <name>updatestatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Date of Purge is Today</fullName>
        <actions>
            <name>Date_of_Purge_is_Today</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Document_Profile__c.Date_of_Purge__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Document Made current</fullName>
        <actions>
            <name>Document_made_current</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Document_Profile__c.Status__c</field>
            <operation>equals</operation>
            <value>Current</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Document Profile Number Updated</fullName>
        <active>false</active>
        <description>Document Profile Number Updates for Numberschema</description>
        <formula>Name = Id</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Document made prerealese or current</fullName>
        <actions>
            <name>Send_email_to_Authorize_user_and_doc_owner_when_security_is_enabled</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND 2) OR (1 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Document_Profile__c.Enable_Security__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Document_Profile__c.Status__c</field>
            <operation>equals</operation>
            <value>Prerelease</value>
        </criteriaItems>
        <criteriaItems>
            <field>Document_Profile__c.Status__c</field>
            <operation>equals</operation>
            <value>Current</value>
        </criteriaItems>
        <description>Send email to doc owner and users under Authorize entity and View only entity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send email to DOC owner on creation of DOC</fullName>
        <actions>
            <name>Notify_DOC_owner_on_creation_of_DOC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Document_Profile__c.Status__c</field>
            <operation>equals</operation>
            <value>Draft</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send email when Effectiveness Review date is Today</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Document_Profile__c.Effectiveness_Review_Date__c</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_email_when_effectiveness_review_started</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Document_Profile__c.Effectiveness_Review_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
