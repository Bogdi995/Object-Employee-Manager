page 50102 "Object Details Line List"
{

    ApplicationArea = All;
    Caption = 'Object Details Line List';
    PageType = List;
    SourceTable = "Object Details Line";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("ObjectType"; Rec."ObjectType")
                {
                    ToolTip = 'Specifies the value of the Object Type field.';
                    ApplicationArea = All;
                }
                field(ObjectNo; Rec.ObjectNo)
                {
                    ToolTip = 'Specifies the value of the Object No. field.';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                }
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field.';
                    ApplicationArea = All;
                }
                field(Name; GetName())
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(Caption; GetCaption())
                {
                    ToolTip = 'Specifies the value of the Caption field.';
                    ApplicationArea = All;
                }
                field(TypeName; GetTypeName())
                {
                    ToolTip = 'Specifies the value of the Type Name field.';
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
                    UpdateFieldsText: Label 'Do you want to update the fields?';
                    AlreadyUpdatedText: Label 'Fields already updated!';
                    SuccessfullyUpdated: Label 'Fields successfully updated!';
                begin
                    if Confirm(UpdateFieldsText, true) then
                        if ObjectDetailsManagement.CheckUpdateTypeObjectDetailsLine(Types::Field) then begin
                            ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Types::Field);
                            Message(SuccessfullyUpdated);
                        end
                        else
                            Message(AlreadyUpdatedText);
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
                    UpdateFieldsText: Label 'Do you want to update the keys?';
                    AlreadyUpdatedText: Label 'Keys already updated!';
                    SuccessfullyUpdated: Label 'Keys successfully updated!';
                begin
                    if Confirm(UpdateFieldsText, true) then
                        if ObjectDetailsManagement.CheckUpdateTypeObjectDetailsLine(Types::"Key") then begin
                            ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Types::"Key");
                            Message(SuccessfullyUpdated);
                        end
                        else
                            Message(AlreadyUpdatedText);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
        Keys: Record "Key";
    begin
        ObjectDetailsManagement.ConfirmCheckUpdateTypeObjectDetailsLine(Types::Field);
        ObjectDetailsManagement.ConfirmCheckUpdateTypeObjectDetailsLine(Types::"Key");
    end;

    local procedure GetName(): Text[250]
    var
        Field: Record Field;
        Keys: Record "Key";
    begin
        if (Rec.ObjectType = "Object Type"::Table) and (Rec.Type = Types::Field) then
            if Field.Get(Rec.ObjectNo, Rec.ID) then
                exit(Field.FieldName);

        if (Rec.ObjectType = "Object Type"::Table) and (Rec.Type = Types::"Key") then
            if Keys.Get(Rec.ObjectNo, Rec.ID) then
                exit(Keys."Key");

        exit(Rec.Name);
    end;

    local procedure GetCaption(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec.ObjectType <> "Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.Caption);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field."Field Caption");
    end;

    local procedure GetTypeName(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec.ObjectType <> "Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.TypeName);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field."Type Name");
    end;

}
