page 50101 "Object Details Card"
{
    Caption = 'Object Details Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Object Details";

    layout
    {
        area(Content)
        {
            group(Group)
            {
                field(ObjectType; Rec.ObjectType)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        if Rec.ObjectType = Rec.ObjectType::Codeunit then
                            ShowSubtype := true
                        else
                            ShowSubtype := false;
                    end;
                }
                field(ObjectNo; Rec.ObjectNo)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(Caption; Rec.Caption)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                group(Subtype)
                {
                    ShowCaption = false;
                    Visible = ShowSubtype;
                    field(ObjectSubtype; Rec.ObjectSubtype)
                    {
                        ToolTip = 'Specifies the value of the Name field.';
                        ApplicationArea = All;
                    }
                }
                field(NoTimesUsed; Rec.NoTimesUsed)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoPrimaryKeys; Rec.NoPrimaryKeys)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoKeys; Rec.NoKeys)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoFields; Rec.NoFields)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoGlobalFunctions; Rec.NoGlobalFunctions)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoUnusedGlobalFunctions; Rec.NoUnusedGlobalFunctions)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoLocalFuntions; Rec.NoLocalFuntions)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoUnusedLocalFunctions; Rec.NoUnusedLocalFunctions)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoTotalVariables; Rec.NoTotalVariables)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoUnusedTotalVariables; Rec.NoUnusedTotalVariables)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoGlobalVariables; Rec.NoGlobalVariables)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoUnusedGlobalVariables; Rec.NoUnusedGlobalVariables)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoUnusedParameters; Rec.NoUnusedParameters)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(NoUnusedReturnValues; Rec.NoUnusedReturnValues)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateObjects)
            {
                Caption = 'Update Objects';
                ApplicationArea = All;
                Image = UpdateDescription;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateObjectsText: Label 'Do you want to update the objects?';
                    AlreadyUpdatedText: Label 'Objects already updated!';
                    SuccessfullyUpdated: Label 'Objects successfully updated!';
                begin
                    if Confirm(UpdateObjectsText, true) then
                        if ObjectDetailsManagement.CheckUpdateObjectDetails() then begin
                            ObjectDetailsManagement.UpdateObjectDetails();
                            Message(SuccessfullyUpdated);
                        end
                        else
                            Message(AlreadyUpdatedText);
                end;
            }
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

    var
        [InDataSet]
        ShowSubtype: Boolean;

    trigger OnOpenPage()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
    begin
        ObjectDetailsManagement.ConfirmCheckUpdateObjectDetails();
    end;
}