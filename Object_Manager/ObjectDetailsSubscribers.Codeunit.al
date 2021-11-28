codeunit 50104 "Object Details Subscriber"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::AllObj, 'OnBeforeInsertEvent', '', true, true)]
    local procedure TableAllObjOnBeforeInsert(var Rec: Record AllObj)
    var
        ObjectDetails: Record "Object Details";
    begin
        if CheckIfObjectTypeValid(Rec) then begin
            ObjectDetails.Init();
            ObjectDetails.Validate(ObjectType, GetObjectTypeFromAllObj(Rec));
            ObjectDetails.Validate(ObjectNo, Rec."Object ID");
            ObjectDetails.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::AllObj, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure TableAllObjOnBeforeDelete(var Rec: Record AllObj)
    var
        ObjectDetails: Record "Object Details";
    begin
        if CheckIfObjectTypeValid(Rec) then begin
            ObjectDetails.SetRange(ObjectType, GetObjectTypeFromAllObj(Rec));
            ObjectDetails.SetRange(ObjectNo, Rec."Object ID");
            if ObjectDetails.FindFirst() then
                ObjectDetails.Delete(true);
        end;
    end;

    local procedure CheckIfObjectTypeValid(AllObj: Record AllObj): Boolean
    var
        ObjectTypeAllObj: Integer;
    begin
        Evaluate(ObjectTypeAllObj, AllObj.GetFilter("Object Type"));
        if ObjectTypeAllObj IN [AllObj."Object Type"::Table, AllObj."Object Type"::"TableExtension",
                                AllObj."Object Type"::Page, AllObj."Object Type"::"PageExtension",
                                AllObj."Object Type"::Report, AllObj."Object Type"::Codeunit,
                                AllObj."Object Type"::Enum, AllObj."Object Type"::EnumExtension,
                                AllObj."Object Type"::XMLport, AllObj."Object Type"::Query, AllObj."Object Type"::MenuSuite] then
            exit(true);
        exit(false);
    end;

    local procedure GetObjectTypeFromAllObj(AllObj: Record AllObj): Enum "Object Type"
    var
        ObjectTypeAllObj: Integer;
    begin
        Evaluate(ObjectTypeAllObj, AllObj.GetFilter("Object Type"));
        case ObjectTypeAllObj of
            AllObj."Object Type"::Table:
                exit("Object Type"::Table);
            AllObj."Object Type"::"TableExtension":
                exit("Object Type"::"TableExtension");
            AllObj."Object Type"::Page:
                exit("Object Type"::Page);
            AllObj."Object Type"::"PageExtension":
                exit("Object Type"::"PageExtension");
            AllObj."Object Type"::Report:
                exit("Object Type"::Report);
            AllObj."Object Type"::Codeunit:
                exit("Object Type"::Codeunit);
            AllObj."Object Type"::Enum:
                exit("Object Type"::Enum);
            AllObj."Object Type"::EnumExtension:
                exit("Object Type"::EnumExtension);
            AllObj."Object Type"::XMLport:
                exit("Object Type"::XMLPort);
            AllObj."Object Type"::Query:
                exit("Object Type"::Query);
            AllObj."Object Type"::MenuSuite:
                exit("Object Type"::MenuSuite);
        end;
    end;

}