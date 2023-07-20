<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Responded_Date</fullName>
        <field>Responded_Date__c</field>
        <formula>today()</formula>
        <name>Set Responded Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Responded Date</fullName>
        <actions>
            <name>Set_Responded_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Responded</value>
        </criteriaItems>
        <criteriaItems>
            <field>CampaignMember.Responded_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
