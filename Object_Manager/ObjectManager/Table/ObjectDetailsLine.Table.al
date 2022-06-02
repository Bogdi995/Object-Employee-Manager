table 50101 "Object Details Line"
{
    Caption = 'Object Details Line';
    DataClassification = CustomerContent;
    LookupPageId = "Object Details Line List";
    DrillDownPageId = "Object Details Line List";

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Object Type"; Enum "Object Type")
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
        }
        field(3; ObjectNo; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Enum Types)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(20; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(30; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(40; Caption; Text[250])
        {
            Caption = 'Caption';
            DataClassification = CustomerContent;
        }
        field(50; TypeName; Text[50])
        {
            Caption = 'Type Name';
            DataClassification = CustomerContent;
        }
        field(60; Used; Boolean)
        {
            Caption = 'Used';
            DataClassification = CustomerContent;
        }
        field(70; NoTimesUsed; Integer)
        {
            Caption = 'No. of Times Used';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Pk; EntryNo)
        {
            Clustered = true;
        }
        key(Fk; "Object Type", ObjectNo)
        {

        }
        key(Fk2; Type, ID)
        {

        }
    }

}