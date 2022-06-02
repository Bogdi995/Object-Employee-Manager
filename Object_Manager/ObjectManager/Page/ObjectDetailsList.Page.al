page 50100 "Object Details List"
{
    PageType = List;
    SourceTable = "Object Details";
    Caption = 'Object Details List';
    ApplicationArea = All;
    UsageCategory = Administration;
    CardPageId = "Object Details Card";
    PromotedActionCategories = 'New,Process,Report,Update';

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field(ObjectType; Rec."Object Type")
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
                field(NoTimesUsed; Rec.NoTimesUsed)
                {
                    ToolTip = 'Specifies the number of times the object was used.';
                    ApplicationArea = All;
                }
                field(NoIntegrationEvents; Rec.NoIntegrationEvents)
                {
                    ToolTip = 'Specifies the number of integration events.';
                    MultiLine = true;
                    ApplicationArea = All;
                }
                field(NoBusinessEvents; Rec.NoBusinessEvents)
                {
                    ToolTip = 'Specifies the number of business events.';
                    MultiLine = true;
                    ApplicationArea = All;
                }
                field(NoGlobalMethods; Rec.NoGlobalMethods)
                {
                    ToolTip = 'Specifies the number of global methods.';
                    ApplicationArea = All;
                }
                field(NoUnusedGlobalMethods; Rec.NoUnusedGlobalMethods)
                {
                    ToolTip = 'Specifies the number of unused global methods.';
                    ApplicationArea = All;
                }
                field(NoLocalMethods; Rec.NoLocalMethods)
                {
                    ToolTip = 'Specifies the number of local methods.';
                    ApplicationArea = All;
                }
                field(NoUnusedLocalMethods; Rec.NoUnusedLocalMethods)
                {
                    ToolTip = 'Specifies the number of unused local methods.';
                    ApplicationArea = All;
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
                field(NoTotalVariables; Rec.NoTotalVariables)
                {
                    ToolTip = 'Specifies the total number of variables.';
                    ApplicationArea = All;
                }
                field(NoUnusedTotalVariables; Rec.NoUnusedTotalVariables)
                {
                    ToolTip = 'Specifies the total number of unused variables.';
                    ApplicationArea = All;
                }
                field(NoGlobalVariables; Rec.NoGlobalVariables)
                {
                    ToolTip = 'Specifies the number of global variables.';
                    ApplicationArea = All;
                }
                field(NoUnusedGlobalVariables; Rec.NoUnusedGlobalVariables)
                {
                    ToolTip = 'Specifies the number of unused global variables.';
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
                PromotedCategory = Category4;

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

            action(UpdateDetails)
            {
                Caption = 'Update Details';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateDetailsLbl: Label 'Do you want to update the details of all objects?';
                    DetailsSuccessfullyUpdated: Label 'All details are successfully updated.';
                begin
                    if Confirm(UpdateDetailsLbl) then begin
                        ObjectDetailsManagement.UpdateAllType(Types::Field);
                        ObjectDetailsManagement.UpdateAllType(Types::"Key");
                        ObjectDetailsManagement.UpdateAllMethodsEvents();
                        ObjectDetailsManagement.UpdateAllVariables();
                        ObjectDetailsManagement.UpdateAllRelationsInternalUsageOfObjects();
                        ObjectDetailsManagement.UpdateAllExternalUsageOfObject();
                        Message(DetailsSuccessfullyUpdated);
                    end;
                end;
            }

            action(UpdateFieldKeys)
            {
                Caption = 'Update Fields and Keys';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateAllFieldsKeysLbl: Label 'Do you want to update the fields and keys of all objects?';
                    FieldsKeysSuccessfullyUpdated: Label 'All fields and keys are successfully updated.';
                begin
                    if Confirm(UpdateAllFieldsKeysLbl) then begin
                        ObjectDetailsManagement.UpdateAllType(Types::Field);
                        ObjectDetailsManagement.UpdateAllType(Types::"Key");
                        Message(FieldsKeysSuccessfullyUpdated);
                    end;
                end;
            }

            action(UpdateMethodsEvents)
            {
                Caption = 'Update Methods and Events';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateAllMethodsEventsLbl: Label 'Do you want to update the methods and events of all objects?';
                    MethodsEventsSuccessfullyUpdated: Label 'All methods and events are successfully updated.';
                begin
                    if Confirm(UpdateAllMethodsEventsLbl) then begin
                        ObjectDetailsManagement.UpdateAllMethodsEvents();
                        Message(MethodsEventsSuccessfullyUpdated);
                    end;
                end;
            }

            action(UpdateVariables)
            {
                Caption = 'Update Variables';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateAllVariablesLbl: Label 'Do you want to update the variables of all objects?';
                    VariablesSuccessfullyUpdated: Label 'The variables from all objects are successfully updated.';
                begin
                    if Confirm(UpdateAllVariablesLbl) then begin
                        ObjectDetailsManagement.UpdateAllVariables();
                        Message(VariablesSuccessfullyUpdated);
                    end;
                end;
            }

            action(UpdateRelationsUsage)
            {
                Caption = 'Update Relations/Usage';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    UpdateAllRelationsUsageLbl: Label 'Do you want to update the relations and the usage of all objects?';
                    RelationsSuccessfullyUpdatedLbl: Label 'The relations for all objects are successfully updated.';
                begin
                    if Confirm(UpdateAllRelationsUsageLbl) then begin
                        ObjectDetailsManagement.UpdateAllRelationsInternalUsageOfObjects();
                        ObjectDetailsManagement.UpdateAllExternalUsageOfObject();
                        Message(RelationsSuccessfullyUpdatedLbl);
                    end;
                end;
            }
        }

        area(Reporting)
        {
            action(CustomerView)
            {
                Caption = 'Customer view';
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                RunObject = report "Object Details Customer View";
            }

            action(Top10Objects)
            {
                Caption = 'Top 10 objects';
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                RunObject = report "Object Statistics Top 10";
            }
        }
    }

    trigger OnOpenPage()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
    begin
        ObjectDetailsManagement.ConfirmCheckUpdateObjectDetails();
    end;

    trigger OnAfterGetRecord()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
    begin
        Rec.NoTimesUsed := ObjectDetailsManagement.GetNoTimesUsed(Rec);
    end;

}