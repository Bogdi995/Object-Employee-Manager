codeunit 50100 "Object Details Management"
{
    trigger OnRun()
    begin
    end;

    //  -------- Object Details --------> START
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

    procedure CheckUpdateObjectDetails(): Boolean
    var
        ObjectDetails: Record "Object Details";
    begin
        if CountAllObj() <> ObjectDetails.Count then
            exit(true);
        exit(false);
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

    local procedure Update(ObjectTypeObjectDetails: Enum "Object Type"; ObjectTypeAllObj: Integer)
    var
        AllObj: Record AllObj;
        ObjectDetails: Record "Object Details";
    begin
        AllObj.SetRange("Object Type", ObjectTypeAllObj);
        ObjectDetails.SetRange(ObjectType, ObjectTypeObjectDetails);
        if AllObj.FindSet() then
            if ObjectDetails.FindSet() then begin
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

    procedure GetShowSubtype(ObjectType: Enum "Object Type"): Boolean
    begin
        if ObjectType = ObjectType::Codeunit then
            exit(true);
        exit(false);
    end;

    procedure GetShowNoUnused(No: Integer): Boolean
    begin
        if No <> 0 then
            exit(true);
        exit(false);
    end;
    //  -------- Object Details --------> END



    //  -------- Object Details Line (FIELDS and KEYS) --------> START
    procedure ConfirmCheckUpdateTypeObjectDetailsLine(Type: Enum Types)
    var
        Progress: Dialog;
        ConfirmMessage: Label 'The %1 are not updated, do you want to update them now?';
        ProgressText: Label 'The %1 are being updated...';
    begin
        if CheckUpdateTypeObjectDetailsLine(Type) then
            if Confirm(StrSubstNo(ConfirmMessage, GetTypeText(Type)), true) then begin
                Progress.Open(StrSubstNo(ProgressText, GetTypeText(Type)));
                UpdateTypeObjectDetailsLine(Type);
                Progress.Close();
            end;
    end;

    procedure CheckUpdateTypeObjectDetailsLine(Type: Enum Types): Boolean
    var
        AllObj: Record AllObj;
        ObjectDetailsLine: Record "Object Details Line";
        RecRef: RecordRef;
        FRef: FieldRef;
        TableNoFRef: FieldRef;
    begin
        RecRef.Open(GetTypeTable(Type));
        TableNoFRef := RecRef.Field(1);
        FilterOutSystemValues(Type, FRef, RecRef);

        ObjectDetailsLine.SetRange(ObjectType, "Object Type"::Table);
        ObjectDetailsLine.SetRange(Type, Type);
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        if AllObj.FindSet() then
            repeat
                TableNoFRef.SetRange(AllObj."Object ID");
                ObjectDetailsLine.SetRange(ObjectNo, AllObj."Object ID");
                if not CheckTypeObjectDetailsLine(RecRef, ObjectDetailsLine) then
                    exit(true);
            until AllObj.Next() = 0;
        exit(false);
    end;

    procedure CheckUpdateTypeObjectDetailsLine(var ObjectDetails: Record "Object Details"; Type: Enum Types): Boolean
    var
        ObjectDetailsLine: Record "Object Details Line";
        RecRef: RecordRef;
        FRef: FieldRef;
        TableNoFRef: FieldRef;
    begin
        RecRef.Open(GetTypeTable(Type));
        TableNoFRef := RecRef.Field(1);
        TableNoFRef.SetRange(ObjectDetails.ObjectNo);
        FilterOutSystemValues(Type, FRef, RecRef);

        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);

        if not CheckTypeObjectDetailsLine(RecRef, ObjectDetailsLine) then
            exit(true);
        exit(false);
    end;

    local procedure CheckTypeObjectDetailsLine(var RecRef: RecordRef; var ObjectDetailsLine: Record "Object Details Line"): Boolean
    begin
        if RecRef.Count() <> ObjectDetailsLine.Count() then
            exit(false);

        if RecRef.FindSet() then
            if ObjectDetailsLine.FindSet() then
                repeat
                    if Format(RecRef.Field(2)) <> Format(ObjectDetailsLine.ID) then
                        exit(false);
                    ObjectDetailsLine.Next();
                until RecRef.Next() = 0;
        exit(true);
    end;


    local procedure GetTypeText(Type: Enum Types): Text
    var
        FieldsText: Label 'fields';
        KeysText: Label 'keys';
    begin
        if Type = Types::Field then
            exit(FieldsText);
        exit(KeysText);
    end;

    procedure GetTypeTable(Type: Enum Types): Integer
    begin
        if Type = Type::Field then
            exit(Database::Field);
        exit(Database::"Key");
    end;

    procedure FilterOutSystemValues(Type: Enum Types; var FRef: FieldRef; var Recref: RecordRef)
    var
        SystemKey: Label '$systemId';
        SystemFieldIDs: Integer;
    begin
        if Type = Types::Field then begin
            SystemFieldIDs := 2000000000;
            FRef := RecRef.Field(2);
            FRef.SetFilter('<%1', SystemFieldIDs);
        end
        else begin
            FRef := RecRef.Field(4);
            FRef.SetFilter('<>%1', SystemKey);
        end;
    end;

    procedure UpdateTypeObjectDetailsLine(Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
        RecRef: RecordRef;
        FRef: FieldRef;
        TableNoFRef: FieldRef;
        Filter: Text;
    begin
        Filter := GetObjectsWhereUpdateForTypeNeeded(Type);
        RecRef.Open(GetTypeTable(Type));
        TableNoFRef := RecRef.Field(1);
        FilterOutSystemValues(Type, FRef, RecRef);

        if Filter <> '' then begin
            ObjectDetailsLine.SetFilter(ObjectNo, Filter);
            ObjectDetailsLine.SetRange(Type, Type);
            if ObjectDetailsLine.FindSet() then
                ObjectDetailsLine.DeleteAll();

            TableNoFRef.SetFilter(Filter);
            if RecRef.FindSet() then
                repeat
                    InsertObjectDetailsLine(RecRef, "Object Type"::Table, Type);
                until RecRef.Next() = 0;
        end;
    end;

    procedure UpdateTypeObjectDetailsLine(Filter: Text; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
        RecRef: RecordRef;
        FRef: FieldRef;
        TableNoFRef: FieldRef;
    begin
        RecRef.Open(GetTypeTable(Type));
        TableNoFRef := RecRef.Field(1);
        FilterOutSystemValues(Type, FRef, RecRef);

        if Filter <> '' then begin
            ObjectDetailsLine.SetFilter(ObjectNo, Filter);
            ObjectDetailsLine.SetRange(Type, Type);
            if ObjectDetailsLine.FindSet() then
                ObjectDetailsLine.DeleteAll();

            TableNoFRef.SetFilter(Filter);
            if RecRef.FindSet() then
                repeat
                    InsertObjectDetailsLine(RecRef, "Object Type"::Table, Type);
                until RecRef.Next() = 0;
        end;
    end;

    local procedure GetObjectsWhereUpdateForTypeNeeded(Type: Enum Types): Text
    var
        AllObj: Record AllObj;
        ObjectDetailsLine: Record "Object Details Line";
        RecRef: RecordRef;
        FRef: FieldRef;
        TableNoFRef: FieldRef;
        Filter: Text;

    begin
        RecRef.Open(GetTypeTable(Type));
        TableNoFRef := RecRef.Field(1);
        FilterOutSystemValues(Type, FRef, RecRef);

        ObjectDetailsLine.SetRange(ObjectType, "Object Type"::Table);
        ObjectDetailsLine.SetRange(Type, Type);
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        if AllObj.FindSet() then
            repeat
                TableNoFRef.SetRange(AllObj."Object ID");
                ObjectDetailsLine.SetRange(ObjectNo, AllObj."Object ID");
                if not CheckTypeObjectDetailsLine(RecRef, ObjectDetailsLine) then
                    Filter += Format(AllObj."Object ID") + '|';
            until AllObj.Next() = 0;
        Filter := DelChr(Filter, '>', '|');
        exit(Filter);
    end;

    procedure InsertObjectDetailsLine(var RecRef: RecordRef; ObjectType: Enum "Object Type"; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.Init();
        ObjectDetailsLine.EntryNo := 0;
        ObjectDetailsLine.Validate(ObjectType, ObjectType);
        ObjectDetailsLine.Validate(ObjectNo, RecRef.Field(1).Value);
        ObjectDetailsLine.Validate(Type, Type);
        ObjectDetailsLine.Validate(ID, RecRef.Field(2).Value);
        ObjectDetailsLine.Insert(true);
    end;
    //  -------- Object Details Line (FIELDS and KEYS) --------> END



    //  -------- Object Details Line (METHODS and EVENTS) --------> START
    [Scope('OnPrem')]
    procedure CheckUpdateUnusedParameters(var ObjectDetails: Record "Object Details"): Boolean
    var
        ObjectMetadataPage: Page "Object Metadata Page";
        Encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
        ObjectALCode: DotNet String;
        InStr: InStream;
        ProcedureTxt: Label '    procedure';
        LocalProcedureTxt: Label '    local procedure';
    begin
        InStr := ObjectMetadataPage.GetUserALCodeInstream(ObjectDetails.ObjectTypeCopy, ObjectDetails.ObjectNo);
        ObjectALCode := StreamReader.StreamReader(InStr, Encoding.UTF8).ReadToEnd();
        if GetUnusedParameters(ObjectALCode, ProcedureTxt) + GetUnusedParameters(ObjectALCode, LocalProcedureTxt) = 0 then
            exit(true);
        exit(false);
    end;

    [Scope('OnPrem')]
    procedure GetUnusedParameters(ObjectALCode: DotNet String; MethodType: Text): Integer
    var
        CopyObjectALCode: DotNet String;
        MethodALCode: DotNet String;
        MethodHeader: DotNet String;
        MethodBody: DotNet String;
        ParametersList: List of [Text];
        Parameter: Text;
        EndTxt: Label '    end;';
        VarTxt: Label 'var ';
        UnusedParameters: Integer;
        Index: Integer;
        SubstringIndex: Integer;
        SubstringIndexEnd: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        // RemoveEventsFromObject(CopyObjectALCode);
        Index := CopyObjectALCode.IndexOf(MethodType);

        repeat
            MethodHeader := CopyObjectALCode.Substring(Index + 4);
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
            SubstringIndex := MethodHeader.IndexOf('(');
            SubstringIndexEnd := MethodHeader.IndexOf(')');
            MethodBody := MethodHeader.Substring(SubstringIndexEnd + 2, MethodHeader.IndexOf(EndTxt) - (SubstringIndexEnd + 2) + StrLen(EndTxt));
            MethodHeader := MethodHeader.Substring(0, SubstringIndexEnd + 1);

            if SubstringIndexEnd - SubstringIndex <> 1 then
                while (SubstringIndex <> 0) do begin
                    MethodHeader := MethodHeader.Substring(SubstringIndex);
                    SubstringIndex := MethodHeader.IndexOf(':');
                    Parameter := MethodHeader.Substring(1, SubstringIndex - 1);
                    if Parameter.Contains(VarTxt) then
                        Parameter := Parameter.Remove(1, 4);
                    ParametersList.Add(Parameter);
                    SubstringIndex := MethodHeader.IndexOf(';') + 1;
                end;
            Index := CopyObjectALCode.IndexOf(MethodType);

            foreach Parameter in ParametersList do
                if not MethodBody.Contains(Parameter) then
                    UnusedParameters += 1;
            ParametersList.RemoveRange(1, ParametersList.Count());
        until Index = -1;

        exit(UnusedParameters);
    end;

    [Scope('OnPrem')]
    local procedure RemoveEventsFromObject(ObjectALCode: DotNet String; IntegrationEvents: List of [Text]; BusinessEvents: List of [Text])
    var
        CRLF: Text[2];
        Member: Text;
        IntegrationEventTxt: Label '    [IntegrationEvent(%1, %2)]';
        BusinessEventTxt: Label '    [BusinessEvent(%1, %2)]';
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        foreach Member in IntegrationEvents do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
        foreach Member in BusinessEvents do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
    end;

    [Scope('OnPrem')]
    local procedure RemoveEventsFromObject(ObjectALCode: DotNet String; EventType: Text; ProcedureType: Text)
    var
        CRLF: Text[2];
        EventAndProcedure: Text;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        EventAndProcedure := EventType + CRLF + ProcedureType;
        ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(EventAndProcedure), StrLen(EventAndProcedure));
    end;

    [Scope('OnPrem')]
    procedure CheckUpdateMethodsEventsObjectDetailsLine(var ObjectDetails: Record "Object Details"): Boolean
    var
        ObjectMetadataPage: Page "Object Metadata Page";
        Encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
        ObjectALCode: DotNet String;
        InStr: InStream;
        GlobalMethods: List of [Text];
        LocalMethods: List of [Text];
        IntegrationEvents: List of [Text];
        BusinessEvents: List of [Text];
        ProcedureTxt: Label '    procedure';
        LocalProcedureTxt: Label '    local procedure';
        IntegrationEventTxt: Label '    [IntegrationEvent(%1, %2)]';
        BusinessEventTxt: Label '    [BusinessEvent(%1, %2)]';
    begin
        InStr := ObjectMetadataPage.GetUserALCodeInstream(ObjectDetails.ObjectTypeCopy, ObjectDetails.ObjectNo);
        ObjectALCode := StreamReader.StreamReader(InStr, Encoding.UTF8).ReadToEnd();

        IntegrationEvents := GetEvents(ObjectALCode, IntegrationEventTxt);
        BusinessEvents := GetEvents(ObjectALCode, BusinessEventTxt);
        RemoveEventsFromObject(ObjectALCode, IntegrationEvents, BusinessEvents);

        if ObjectALCode.IndexOf(ProcedureTxt) <> -1 then
            GlobalMethods := GetMethods(ObjectALCode, ProcedureTxt, false, '');
        if ObjectALCode.IndexOf(LocalProcedureTxt) <> -1 then
            LocalMethods := GetMethods(ObjectALCode, LocalProcedureTxt, false, '');

        if CheckMethodsEvents(ObjectDetails, GlobalMethods, Types::"Global Method") and CheckMethodsEvents(ObjectDetails, LocalMethods, Types::"Local Method")
            and CheckMethodsEvents(ObjectDetails, IntegrationEvents, Types::"Integration Event") and CheckMethodsEvents(ObjectDetails, BusinessEvents, Types::"Business Event") then
            exit(false);
        exit(true);
    end;

    [Scope('OnPrem')]
    procedure UpdateMethodsEventsObjectDetailsLine(var ObjectDetails: Record "Object Details")
    var
        ObjectMetadataPage: Page "Object Metadata Page";
        Encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
        ObjectALCode: DotNet String;
        InStr: InStream;
        GlobalMethods: List of [Text];
        LocalMethods: List of [Text];
        IntegrationEvents: List of [Text];
        BusinessEvents: List of [Text];
        ProcedureTxt: Label '    procedure';
        LocalProcedureTxt: Label '    local procedure';
        IntegrationEventTxt: Label '    [IntegrationEvent(%1, %2)]';
        BusinessEventTxt: Label '    [BusinessEvent(%1, %2)]';
    begin
        InStr := ObjectMetadataPage.GetUserALCodeInstream(ObjectDetails.ObjectTypeCopy, ObjectDetails.ObjectNo);
        ObjectALCode := StreamReader.StreamReader(InStr, Encoding.UTF8).ReadToEnd();

        IntegrationEvents := GetEvents(ObjectALCode, IntegrationEventTxt);
        BusinessEvents := GetEvents(ObjectALCode, BusinessEventTxt);
        RemoveEventsFromObject(ObjectALCode, IntegrationEvents, BusinessEvents);

        if ObjectALCode.IndexOf(ProcedureTxt) <> -1 then
            GlobalMethods := GetMethods(ObjectALCode, ProcedureTxt, false, '');
        if ObjectALCode.IndexOf(LocalProcedureTxt) <> -1 then
            LocalMethods := GetMethods(ObjectALCode, LocalProcedureTxt, false, '');

        UpdateMethodsEvents(ObjectDetails, GlobalMethods, Types::"Global Method");
        UpdateMethodsEvents(ObjectDetails, LocalMethods, Types::"Local Method");
        UpdateMethodsEvents(ObjectDetails, IntegrationEvents, Types::"Integration Event");
        UpdateMethodsEvents(ObjectDetails, BusinessEvents, Types::"Business Event");
    end;

    [Scope('OnPrem')]
    local procedure GetEvents(ObjectALCode: DotNet String; EventTypeTxt: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        TypeEvents: List of [Text];
        TypeEvent: Text;
        ProcedureTxt: Label '    procedure';
        LocalProcedureTxt: Label '    local procedure';
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        repeat
            TypeEvent := GetEventParameters(CopyObjectALCode, EventTypeTxt);
            if TypeEvent <> '' then begin
                UpdateEvents(TypeEvents, CopyObjectALCode, TypeEvent, ProcedureTxt);
                UpdateEvents(TypeEvents, CopyObjectALCode, TypeEvent, LocalProcedureTxt);
            end;
        until TypeEvent = '';
        exit(TypeEvents);
    end;

    [Scope('OnPrem')]
    local procedure UpdateEvents(var TypeEvents: List of [Text]; ObjectALCode: DotNet String; EventType: Text; ProcedureType: Text)
    var
        TypeEventsAux: List of [Text];
        Member: Text;
    begin
        TypeEventsAux := GetEventsWithSpecificParameters(ObjectALCode, EventType, ProcedureType);
        if TypeEventsAux.Count <> 0 then begin
            foreach Member in TypeEventsAux do
                TypeEvents.Add(Member);
            RemoveEventsFromObject(ObjectALCode, EventType, ProcedureType);
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetEventParameters(ObjectALCode: DotNet String; EventType: Text): Text
    var
        TrueTxt: Label 'true';
        FalseTxt: Label 'false';
    begin
        if ObjectALCode.IndexOf(StrSubstNo(EventType, TrueTxt, TrueTxt)) <> -1 then
            exit(StrSubstNo(EventType, TrueTxt, TrueTxt));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, TrueTxt, FalseTxt)) <> -1 then
            exit(StrSubstNo(EventType, TrueTxt, FalseTxt));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, FalseTxt, TrueTxt)) <> -1 then
            exit(StrSubstNo(EventType, FalseTxt, TrueTxt));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, FalseTxt, FalseTxt)) <> -1 then
            exit(StrSubstNo(EventType, FalseTxt, FalseTxt));
    end;

    [Scope('OnPrem')]
    local procedure GetEventsWithSpecificParameters(ObjectALCode: DotNet String; EventType: Text; ProcedureTypeTxt: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        Index: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(EventType);
        CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
        if CopyObjectALCode.IndexOf(ProcedureTypeTxt) <> -1 then
            exit(GetMethods(CopyObjectALCode, ProcedureTypeTxt, true, EventType));
    end;

    [Scope('OnPrem')]
    local procedure GetMethods(ObjectALCode: DotNet String; MethodType: Text; IsEvent: Boolean; EventType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        Substring: DotNet String;
        Methods: List of [Text];
        CRLF: Text[2];
        JValue: JsonValue;
        Index: Integer;
        SubstringIndex: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(MethodType);

        repeat
            Substring := CopyObjectALCode.Substring(Index);
            SubstringIndex := Substring.IndexOf('(');
            JValue.SetValue(Substring.Substring(0, SubstringIndex));

            if IsEvent then
                Methods.Add(DelChr(EventType + CRLF + Format(JValue), '=', '"'))
            else
                Methods.Add(Delchr(Format(JValue), '=', '"'));

            CopyObjectALCode := Substring.Substring(SubstringIndex);
            Index := CopyObjectALCode.IndexOf(MethodType);
        until Index = -1;

        exit(Methods);
    end;

    // procedure CheckIfMethodIsNotEvent(IntegrationEvents: List of [Text]; BusinessEvents: List of [Text]; NewMethod: Text): Boolean
    // var
    //     Member: Text;
    // begin
    //     foreach Member in IntegrationEvents do
    //         if StrPos(Member, NewMethod) <> 0 then
    //             exit(false);
    //     foreach Member in BusinessEvents do
    //         if StrPos(Member, NewMethod) <> 0 then
    //             exit(false);
    //     exit(true);
    // end;

    procedure CheckMethodsEvents(var ObjectDetails: Record "Object Details"; GivenList: List of [Text]; Type: Enum Types): Boolean
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);
        if ObjectDetailsLine.FindSet() then
            repeat
                if not GivenList.Contains(ObjectDetailsLine.Name) then
                    exit(false);
            until ObjectDetailsLine.Next() = 0
        else
            exit(false);
        exit(true);
    end;

    procedure UpdateMethodsEvents(var ObjectDetails: Record "Object Details"; GivenList: List of [Text]; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
        Member: Text;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);
        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        foreach Member in GivenList do
            InsertObjectDetailsLine(ObjectDetails, DelChr(Member, '=', ' '), Type);
    end;

    local procedure InsertObjectDetailsLine(var ObjectDetails: Record "Object Details"; MethodEventName: Text; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.Init();
        ObjectDetailsLine.EntryNo := 0;
        ObjectDetailsLine.Validate(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.Validate(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.Validate(Type, Type);
        ObjectDetailsLine.Validate(Name, MethodEventName);
        ObjectDetailsLine.Insert(true);
    end;

    //  -------- Object Details Line (METHODS and EVENTS) --------> END



    //  -------- Others -------> START
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
    //  -------- Others -------> END

}