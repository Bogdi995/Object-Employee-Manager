page 50102 "Object Details Line List"
{
    PageType = List;
    SourceTable = "Object Details Line";
    Caption = 'Object Details Line List';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("ObjectType"; Rec."Object Type")
                {
                    ToolTip = 'Specifies the type of the object.';
                    ApplicationArea = All;
                }
                field(ObjectNo; Rec.ObjectNo)
                {
                    ToolTip = 'Specifies the number of the object.';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the type of the data.';
                    ApplicationArea = All;
                }
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the ID of the data.';
                    ApplicationArea = All;
                }
                field(Name; GetName())
                {
                    ToolTip = 'Specifies the name of the data.';
                    ApplicationArea = All;
                }
                field(Caption; GetCaption())
                {
                    ToolTip = 'Specifies the caption of the data.';
                    ApplicationArea = All;
                }
                field(TypeName; GetTypeName())
                {
                    ToolTip = 'Specifies the data type and its length.';
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        case Rec.Type of
                            Types::"Relation (Internal)", Types::"Object (Internal)":
                                DrillDownInternal();
                            Types::"Relation (External)", Types::"Object (External)", Types::"Object (Used)":
                                DrillDownExternal();
                        end;
                    end;
                }
                field(NoTimesUsed; Rec.NoTimesUsed)
                {
                    ToolTip = 'Specified the number of times the object was used';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateFields)
            {
                Caption = 'Update Fields';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateFieldsLbl: Label 'Do you want to update the fields?';
                    AlreadyUpdatedLbl: Label 'Fields already updated!';
                    SuccessfullyUpdatedLbl: Label 'Fields successfully updated!';
                    NeedsUpdate: Boolean;
                begin
                    if Confirm(UpdateFieldsLbl, true) then begin
                        ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Types::Field, NeedsUpdate);
                        if NeedsUpdate then
                            Message(SuccessfullyUpdatedLbl)
                        else
                            Message(AlreadyUpdatedLbl);
                    end;
                end;
            }

            action(UpdateKeys)
            {
                Caption = 'Update Keys';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateFieldsLbl: Label 'Do you want to update the keys?';
                    AlreadyUpdatedLbl: Label 'Keys already updated!';
                    SuccessfullyUpdatedLbl: Label 'Keys successfully updated!';
                    NeedsUpdate: Boolean;
                begin
                    if Confirm(UpdateFieldsLbl, true) then begin
                        ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Types::"Key", NeedsUpdate);
                        if NeedsUpdate then
                            Message(SuccessfullyUpdatedLbl)
                        else
                            Message(AlreadyUpdatedLbl);
                    end;
                end;
            }
        }
    }

    local procedure GetName(): Text[250]
    var
        Field: Record Field;
        Keys: Record "Key";
    begin
        if (Rec."Object Type" = Rec."Object Type"::Table) and (Rec.Type = Types::Field) then
            if Field.Get(Rec.ObjectNo, Rec.ID) then
                exit(Field.FieldName);

        if (Rec."Object Type" = Rec."Object Type"::Table) and (Rec.Type = Types::"Key") then
            if Keys.Get(Rec.ObjectNo, Rec.ID) then
                exit(Keys."Key");

        exit(Rec.Name);
    end;

    local procedure GetCaption(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec."Object Type" <> Rec."Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.Caption);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field."Field Caption");
    end;

    local procedure GetTypeName(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec."Object Type" <> Rec."Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.TypeName);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field."Type Name");
    end;

    local procedure DrillDownInternal()
    var
        ObjectDetails: Record "Object Details";
        ObjectDetailsManagement: Codeunit "Object Details Management";
        ObjectALCode: DotNet String;
    begin
        ObjectDetails.SetRange("Object Type", Rec."Object Type");
        ObjectDetails.SetRange(ObjectNo, Rec.ObjectNo);

        if ObjectDetails.FindFirst() then begin
            ObjectDetailsManagement.GetObjectALCode(ObjectDetails, ObjectALCode);
            Message(ObjectALCode);
        end;
    end;

    local procedure DrillDownExternal()
    var
        ObjectDetails: Record "Object Details";
        ObjectDetailsManagement: Codeunit "Object Details Management";
        ObjectALCode: DotNet String;
        ObjectType: Text;
    begin
        ObjectType := CopyStr(Rec.TypeName, 1, StrPos(Rec.TypeName, ' ') - 1);

        ObjectDetails.SetRange("Object Type", ObjectDetailsManagement.GetObjectTypeFromText(ObjectType));
        ObjectDetails.SetRange(ObjectNo, Rec.ID);
        if ObjectDetails.FindFirst() then begin
            ObjectDetailsManagement.GetObjectALCode(ObjectDetails, ObjectALCode);
            Message(ObjectALCode);
        end;
    end;
}
