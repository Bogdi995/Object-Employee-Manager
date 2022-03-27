page 50100 "Object Details List"
{
    PageType = List;
    SourceTable = "Object Details";
    Caption = 'Object Details List';
    ApplicationArea = All;
    UsageCategory = Administration;
    CardPageId = "Object Details Card";

    layout
    {
        area(Content)
        {
            repeater(group)
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

            action(UpdateVariables)
            {
                Caption = 'Update Variables';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AllObj: Record AllObj;
                    ObjectDetails: Record "Object Details";
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    Progress: Dialog;
                    Object: Text;
                    UpdateVariablesLbl: Label 'The variables are beign updated...\\#1';
                    VariablesSuccessfullyUpdated: Label 'The variables from all objects are successfully updated.';
                    NeedsUpdate: array[4] of Boolean;
                begin
                    // AllObj.SetFilter("Object Type", '%1|%2|%3|%4|%5', AllObj."Object Type"::Table,
                    //                  AllObj."Object Type"::"TableExtension", AllObj."Object Type"::Page,
                    //                  AllObj."Object Type"::"PageExtension", AllObj."Object Type"::Codeunit);
                    AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
                    AllObj.SetFilter("Object ID", '<%1', 2000000000);

                    if AllObj.FindSet() then begin
                        Progress.Open(UpdateVariablesLbl, Object);

                        repeat
                            ObjectDetails.SetRange(ObjectType, ObjectDetailsManagement.GetObjectTypeFromAllObj(AllObj));
                            ObjectDetails.SetRange(ObjectNo, AllObj."Object ID");
                            if ObjectDetails.FindFirst() then begin
                                ObjectDetails.CalcFields(Name);
                                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                                Progress.Update();
                                ObjectDetailsManagement.UpdateVariables(ObjectDetails, NeedsUpdate[1]);
                                ObjectDetailsManagement.UpdateUnusedVariables(ObjectDetails, NeedsUpdate[2]);
                            end;
                        until AllObj.Next() = 0;

                        Progress.Close();
                        Message(VariablesSuccessfullyUpdated);
                    end;
                end;
            }

            action(UpdateRelations)
            {
                Caption = 'Update Relations';
                ApplicationArea = All;
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AllObj: Record AllObj;
                    ObjectDetails: Record "Object Details";
                    ObjectDetailsManagement: Codeunit "Object Details Management";
                    Progress: Dialog;
                    Object: Text;
                    UpdateRelationsLbl: Label 'The relations are beign updated...\\#1';
                    RelationsSuccessfullyUpdatedLbl: Label 'The relations for all objects are successfully updated.';
                    NeedsUpdate: array[4] of Boolean;
                begin
                    AllObj.SetFilter("Object Type", '%1|%2|%3|%4|%5|%6', AllObj."Object Type"::Table,
                                             AllObj."Object Type"::"TableExtension", AllObj."Object Type"::Page,
                                             AllObj."Object Type"::"PageExtension", AllObj."Object Type"::Report,
                                             AllObj."Object Type"::Codeunit);
                    AllObj.SetFilter("Object ID", '<%1', 2000000000);

                    if AllObj.FindSet() then begin
                        Progress.Open(UpdateRelationsLbl, Object);

                        repeat
                            ObjectDetails.SetRange(ObjectType, ObjectDetailsManagement.GetObjectTypeFromAllObj(AllObj));
                            ObjectDetails.SetRange(ObjectNo, AllObj."Object ID");

                            if ObjectDetails.FindFirst() then begin
                                ObjectDetails.CalcFields(Name);
                                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                                Progress.Update();

                                if ObjectDetails.ObjectType = ObjectDetails.ObjectType::Table then begin
                                    ObjectDetailsManagement.UpdateRelations(Rec, NeedsUpdate[1], Types::"Relation (External)");
                                    ObjectDetailsManagement.UpdateRelations(Rec, NeedsUpdate[2], Types::"Relation (Internal)");
                                end;
                                ObjectDetailsManagement.UpdateNoOfObjectsUsedIn(Rec, NeedsUpdate[3]);

                            end;
                        until AllObj.Next() = 0;

                        Progress.Close();
                        Message(RelationsSuccessfullyUpdatedLbl);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ObjectDetailsManagement: Codeunit "Object Details Management";
        obj: Record "Object Details";
        obj2: Record "Object Details Line";
    begin
        ObjectDetailsManagement.ConfirmCheckUpdateObjectDetails();
        // obj.DeleteAll();
        // obj2.DeleteAll();
    end;

}