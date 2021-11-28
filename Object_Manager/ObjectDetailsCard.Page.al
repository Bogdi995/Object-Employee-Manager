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
                group(Subtype)
                {
                    ShowCaption = false;
                    Visible = ShowSubtype;
                    field(ObjectSubtype; Rec.ObjectSubtype)
                    {
                        ApplicationArea = All;
                    }
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

    var
        [InDataSet]
        ShowSubtype: Boolean;

    trigger OnOpenPage()
    var

    begin
    end;
}