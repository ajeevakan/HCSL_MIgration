<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Activity_Complete_Date_to_Today</fullName>
        <field>Activity_Complete_Date__c</field>
        <formula>Today()</formula>
        <name>Set Activity Complete Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_Complete</fullName>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>Set Status Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Complete_to_Activity_Date</fullName>
        <field>Activity_Complete_Date__c</field>
        <formula>ActivityDate</formula>
        <name>Set Task Complete to Activity Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Subject</fullName>
        <field>Subject</field>
        <formula>text(Activity_Type__c)</formula>
        <name>Set Task Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Status Complete</fullName>
        <actions>
            <name>Set_Status_Complete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Result_Code__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Subject</fullName>
        <actions>
            <name>Set_Task_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Activity_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Task Complete Date On Create</fullName>
        <actions>
            <name>Set_Task_Complete_to_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Is_Pending__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Activity_Complete_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Task Complete Date on Update</fullName>
        <actions>
            <name>Set_Activity_Complete_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISNEW()) &amp;&amp; NOT(Is_Pending__c) &amp;&amp; ISCHANGED( Is_Pending__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
