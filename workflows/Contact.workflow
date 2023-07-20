<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Home_Phone</fullName>
        <field>HomePhone</field>
        <formula>Phone</formula>
        <name>Set Home Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Home_Phone_to_Temp_Home_Phone</fullName>
        <field>HomePhone</field>
        <formula>Temp_Home_Phone__c</formula>
        <name>Set Home Phone to Temp Home Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Mobile_Phone_to_Phone</fullName>
        <field>MobilePhone</field>
        <formula>Phone</formula>
        <name>Set Mobile Phone to Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Mobile_Preferred</fullName>
        <field>Preferred_Phone__c</field>
        <literalValue>Mobile</literalValue>
        <name>Set Mobile Preferred</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_PhoneHome</fullName>
        <field>Preferred_Phone__c</field>
        <literalValue>Home</literalValue>
        <name>Set Preferred Phone Home</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_Phone_Home</fullName>
        <field>Preferred_Phone__c</field>
        <literalValue>Home</literalValue>
        <name>Set Preferred Phone Home</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_Phone_Work</fullName>
        <field>Preferred_Phone__c</field>
        <literalValue>Work</literalValue>
        <name>Set Preferred Phone Work</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Workphone</fullName>
        <field>Work_Phone__c</field>
        <formula>IF (ISBLANK(Phone), Work_Phone__c, Phone)</formula>
        <name>Set Workphone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Main_Phone</fullName>
        <field>Phone</field>
        <formula>IF (
(ISBLANK(TEXT(Preferred_Phone__c)) ||
ISPICKVAL(Preferred_Phone__c, &apos;Work&apos;)) &amp;&amp; NOT(ISBLANK(Work_Phone__c))
, Work_Phone__c,
IF(
(ISBLANK(TEXT(Preferred_Phone__c)) ||
ISPICKVAL(Preferred_Phone__c, &apos;Mobile&apos;)) &amp;&amp; NOT(ISBLANK(MobilePhone))
, MobilePhone,


IF(
(ISBLANK(TEXT(Preferred_Phone__c)) ||
ISPICKVAL(Preferred_Phone__c, &apos;Home&apos;)) &amp;&amp; NOT(ISBLANK(HomePhone))
, HomePhone,

if ( NOT(ISBLANK(Work_Phone__c)),
Work_Phone__c, If (NOT(ISBLANK(MobilePhone)), MobilePhone, IF(NOT(ISBLANK(HomePhone)),HomePhone, Phone) ) )

)

)
)</formula>
        <name>Update Main Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Map Temp Home Phone to Home Phone</fullName>
        <actions>
            <name>Set_Home_Phone_to_Temp_Home_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.HomePhone</field>
            <operation>equals</operation>
            <value>NULL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Temp_Home_Phone__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Home Phone Preferred</fullName>
        <actions>
            <name>Set_Preferred_PhoneHome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>((ISNEW() || ISCHANGED(HomePhone) || ISCHANGED (Work_Phone__c) || ISCHANGED (MobilePhone))   &amp;&amp; NOT(ISBLANK(HomePhone))) &amp;&amp; ( ISBLANK(TEXT ( Preferred_Phone__c ) ) &amp;&amp; ISBLANK(Work_Phone__c) &amp;&amp; ISBLANK(MobilePhone) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Home Phone When Phone Changed</fullName>
        <actions>
            <name>Set_Home_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Preferred_Phone_Home</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(ISNEW() || ISCHANGED( Phone )) &amp;&amp; NOT(ISBLANK(Phone)) &amp;&amp; ((ISBLANK(TEXT(Preferred_Phone__c)) || ISPICKVAL(Preferred_Phone__c, &apos;Home&apos;))   )    &amp;&amp; ( Phone != HomePhone || ISBLANK(HomePhone) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Main Phone</fullName>
        <actions>
            <name>Update_Main_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISBLANK(Phone) &amp;&amp; NOT (ISCHANGED (Phone)) &amp;&amp; (ISNEW() || ISCHANGED( HomePhone ) || ISCHANGED( Work_Phone__c ) || ISCHANGED( MobilePhone ) || ISCHANGED( Preferred_Phone__c ) ) &amp;&amp; ( NOT(ISBLANK(HomePhone)) || NOT(ISBLANK(Work_Phone__c)) || NOT(ISBLANK(MobilePhone)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Mobile Preferred</fullName>
        <actions>
            <name>Set_Mobile_Preferred</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>((ISNEW() || ISCHANGED(HomePhone) || ISCHANGED (Work_Phone__c) || ISCHANGED (MobilePhone)) &amp;&amp; NOT(ISBLANK(MobilePhone))) &amp;&amp; (( ISBLANK(Work_Phone__c) &amp;&amp; ISBLANK(TEXT ( Preferred_Phone__c ) ))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Mobile When Phone Changed</fullName>
        <actions>
            <name>Set_Mobile_Phone_to_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(ISNEW() || ISCHANGED( Phone )) &amp;&amp; NOT(ISBLANK(Phone)) &amp;&amp; ISPICKVAL(Preferred_Phone__c, &apos;Mobile&apos;) &amp;&amp; ( Phone != MobilePhone || ISBLANK(MobilePhone) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Work Phone Preferred</fullName>
        <actions>
            <name>Set_Preferred_Phone_Work</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>((ISNEW() || ISCHANGED(HomePhone) || ISCHANGED (Work_Phone__c) || ISCHANGED (MobilePhone))    &amp;&amp; NOT(ISBLANK(Work_Phone__c))) &amp;&amp;   ((ISBLANK(HomePhone) &amp;&amp; ISBLANK(MobilePhone) )  || ISBLANK(TEXT(Preferred_Phone__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Work Phone When Phone Changed</fullName>
        <actions>
            <name>Set_Workphone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(ISNEW() || ISCHANGED( Phone) ) &amp;&amp; NOT(ISBLANK(Phone)) &amp;&amp; ISPICKVAL(Preferred_Phone__c, &apos;Work&apos;) &amp;&amp; ( Phone != Work_Phone__c || ISBLANK(Work_Phone__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
