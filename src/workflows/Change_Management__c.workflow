<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Cr_is_created_and_submit_for_approval_initially</fullName>
        <description>Cr is created and submit for approval initially</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_Approval_request</template>
    </alerts>
    <alerts>
        <fullName>Email_to_CR_Owner_on_approvingg_Task</fullName>
        <description>Email to CR Owner on approvingg Task</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>ParentOwner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/Task_Approvedd</template>
    </alerts>
    <alerts>
        <fullName>Notify_Approver_for_changing_owner_of_CR_Task</fullName>
        <description>Notify Approver for changing owner of CR Task</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_ChangeOwnerApproval</template>
    </alerts>
    <alerts>
        <fullName>Notify_CR_owner_on_creation_of_change_request</fullName>
        <description>Notify CR owner on creation of change request</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_Creation</template>
    </alerts>
    <alerts>
        <fullName>Notify_when_change_owner_is_Recalled</fullName>
        <description>Notify when change owner is Recalled</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_ChangeOwnerApprovalRecall</template>
    </alerts>
    <alerts>
        <fullName>Notify_when_change_owner_is_Rejected</fullName>
        <description>Notify when change owner is Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_TaskChangeOwnerRejection</template>
    </alerts>
    <alerts>
        <fullName>Notify_when_change_owner_is_approved</fullName>
        <description>Notify when change owner is approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_Task_Change_Owner_approved</template>
    </alerts>
    <alerts>
        <fullName>Recalling_CR_task_from_approval</fullName>
        <description>Recalling CR task from  approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Qualityze_Emails/CR_TaskApprovalRecall</template>
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
        <fullName>Approval_Process_Com</fullName>
        <field>Approver_process_complete__c</field>
        <literalValue>0</literalValue>
        <name>Approval Process Com</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Update</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Approval Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CM_Approval_Process_Com</fullName>
        <field>Approver_process_complete__c</field>
        <literalValue>0</literalValue>
        <name>CM Approval Process Com</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CM_Approval_Process_Complete</fullName>
        <field>Approver_process_complete__c</field>
        <literalValue>0</literalValue>
        <name>CM Approval Process Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CRTaskStatusOpen</fullName>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>CRTaskStatusOpen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeFieldApprovalStatus_Pending_Approv</fullName>
        <field>ChangeFieldApprovalStatus__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>ChangeFieldApprovalStatus Pending Approv</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeFieldApprovalStatus_Recalled</fullName>
        <field>ChangeFieldApprovalStatus__c</field>
        <literalValue>Recall</literalValue>
        <name>ChangeFieldApprovalStatus Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeFieldApprovalStatus_Rejected</fullName>
        <field>ChangeFieldApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>ChangeFieldApprovalStatus Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeFieldApprovalStatuss_Rejected</fullName>
        <field>ChangeFieldApprovalStatus__c</field>
        <literalValue>Rejected</literalValue>
        <name>ChangeFieldApprovalStatuss Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeManagementStatus</fullName>
        <field>Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>ChangeManagementStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Initial_Phase_Draft</fullName>
        <description>Initial Phase Draft</description>
        <field>Phase__c</field>
        <literalValue>Draft</literalValue>
        <name>Initial Phase Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_CR_Record</fullName>
        <field>isLocked__c</field>
        <literalValue>1</literalValue>
        <name>Lock CR Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lock_record_CR</fullName>
        <field>isLocked__c</field>
        <literalValue>1</literalValue>
        <name>Lock record CR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OnRecallCrSequencenumberr</fullName>
        <field>CurrentApprovalSequenceNumber__c</field>
        <formula>99999</formula>
        <name>OnRecallCrSequencenumberr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OnRejectionCRsequenceNumberr</fullName>
        <field>CurrentApprovalSequenceNumber__c</field>
        <formula>99999</formula>
        <name>OnRejectionCRsequenceNumberr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OnrecallCRsequenceNumber</fullName>
        <field>currenappSequenceNumber__c</field>
        <formula>9999</formula>
        <name>OnrecallCRsequenceNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RecallStatus</fullName>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>RecallStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Started_Approval_Process</fullName>
        <field>Approver_process_complete__c</field>
        <literalValue>0</literalValue>
        <name>Started Approval Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_CM_Record</fullName>
        <field>isLocked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock CM Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unlock_Record_CM</fullName>
        <field>isLocked__c</field>
        <literalValue>0</literalValue>
        <name>Unlock Record CM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateApprovalRequired</fullName>
        <field>Approval_Required__c</field>
        <literalValue>Yes</literalValue>
        <name>UpdateApprovalRequired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>final_recall_data</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>Recall</literalValue>
        <name>final recall data</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>final_rejection</fullName>
        <field>ApprovalStatus__c</field>
        <literalValue>rejected</literalValue>
        <name>final rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>onrejectionCRSequenceNumber</fullName>
        <field>currenappSequenceNumber__c</field>
        <formula>9999</formula>
        <name>onrejectionCRSequenceNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatePhasefieldonRecall</fullName>
        <field>Phase__c</field>
        <literalValue>Review</literalValue>
        <name>updatePhasefieldonRecall</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatePhasefieldonRejectionupdatePhasefi</fullName>
        <field>Phase__c</field>
        <literalValue>Workflow</literalValue>
        <name>updatePhasefieldonRejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_status_when_approval_is_checked</fullName>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>update status when approval is checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatephasefieldfinally</fullName>
        <field>Phase__c</field>
        <literalValue>Workflow</literalValue>
        <name>updatephasefieldfinally</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatephasefieldinitially</fullName>
        <field>Phase__c</field>
        <literalValue>Review</literalValue>
        <name>updatephasefieldinitially</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatestatuswhenNoResolutionSelected</fullName>
        <field>Status__c</field>
        <literalValue>Open</literalValue>
        <name>updatestatuswhenNoResolutionSelected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Initial Phase</fullName>
        <actions>
            <name>Initial_Phase_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Change_Management__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <criteriaItems>
            <field>Change_Management__c.Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>send email to CR owner on creation of CR</fullName>
        <actions>
            <name>Notify_CR_owner_on_creation_of_change_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Management__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Document,Process,Product</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
