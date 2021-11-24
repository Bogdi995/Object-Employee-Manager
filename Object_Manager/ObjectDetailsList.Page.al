page 50100 "Object Details List"
{
    Caption = 'Object Details List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Object Details";

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
                field(LastDateModified; Rec.LastDateModified)
                {
                    ApplicationArea = All;
                }
                field(LastTimeModified; Rec.LastTimeModified)
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
    begin
        if ObjectDetailsManagement.CheckIfUpdateNeeded() then
            ObjectDetailsManagement.UpdateObjectDetails();
    end;
}