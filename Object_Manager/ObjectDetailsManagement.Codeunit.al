codeunit 50100 "Object Details Management"
{
    trigger OnRun()
    begin
    end;

    procedure ConfirmCheckUpdateObjectDetails()
    var
        ConfirmMessage: Label 'The objects are not updated, do you want to update them now?';
        ProgressText: Label 'The objects are being updated...';
        Progress: Dialog;
    begin
        if CheckUpdateObjectDetails() then
            if Confirm(ConfirmMessage, true) then begin
                Progress.Open(ProgressText);
                UpdateObjectDetails();
                Progress.Close();
            end;
    end;

    procedure ConfirmCheckUpdateObjectDetailsLine()
    var
        ConfirmMessage: Label 'The fields are not updated, do you want to update them now?';
        ProgressText: Label 'The fields are being updated...';
        Progress: Dialog;
    begin
        if CheckUpdateObjectDetailsLine() then
            if Confirm(ConfirmMessage, true) then begin
                Progress.Open(ProgressText);
                UpdateObjectDetailsLine();
                Progress.Close();
            end;
    end;

    procedure CheckUpdateObjectDetailsLine(): Boolean
    var
        AllObj: Record AllObj;
        Field: Record Field;
        ObjectDetailsLine: Record "Object Details Line";
        SystemFieldIDs: Integer;
    begin
        SystemFieldIDs := 2000000000;
        ObjectDetailsLine.SetRange(ObjectType, "Object Type"::Table);
        Field.SetFilter("No.", '<%1', SystemFieldIDs);
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        if AllObj.FindFirst() then
            repeat
                Field.SetRange(TableNo, AllObj."Object ID");
                ObjectDetailsLine.SetRange(ObjectNo, AllObj."Object ID");
                if not CheckFieldsObjectDetailsLine(Field, ObjectDetailsLine) then
                    exit(true);
            until AllObj.Next() = 0;
        exit(false);
    end;

    procedure CheckUpdateObjectDetails(): Boolean
    var
        ObjectDetails: Record "Object Details";
    begin
        if CountAllObj() <> ObjectDetails.Count then
            exit(true);
        exit(false);
    end;

    procedure CountAllObj(): Integer
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

    procedure UpdateObjectDetails()
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

    procedure UpdateObjectDetailsLine()
    var
        AllObj: Record AllObj;
        Field: Record Field;
        ObjectDetailsLine: Record "Object Details Line";
        SystemFieldIDs: Integer;
        Filter: Text;
    begin
        SystemFieldIDs := 2000000000;
        ObjectDetailsLine.SetRange(ObjectType, "Object Type"::Table);
        Field.SetFilter("No.", '<%1', SystemFieldIDs);
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        if AllObj.FindFirst() then
            repeat
                Field.SetRange(TableNo, AllObj."Object ID");
                ObjectDetailsLine.SetRange(ObjectNo, AllObj."Object ID");
                if not CheckFieldsObjectDetailsLine(Field, ObjectDetailsLine) then begin
                    Filter += Format(AllObj."Object ID") + '|';
                end;
            until AllObj.Next() = 0;
        Filter := DelChr(Filter, '>', '|');
        if Filter <> '' then
            UpdateFieldsObjectDetailsLine(Filter, SystemFieldIDs);
    end;

    procedure CheckFieldsObjectDetailsLine(var Field: Record Field; var ObjectDetailsLine: Record "Object Details Line"): Boolean
    begin
        if Field.Count() <> ObjectDetailsLine.Count() then
            exit(false);

        if Field.FindSet() then
            if ObjectDetailsLine.FindSet() then
                repeat
                    if Field."No." <> ObjectDetailsLine.ID then
                        exit(false);
                    ObjectDetailsLine.Next();
                until Field.Next() = 0;
        exit(true);
    end;

    procedure UpdateFieldsObjectDetailsLine(Filter: Text; SystemFieldIDs: Integer)
    var
        Field: Record Field;
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.SetFilter(ObjectNo, Filter);
        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        Field.SetFilter(TableNo, Filter);
        Field.SetFilter("No.", '<%1', SystemFieldIDs);
        if Field.FindSet() then
            repeat
                InsertObjectDetailsLine(Field, "Object Type"::Table);
            until Field.Next() = 0;
    end;

    procedure Update(ObjectTypeObjectDetails: enum "Object Type"; ObjectTypeAllObj: Integer)
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

    procedure InsertNewRecord(var AllObj: Record AllObj; TypeOfObject: enum "Object Type")
    var
        ObjectDetails: Record "Object Details";
    begin
        ObjectDetails.Init();
        ObjectDetails.Validate(ObjectType, TypeOfObject);
        ObjectDetails.Validate(ObjectNo, AllObj."Object ID");
        ObjectDetails.Insert(true);
    end;

    procedure InsertObjectDetailsLine(var Field: Record Field; ObjectType: Enum "Object Type")
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.Init();
        ObjectDetailsLine.EntryNo := 0;
        ObjectDetailsLine.Validate(ObjectType, ObjectType);
        ObjectDetailsLine.Validate(ObjectNo, Field.TableNo);
        ObjectDetailsLine.Validate(Type, Types::Field);
        ObjectDetailsLine.Validate(ID, Field."No.");
        ObjectDetailsLine.Insert(true);
    end;

    procedure GetObjectTypeFromObjectDetails(var ObjectDetails: Record "Object Details"): Integer
    var
        AllObj: Record AllObj;
    begin
        case ObjectDetails.ObjectType of
            "Object Type"::Table:
                exit(AllObj."Object Type"::Table);
            "Object Type"::"TableExtension":
                exit(AllObj."Object Type"::"TableExtension");
            "Object Type"::Page:
                exit(AllObj."Object Type"::Page);
            "Object Type"::"PageExtension":
                exit(AllObj."Object Type"::"PageExtension");
            "Object Type"::Report:
                exit(AllObj."Object Type"::Report);
            "Object Type"::Codeunit:
                exit(AllObj."Object Type"::Codeunit);
            "Object Type"::Enum:
                exit(AllObj."Object Type"::Enum);
            "Object Type"::EnumExtension:
                exit(AllObj."Object Type"::EnumExtension);
            "Object Type"::XMLPort:
                exit(AllObj."Object Type"::XMLport);
            "Object Type"::Query:
                exit(AllObj."Object Type"::Query);
            "Object Type"::MenuSuite:
                exit(AllObj."Object Type"::MenuSuite);
        end;
    end;
}