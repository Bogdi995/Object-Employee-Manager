table 50100 "Object Details"
{
    DataClassification = ToBeClassified;
    Caption = 'Object Details';

    fields
    {
        field(1; ObjectType; Option)
        {
            Caption = 'Object Type';
            OptionMembers = "TableData","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System","FieldNumber",,,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension";
            OptionCaption = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber,,,PageExtension,TableExtension,Enum,EnumExtension,Profile,ProfileExtension';
            DataClassification = CustomerContent;
        }
        field(2; ObjectNo; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" where("Object Type" = field(ObjectType));
        }
        field(10; Name; Text[30])
        {
            Caption = 'Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = field(ObjectType), "Object ID" = field(ObjectNo)));
        }
        field(20; Caption; Text[250])
        {
            Caption = 'Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = field(ObjectType), "Object ID" = field(ObjectNo)));
        }
        field(25; ObjectSubtype; Text[30])
        {
            Caption = 'Object Subtype';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Subtype" where("Object Type" = field(ObjectType), "Object ID" = field(ObjectNo)));
        }
        field(30; LastDateModified; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(40; LastTimeModified; Time)
        {
            Caption = 'Last Time Modified';
            DataClassification = CustomerContent;
        }
        field(50; NoTimesUsed; Integer)
        {
            Caption = 'No. of Times Used';
            DataClassification = CustomerContent;
        }
        field(60; NoPrimaryKeys; Integer)
        {
            Caption = 'No. of Primary Keys';
            DataClassification = CustomerContent;
        }
        field(70; NoKeys; Integer)
        {
            Caption = 'No. of Keys';
            DataClassification = CustomerContent;
        }
        field(80; NoFields; Integer)
        {
            Caption = 'No. of fields';
            DataClassification = CustomerContent;
        }
        field(90; NoGlobalFunctions; Integer)
        {
            Caption = 'No. of Global Functions';
            DataClassification = CustomerContent;
        }
        field(100; NoUnusedGlobalFunctions; Integer)
        {
            Caption = 'No. of Unused Global Functions';
            DataClassification = CustomerContent;
        }
        field(110; NoLocalFuntions; Integer)
        {
            Caption = 'No. of Local Functions';
            DataClassification = CustomerContent;
        }
        field(120; NoUnusedLocalFunctions; Integer)
        {
            Caption = 'No. of Unused Local Functions';
            DataClassification = CustomerContent;
        }
        field(130; NoTotalVariables; Integer)
        {
            Caption = 'No. of Total Variables';
            DataClassification = CustomerContent;
        }
        field(140; NoUnusedTotalVariables; Integer)
        {
            Caption = 'No. of Unused Total Variables';
            DataClassification = CustomerContent;
        }
        field(150; NoGlobalVariables; Integer)
        {
            Caption = 'No. of Global Variables';
            DataClassification = CustomerContent;
        }
        field(160; NoUnusedGlobalVariables; Integer)
        {
            Caption = 'No. of Unused Global Variables';
            DataClassification = CustomerContent;
        }
        field(170; NoUnusedParameters; Integer)
        {
            Caption = 'No. of Unused Parameters';
            DataClassification = CustomerContent;
        }
        field(180; NoUnusedReturnValues; Integer)
        {
            Caption = 'No. of Unused Return Values';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; ObjectType, ObjectNo)
        {
            Clustered = true;
        }
    }
}