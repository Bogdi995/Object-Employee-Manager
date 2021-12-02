page 50100 "Object Details List"
{
    Caption = 'Object Details List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Object Details";
    CardPageId = "Object Details Card";

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field(ObjectType; Rec.ObjectType)
                {
                    ApplicationArea = All;
                }
                field(ObjectNo; Rec.ObjectNo)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Caption; Rec.Caption)
                {
                    ApplicationArea = All;
                }
                field(NoTimesUsed; Rec.NoTimesUsed)
                {
                    ApplicationArea = All;
                }
                field(NoPrimaryKeys; Rec.NoPrimaryKeys)
                {
                    ApplicationArea = All;
                }
                field(NoKeys; Rec.NoKeys)
                {
                    ApplicationArea = All;
                }
                field(NoFields; Rec.NoFields)
                {
                    ApplicationArea = All;
                }
                field(NoGlobalFunctions; Rec.NoGlobalFunctions)
                {
                    ApplicationArea = All;
                }
                field(NoUnusedGlobalFunctions; Rec.NoUnusedGlobalFunctions)
                {
                    ApplicationArea = All;
                }
                field(NoLocalFuntions; Rec.NoLocalFuntions)
                {
                    ApplicationArea = All;
                }
                field(NoUnusedLocalFunctions; Rec.NoUnusedLocalFunctions)
                {
                    ApplicationArea = All;
                }
                field(NoTotalVariables; Rec.NoTotalVariables)
                {
                    ApplicationArea = All;
                }
                field(NoUnusedTotalVariables; Rec.NoUnusedTotalVariables)
                {
                    ApplicationArea = All;
                }
                field(NoGlobalVariables; Rec.NoGlobalVariables)
                {
                    ApplicationArea = All;
                }
                field(NoUnusedGlobalVariables; Rec.NoUnusedGlobalVariables)
                {
                    ApplicationArea = All;
                }
                field(NoUnusedParameters; Rec.NoUnusedParameters)
                {
                    ApplicationArea = All;
                }
                field(NoUnusedReturnValues; Rec.NoUnusedReturnValues)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Update)
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
                        if ObjectDetailsManagement.CheckIfUpdateNeeded() then begin
                            ObjectDetailsManagement.UpdateObjectDetails();
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
        Object: Record "Page Table Field";
    begin
        ObjectDetailsManagement.ConfirmCheckIfUpdateNeeded();

    end;

}