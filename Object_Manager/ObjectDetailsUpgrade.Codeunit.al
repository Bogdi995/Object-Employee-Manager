codeunit 50102 "Object Details Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Module: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Module);
        if Module.DataVersion.Major = 1 then begin
            CheckIfUpdateNeeded();
        end;
    end;

    local procedure CheckIfUpdateNeeded()
    var
        ObjectDetails: Record "Object Details";
    begin
        if CountAllObj() <> ObjectDetails.Count then
            UpdateObjectDetails();
    end;

    local procedure CountAllObj(): Integer
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetFilter("Object Type", '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11', AllObj."Object Type"::Table,
                         AllObj."Object Type"::"TableExtension", AllObj."Object Type"::Page,
                         AllObj."Object Type"::"PageExtension", AllObj."Object Type"::Report,
                         AllObj."Object Type"::Codeunit, AllObj."Object Type"::Enum,
                         AllObj."Object Type"::EnumExtension, AllObj."Object Type"::XMLport,
                         AllObj."Object Type"::Query, AllObj."Object Type"::MenuSuite);
        exit(AllObj.Count());
    end;

    local procedure UpdateObjectDetails()
    var
        AllObj: Record AllObj;
    begin
        Update("Object Type"::Table, AllObj."Object Type"::Table);
        Update("Object Type"::"TableExtension", AllObj."Object Type"::"TableExtension");
        Update("Object Type"::Page, AllObj."Object Type"::Page);
        Update("Object Type"::"PageExtension", AllObj."Object Type"::"PageExtension");
        Update("Object Type"::Report, AllObj."Object Type"::Report);
        Update("Object Type"::Codeunit, AllObj."Object Type"::Codeunit);
        Update("Object Type"::Enum, AllObj."Object Type"::Enum);
        Update("Object Type"::EnumExtension, AllObj."Object Type"::EnumExtension);
        Update("Object Type"::XMLPort, AllObj."Object Type"::XMLport);
        Update("Object Type"::Query, AllObj."Object Type"::Query);
        Update("Object Type"::MenuSuite, AllObj."Object Type"::MenuSuite);

    end;

    local procedure Update(ObjectTypeObjectDetails: enum "Object Type"; ObjectTypeAllObj: Integer)
    var
        AllObj: Record AllObj;
        ObjectDetails: Record "Object Details";
    begin
        AllObj.SetRange("Object Type", ObjectTypeAllObj);
        ObjectDetails.SetRange(ObjectType, ObjectTypeObjectDetails);
        if AllObj.FindFirst() then
            if ObjectDetails.FindFirst() then begin
                if AllObj.Count() > ObjectDetails.Count() then
                    repeat
                        ObjectDetails.SetRange(ObjectNo, AllObj."Object ID");
                        if not ObjectDetails.FindFirst() then
                            InsertNewRecord(AllObj, ObjectTypeObjectDetails);
                    until AllObj.Next() = 0
                else
                    if AllObj.Count() < ObjectDetails.Count() then
                        repeat
                            AllObj.SetRange("Object ID", ObjectDetails.ObjectNo);
                            if not AllObj.FindFirst() then
                                ObjectDetails.Delete(true);
                        until ObjectDetails.Next() = 0;
            end;
    end;

    local procedure InsertNewRecord(var AllObj: Record AllObj; TypeOfObject: enum "Object Type")
    var
        ObjectDetails: Record "Object Details";
    begin
        ObjectDetails.Init();
        ObjectDetails.Validate(ObjectType, TypeOfObject);
        ObjectDetails.Validate(ObjectNo, AllObj."Object ID");
        ObjectDetails.Insert(true);
    end;
}