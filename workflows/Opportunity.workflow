<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Opp_Name</fullName>
        <field>Name</field>
        <formula>LEFT(Opportunity_Name_Formula__c, 120)</formula>
        <name>Set Opp Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_Senior_Living</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Senior_Living</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type Senior Living</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Record_Type_Skilled_Nursing</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Skilled_Nursing</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set Record Type Skilled Nursing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Opp Name</fullName>
        <actions>
            <name>Set_Opp_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Name   &lt;&gt;  Left(Opportunity_Name_Formula__c, 120)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Record Type Skilled Nursing</fullName>
        <actions>
            <name>Set_Record_Type_Skilled_Nursing</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Skilled_Nursing__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Recordtype to Senior Living</fullName>
        <actions>
            <name>Set_Record_Type_Senior_Living</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Senior_Living__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
