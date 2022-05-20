table 50103 "Object Details Amount"
{
    Caption = 'Object Details Amount';

    fields
    {
        field(1; "Object Type"; Enum "Object Type")
        {
            Caption = 'Object Type';
        }
        field(2; ObjectNo; Integer)
        {
            Caption = 'Object No.';
        }
        field(3; FieldCount; Integer)
        {
            Caption = 'Total Count';
        }
    }

    keys
    {
        key(Pk; FieldCount, "Object Type", ObjectNo)
        {
            Clustered = true;
        }
    }
}