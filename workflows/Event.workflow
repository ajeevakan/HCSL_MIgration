<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_EventActivity_Complete_Date_to_Today</fullName>
        <field>Activity_Complete_Date__c</field>
        <formula>Today()</formula>
        <name>Set EventActivity Complete Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Event_Complete_Date_to_Activity_Date</fullName>
        <field>Activity_Complete_Date__c</field>
        <formula>ActivityDate</formula>
        <name>Set Event Complete Date to Activity Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Event_Subject</fullName>
        <field>Subject</field>
        <formula>text(Activity_Type__c)</formula>
        <name>Set Event Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Event Activity Complete Date</fullName>
        <actions>
            <name>Set_EventActivity_Complete_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISNEW()) &amp;&amp; NOT(Is_Pending__c) &amp;&amp; ISCHANGED( Is_Pending__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Event Complete Date on Create</fullName>
        <actions>
            <name>Set_Event_Complete_Date_to_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Event.Is_Pending__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Activity_Complete_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Subject Event</fullName>
        <actions>
            <name>Set_Event_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Event.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Event.Activity_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
