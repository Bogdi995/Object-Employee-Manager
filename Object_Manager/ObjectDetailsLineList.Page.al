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
                        if ObjectDetailsManagement.CheckUpdateObjectDetailsLine() then begin
                            ObjectDetailsManagement.UpdateObjectDetailsLine();
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
    begin
        ObjectDetailsManagement.ConfirmCheckUpdateObjectDetailsLine();
    end;

    local procedure GetName(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec.ObjectType <> "Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.Name);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field.FieldName);
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
