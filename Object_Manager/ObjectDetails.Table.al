table 50100 "Object Details"
{
    Caption = 'Object Details';
    DataClassification = CustomerContent;
    LookupPageId = "Object Details List";
    DrillDownPageId = "Object Details List";

    fields
    {
        field(1; ObjectType; Enum "Object Type")
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                ObjectDetailsManagement: Codeunit "Object Details Management";
            begin
                Validate(ObjectTypeCopy, ObjectDetailsManagement.GetObjectTypeFromObjectDetails(Rec));
            end;
        }
        field(2; ObjectNo; Integer)
        {
            Caption = 'Object No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Name; Text[30])
        {
            Caption = 'Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = field(ObjectTypeCopy), "Object ID" = field(ObjectNo)));
        }
        field(20; Caption; Text[250])
        {
            Caption = 'Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = field(ObjectTypeCopy), "Object ID" = field(ObjectNo)));
        }
        field(30; ObjectSubtype; Text[30])
        {
            Caption = 'Object Subtype';
            DataClassification = CustomerContent;
        }
        field(50; NoTimesUsed; Integer)
        {
            Caption = 'No. of Times Used';
            DataClassification = CustomerContent;
        }
        field(60; PrimaryKey; Text[250])
        {
            Caption = 'Primary Key';
            FieldClass = FlowField;
            CalcFormula = lookup(Key."Key" where(TableNo = field(ObjectNo), "No." = const(1)));
        }
        field(70; NoKeys; Integer)
        {
            Caption = 'No. of Keys';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Key")));
        }
        field(80; NoFields; Integer)
        {
            Caption = 'No. of fields';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const(Field)));
        }
        field(90; NoIntegrationEvents; Integer)
        {
            Caption = 'No. of Integration Events';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Integration Event")));
        }
        field(100; NoBusinessEvents; Integer)
        {
            Caption = 'No. of Business Events';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Business Event")));
        }
        field(110; NoGlobalMethods; Integer)
        {
            Caption = 'No. of Global Methods';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Global Method"), Used = const(true)));
        }
        field(120; NoUnusedGlobalMethods; Integer)
        {
            Caption = 'No. of Unused Global Methods';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Global Method"), Used = const(false)));
        }
        field(130; NoLocalMethods; Integer)
        {
            Caption = 'No. of Local Methods';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Local Method"), Used = const(true)));
        }
        field(140; NoUnusedLocalMethods; Integer)
        {
            Caption = 'No. of Unused Local Methods';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const("Local Method"), Used = const(false)));
        }
        field(150; NoTotalVariables; Integer)
        {
            Caption = 'No. of Total Variables';
            DataClassification = CustomerContent;
        }
        field(160; NoUnusedTotalVariables; Integer)
        {
            Caption = 'No. of Unused Total Variables';
            DataClassification = CustomerContent;
        }
        field(170; NoGlobalVariables; Integer)
        {
            Caption = 'No. of Global Variables';
            DataClassification = CustomerContent;
        }
        field(180; NoUnusedGlobalVariables; Integer)
        {
            Caption = 'No. of Unused Global Variables';
            DataClassification = CustomerContent;
        }
        field(190; NoUnusedParameters; Integer)
        {
            Caption = 'No. of Unused Parameters';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), Type = const(Parameter), Used = const(false)));
        }
        field(200; NoUnusedReturnValues; Integer)
        {
            Caption = 'No. of Unused Return Values';
            DataClassification = CustomerContent;
        }
        field(210; RelationsTo; Integer)
        {
            Caption = 'Relations To';
            DataClassification = CustomerContent;
        }
        field(220; RelationsFrom; Integer)
        {
            Caption = 'Relations From';
            DataClassification = CustomerContent;
        }
        field(230; NoObjectsUsedIn; Integer)
        {
            Caption = 'No. of Objects Used in';
            DataClassification = CustomerContent;
        }
        field(240; UsedInNoObjects; Integer)
        {
            Caption = 'Used in No. of Objects';
            DataClassification = CustomerContent;
        }
        field(250; ObjectTypeCopy; Option)
        {
            OptionMembers = "TableData","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System","FieldNumber",,,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension";
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

    trigger OnDelete()
    begin
        DeleteLines(Rec);
    end;

    local procedure DeleteLines(var ObjectDetails: Record "Object Details")
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.SetCurrentKey(ObjectType, ObjectNo);
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.DeleteAll();
    end;

}