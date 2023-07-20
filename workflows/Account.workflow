<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Home_Phone</fullName>
        <field>PersonHomePhone</field>
        <formula>Phone</formula>
        <name>Set Home Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Home_Phone_to_Temp_Home_Phone</fullName>
        <field>PersonHomePhone</field>
        <formula>Temp_Home_Phone__pc</formula>
        <name>Set Home Phone to Temp Home Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Mobile_Phone_to_Phone</fullName>
        <field>PersonMobilePhone</field>
        <formula>Phone</formula>
        <name>Set Mobile Phone to Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_PhoneHome</fullName>
        <field>Preferred_Phone__pc</field>
        <literalValue>Home</literalValue>
        <name>Set Preferred Phone Home</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_Phone_Home</fullName>
        <field>Preferred_Phone__pc</field>
        <literalValue>Home</literalValue>
        <name>Set Preferred Phone Home</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_Phone_Mobile</fullName>
        <field>Preferred_Phone__pc</field>
        <literalValue>Mobile</literalValue>
        <name>Set Preferred Phone Mobile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preferred_Phone_Work</fullName>
        <field>Preferred_Phone__pc</field>
        <literalValue>Work</literalValue>
        <name>Set Preferred Phone Work</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Workphone</fullName>
        <field>Work_Phone__pc</field>
        <formula>Phone</formula>
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
(ISBLANK(TEXT(Preferred_Phone__pc)) ||
ISPICKVAL(Preferred_Phone__pc, &apos;Home&apos;)) &amp;&amp; NOT(ISBLANK(PersonHomePhone))
, PersonHomePhone,
IF(
(ISBLANK(TEXT(Preferred_Phone__pc)) ||
ISPICKVAL(Preferred_Phone__pc, &apos;Mobile&apos;)) &amp;&amp; NOT(ISBLANK(PersonMobilePhone))
, PersonMobilePhone,


IF(
(ISBLANK(TEXT(Preferred_Phone__pc)) ||
ISPICKVAL(Preferred_Phone__pc, &apos;Work&apos;)) &amp;&amp; NOT(ISBLANK(Work_Phone__pc))
, Work_Phone__pc,

if ( NOT(ISBLANK(PersonHomePhone)),
PersonHomePhone, If (NOT(ISBLANK(PersonMobilePhone)), PersonMobilePhone, IF(NOT(ISBLANK(Work_Phone__pc)),Work_Phone__pc, Phone) ) )

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
            <field>Account.PersonHomePhone</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Temp_Home_Phone__pc</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IsPersonAccount</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Home Phone Preferred</fullName>
        <actions>
            <name>Set_Preferred_Phone_Home</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(((ISNEW() || ISCHANGED(PersonHomePhone) || ISCHANGED (Work_Phone__pc) || ISCHANGED (PersonMobilePhone)) &amp;&amp; NOT(ISBLANK(PersonHomePhone))) &amp;&amp; ( ISBLANK(TEXT ( Preferred_Phone__pc ) ) || ISBLANK(Work_Phone__pc) &amp;&amp; ISBLANK(PersonMobilePhone) )) &amp;&amp; IsPersonAccount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Home Phone When Phone Changed</fullName>
        <actions>
            <name>Set_Home_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Preferred_PhoneHome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(  (ISNEW() || ISCHANGED( Phone )) &amp;&amp; NOT(ISBLANK(Phone)  )   &amp;&amp;   (      (   ISBLANK(TEXT(Preferred_Phone__pc)   )     ||     ISPICKVAL(Preferred_Phone__pc, &apos;Home&apos;)   )  )  &amp;&amp;  ( Phone != PersonHomePhone || ISBLANK(PersonHomePhone) ) ) &amp;&amp; IsPersonAccount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Main Phone</fullName>
        <actions>
            <name>Update_Main_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISBLANK(Phone) &amp;&amp; (NOT (ISCHANGED (Phone)) &amp;&amp; (ISNEW() || ISCHANGED( PersonHomePhone ) || ISCHANGED( Work_Phone__pc ) || ISCHANGED( PersonMobilePhone ) || ISCHANGED( Preferred_Phone__pc ) ) &amp;&amp; ( NOT(ISBLANK(PersonHomePhone)) || NOT(ISBLANK(Work_Phone__pc)) || NOT(ISBLANK(PersonMobilePhone)) )) &amp;&amp; IsPersonAccount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Mobile Preferred</fullName>
        <actions>
            <name>Set_Preferred_Phone_Mobile</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>((ISNEW() || ISCHANGED(PersonHomePhone) || ISCHANGED (Work_Phone__pc) || ISCHANGED (PersonMobilePhone)) &amp;&amp; NOT(ISBLANK(PersonMobilePhone))) &amp;&amp; (( ISBLANK(PersonHomePhone) &amp;&amp; ISBLANK(TEXT ( Preferred_Phone__pc ) )) || (ISBLANK(PersonHomePhone) &amp;&amp; ISBLANK(Work_Phone__pc)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Mobile When Phone Changed</fullName>
        <actions>
            <name>Set_Mobile_Phone_to_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>((ISNEW() || ISCHANGED( Phone )) &amp;&amp; NOT(ISBLANK(Phone)) &amp;&amp; ISPICKVAL(Preferred_Phone__pc, &apos;Mobile&apos;) &amp;&amp; ( Phone != PersonMobilePhone || ISBLANK(PersonMobilePhone) )) &amp;&amp; IsPersonAccount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Work Phone Preferred</fullName>
        <actions>
            <name>Set_Preferred_Phone_Work</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(((ISNEW() || ISCHANGED(PersonHomePhone) || ISCHANGED (Work_Phone__pc) || ISCHANGED (PersonMobilePhone)) &amp;&amp; NOT(ISBLANK(Work_Phone__pc))) &amp;&amp; ISBLANK(PersonHomePhone) &amp;&amp; ISBLANK(PersonMobilePhone)) &amp;&amp; IsPersonAccount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Work Phone When Phone Changed</fullName>
        <actions>
            <name>Set_Workphone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>((ISNEW() || ISCHANGED( Phone) ) &amp;&amp; NOT(ISBLANK(Phone)) &amp;&amp; ISPICKVAL(Preferred_Phone__pc, &apos;Work&apos;) &amp;&amp; ( Phone != Work_Phone__pc || ISBLANK(Work_Phone__pc) )) &amp;&amp; IsPersonAccount</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
