page 50101 "Object Details Card"
{
    PageType = Card;
    SourceTable = "Object Details";
    Caption = 'Object Details Card';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Details)
            {
                field(ObjectType; Rec.ObjectType)
                {
                    ToolTip = 'Specifies the type of the object.';
                    ApplicationArea = All;
                }
                field(ObjectNo; Rec.ObjectNo)
                {
                    ToolTip = 'Specifies the number of the object.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the object.';
                    ApplicationArea = All;
                }
                field(Caption; Rec.Caption)
                {
                    ToolTip = 'Specifies the caption of the object.';
                    ApplicationArea = All;
                }
                group(Subtype)
                {
                    ShowCaption = false;
                    Visible = ShowSubtype;
                    field(ObjectSubtype; Rec.ObjectSubtype)
                    {
                        ToolTip = 'Specifies the subtype of the object. This field is visible only when the type of the object is Codeunit.';
                        ApplicationArea = All;
                    }
                }
                field(NoTimesUsed; Rec.NoTimesUsed)
                {
                    ToolTip = 'Specifies the number of times the object was used.';
                    ApplicationArea = All;
                }
                field(PrimaryKey; Rec.PrimaryKey)
                {
                    ToolTip = 'Specifies the primary key of the object.';
                    ApplicationArea = All;
                }
                field(NoKeys; Rec.NoKeys)
                {
                    ToolTip = 'Specifies the number of keys the object has.';
                    ApplicationArea = All;
                }
                field(NoFields; Rec.NoFields)
                {
                    ToolTip = 'Specifies the number of fields the object has.';
                    ApplicationArea = All;
                }
                group(Relations)
                {
                    field(RelationsFrom; Rec.RelationsFrom)
                    {
                        ToolTip = 'Specifies the number of relations the object has from other objects.';
                        ApplicationArea = All;
                    }
                    field(RelationsTo; Rec.RelationsTo)
                    {
                        ToolTip = 'Specifies the number of relations the object has to other objects.';
                        ApplicationArea = All;
                    }
                    field(NoObjectsUsedIn; Rec.NoObjectsUsedIn)
                    {
                        ToolTip = 'Specifies the number of objects used in the object.';
                        ApplicationArea = All;
                    }
                    field(UsedInNoObjects; Rec.UsedInNoObjects)
                    {
                        ToolTip = 'Specifies the number of objects the object is used in.';
                        ApplicationArea = All;
                    }
                }
                group(MethodsEvents)
                {
                    Caption = 'Methods and events';
                    ShowCaption = true;

                    field(NoIntegrationEvents; Rec.NoIntegrationEvents)
                    {
                        ToolTip = 'Specifies the number of integration events.';
                        ApplicationArea = All;
                    }
                    field(NoBusinessEvents; Rec.NoBusinessEvents)
                    {
                        ToolTip = 'Specifies the number of business events.';
                        ApplicationArea = All;
                    }
                    field(NoGlobalMethods; Rec.NoGlobalMethods)
                    {
                        ToolTip = 'Specifies the number of global methods.';
                        ApplicationArea = All;
                    }
                    group(UnusedGlobalMethods)
                    {
                        ShowCaption = false;
                        Visible = ShowNoUnusedGlobalMethods;
                        field(NoUnusedGlobalMethods; Rec.NoUnusedGlobalMethods)
                        {
                            ToolTip = 'Specifies the number of unused global methods.';
                            ApplicationArea = All;
                        }
                    }
                    field(NoLocalMethods; Rec.NoLocalMethods)
                    {
                        ToolTip = 'Specifies the number of local methods.';
                        ApplicationArea = All;
                    }
                    group(UnusedLocalMethods)
                    {
                        ShowCaption = false;
                        Visible = ShowNoUnusedLocalMethods;
                        field(NoUnusedLocalMethods; Rec.NoUnusedLocalMethods)
                        {
                            ToolTip = 'Specifies the number of unused local methods.';
                            ApplicationArea = All;
                        }
                    }
                    field(NoUnusedParameters; Rec.NoUnusedParameters)
                    {
                        ToolTip = 'Specifies the number of unused parameters.';
                        ApplicationArea = All;
                    }
                    field(NoUnusedReturnValues; Rec.NoUnusedReturnValues)
                    {
                        ToolTip = 'Specifies the number of unused return values.';
                        ApplicationArea = All;
                    }
                }
                group(Variables)
                {
                    Caption = 'Variables';
                    ShowCaption = true;

                    field(NoTotalVariables; Rec.NoTotalVariables)
                    {
                        ToolTip = 'Specifies the total number of variables.';
                        ApplicationArea = All;
                    }
                    group(UnusedTotalVariables)
                    {
                        ShowCaption = false;
                        Visible = ShowNoUnusedTotalVariables;
                        field(NoUnusedTotalVariables; Rec.NoUnusedTotalVariables)
                        {
                            ToolTip = 'Specifies the total number of unused variables.';
                            ApplicationArea = All;
                        }
                    }
                    field(NoGlobalVariables; Rec.NoGlobalVariables)
                    {
                        ToolTip = 'Specifies the number of global variables.';
                        ApplicationArea = All;
                    }
                    group(UnusedGlobalVariables)
                    {
                        ShowCaption = false;
                        Visible = ShowNoUnusedGlobalVariables;
                        field(NoUnusedGlobalVariables; Rec.NoUnusedGlobalVariables)
                        {
                            ToolTip = 'Specifies the number of unused global variables.';
                            ApplicationArea = All;
                        }
                    }
                }
            }
            group(Lines)
            {
                part("Object Details Subpage"; "Object Details Subpage")
                {
                    SubPageLink = ObjectType = field(ObjectType), ObjectNo = field(ObjectNo);
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
                    UpdateFieldsText: Label 'Do you want to update the fields for: %1 %2 - "%3"?';
                    AlreadyUpdatedText: Label 'Fields already updated!';
                    SuccessfullyUpdated: Label 'Fields successfully updated!';
                begin
                    if Confirm(StrSubstNo(UpdateFieldsText, Rec.ObjectType, Rec.ObjectNo, Rec.Name), true) then
                        if ObjectDetailsManagement.CheckUpdateTypeObjectDetailsLine(Rec, Types::Field) then begin
                            ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Format(Rec.ObjectNo), Types::Field);
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
                    UpdateKeysText: Label 'Do you want to update the keys for: %1 %2 - "%3"?';
                    AlreadyUpdatedText: Label 'Keys already updated!';
                    SuccessfullyUpdated: Label 'Keys successfully updated!';
                begin
                    if Confirm(StrSubstNo(UpdateKeysText, Rec.ObjectType, Rec.ObjectNo, Rec.Name), true) then
                        if ObjectDetailsManagement.CheckUpdateTypeObjectDetailsLine(Rec, Types::"Key") then begin
                            ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Format(Rec.ObjectNo), Types::"Key");
                            Message(SuccessfullyUpdated);
                        end
                        else
                            Message(AlreadyUpdatedText);
                end;
            }
            action(UpdateMethodsEvents)
            {
                Caption = 'Update Methods and Events';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateMethodsEventsText: Label 'Do you want to update the methods and events for: %1 %2 - "%3"?';
                    AlreadyUpdatedText: Label 'Methods and events already updated!';
                    SuccessfullyUpdated: Label 'Methods and events successfully updated!';
                begin
                    if Confirm(StrSubstNo(UpdateMethodsEventsText, Rec.ObjectType, Rec.ObjectNo, Rec.Name), true) then
                        if ObjectDetailsManagement.CheckUpdateMethodsEventsObjectDetailsLine(Rec) then begin
                            ObjectDetailsManagement.UpdateMethodsEventsObjectDetailsLine(Rec);
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
        ShowSubtype, ShowNoUnusedTotalVariables, ShowNoUnusedGlobalVariables, ShowNoUnusedGlobalMethods, ShowNoUnusedLocalMethods : Boolean;

    trigger OnOpenPage()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
    begin
        ObjectDetailsManagement.ConfirmCheckUpdateObjectDetails();
        ShowSubtype := ObjectDetailsManagement.GetShowSubtype(Rec.ObjectType);
        ShowNoUnusedGlobalMethods := ObjectDetailsManagement.GetShowNoUnused(Rec.NoGlobalMethods);
        ShowNoUnusedLocalMethods := ObjectDetailsManagement.GetShowNoUnused(Rec.NoLocalMethods);
        ShowNoUnusedTotalVariables := ObjectDetailsManagement.GetShowNoUnused(Rec.NoTotalVariables);
        ShowNoUnusedGlobalVariables := ObjectDetailsManagement.GetShowNoUnused(Rec.NoGlobalVariables);
    end;

}