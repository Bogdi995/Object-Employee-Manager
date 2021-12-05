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
        field(60; NoPrimaryKeys; Integer)
        {
            Caption = 'No. of Primary Keys';
            FieldClass = FlowField;
            CalcFormula = count("Object Details Line" where(ObjectType = field(ObjectType), ObjectNo = field(ObjectNo), ID = const(1), Type = const("Key")));
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
        field(190; ObjectTypeCopy; Option)
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

    trigger OnInsert()
    begin

    end;

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

    // local procedure InsertLines(var ObjectDetails: Record "Object Details")
    // var
    //     Field: Record Field;
    //     ObjectDetailsManagement: Codeunit "Object Details Management";
    //     SystemTableIDs: Integer;
    // begin
    //     SystemTableIDs := 2000000000;
    //     if ObjectDetails.ObjectType = "Object Type"::Table then begin
    //         Field.SetRange(TableNo, ObjectDetails.ObjectNo);
    //         if Field.FindFirst() then
    //             repeat
    //                 if Field."No." < SystemTableIDs then begin
    //                     ObjectDetailsManagement.InsertObjectDetailsLine(Field, ObjectDetails.ObjectType);
    //                 end;
    //             until Field.Next() = 0;
    //     end;
    // end;
}