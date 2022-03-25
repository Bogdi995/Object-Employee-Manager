codeunit 50100 "Object Details Management"
{
    var
        ModifiedObjectALCode: DotNet String;
        TriggerLbl: Label '    trigger';
        FieldTriggerLbl: Label '            trigger';
        ProcedureLbl: Label '    procedure';
        LocalProcedureLbl: Label '    local procedure';
        IntegrationEventLbl: Label '    [IntegrationEvent(%1, %2)]';
        BusinessEventLbl: Label '    [BusinessEvent(%1, %2)]';
        VarLbl: Label '    var';
        FieldVarLbl: Label '            var';
        BeginLbl: Label '    begin';
        FieldBeginLbl: Label '            begin';
        EndLbl: Label '    end;';
        FieldEndLbl: Label '            end;';
        RecordLbl: Label 'Record';
        PageLbl: Label 'Page';
        ReportLbl: Label 'Report';
        CodeunitLbl: Label 'Codeunit';

    //  -------- Object Details --------> START
    procedure ConfirmCheckUpdateObjectDetails()
    var
        ConfirmMessageLbl: Label 'The objects are not updated, do you want to update them now?';
        ProgressLbl: Label 'The objects are being updated...';
        Progress: Dialog;
    begin
        if CheckUpdateObjectDetails() then
            if Confirm(ConfirmMessageLbl, true) then begin
                Progress.Open(ProgressLbl);
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

    local procedure InsertNewRecord(AllObj: Record AllObj; TypeOfObject: enum "Object Type")
    var
        ObjectDetails: Record "Object Details";
    begin
        ObjectDetails.Init();
        ObjectDetails.Validate(ObjectType, TypeOfObject);
        ObjectDetails.Validate(ObjectNo, AllObj."Object ID");
        ObjectDetails.Insert(true);
    end;

    procedure GetShowSubtypeSingleInstance(ObjectType: Enum "Object Type"): Boolean
    begin
        if ObjectType = ObjectType::Codeunit then
            exit(true);
        exit(false);
    end;

    procedure GetShowRelations(ObjectType: Enum "Object Type"): Boolean
    begin
        if ObjectType = ObjectType::Table then
            exit(true);
        exit(false);
    end;

    procedure GetShowNoUnused(No: Integer): Boolean
    begin
        if No <> 0 then
            exit(true);
        exit(false);
    end;

    procedure GetIsEnabled(ObjectDetails: Record "Object Details"): Boolean
    begin
        if ObjectDetails.ObjectType in ["Object Type"::Table, "Object Type"::"TableExtension"] then
            exit(true);
        exit(false);
    end;
    //  -------- Object Details --------> END



    //  -------- Object Details Line (FIELDS and KEYS) --------> START
    // procedure ConfirmCheckUpdateTypeObjectDetailsLine(Type: Enum Types)
    // var
    //     Progress: Dialog;
    //     ConfirmMessage: Label 'The %1 are not updated, do you want to update them now?';
    //     ProgressText: Label 'The %1 are being updated...';
    // begin
    //     if CheckUpdateTypeObjectDetailsLine(Type) then
    //         if Confirm(StrSubstNo(ConfirmMessage, GetTypeText(Type)), true) then begin
    //             Progress.Open(StrSubstNo(ProgressText, GetTypeText(Type)));
    //             UpdateTypeObjectDetailsLine(Type);
    //             Progress.Close();
    //         end;
    // end;

    procedure CheckUpdateTypeObjectDetailsLine(ObjectDetails: Record "Object Details"; Type: Enum Types): Boolean
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

    local procedure CheckTypeObjectDetailsLine(RecRef: RecordRef; var ObjectDetailsLine: Record "Object Details Line"): Boolean
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
        FieldsLbl: Label 'fields';
        KeysLbl: Label 'keys';
    begin
        if Type = Types::Field then
            exit(FieldsLbl);
        exit(KeysLbl);
    end;

    procedure GetTypeTable(Type: Enum Types): Integer
    begin
        if Type = Type::Field then
            exit(Database::Field);
        exit(Database::"Key");
    end;

    procedure FilterOutSystemValues(Type: Enum Types; var FRef: FieldRef; RecRef: RecordRef)
    var
        SystemKey: Label '$systemId';
        SystemFieldIDs: Integer;
    begin
        case Type of
            Types::Field:
                begin
                    SystemFieldIDs := 2000000000;
                    FRef := RecRef.Field(2);
                    FRef.SetFilter('<%1', SystemFieldIDs);
                end;
            Types::"Key":
                begin
                    FRef := RecRef.Field(4);
                    FRef.SetFilter('<>%1', SystemKey);
                end;
        end;
    end;

    procedure UpdateTypeObjectDetailsLine(Type: Enum Types; var NeedsUpdate: Boolean)
    var
        Filter: Text;
    begin
        Filter := GetObjectsWhereUpdateForTypeNeeded(Type);
        if Filter <> '' then begin
            NeedsUpdate := true;
            UpdateTypeObjectDetailsLine(Filter, Type);
        end;
    end;

    procedure UpdateTypeObjectDetailsLine(Filter: Text; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
        RecRef: RecordRef;
        FRef: FieldRef;
        TableNoFRef: FieldRef;
    begin
        if Filter <> '' then begin
            RecRef.Open(GetTypeTable(Type));
            TableNoFRef := RecRef.Field(1);
            FilterOutSystemValues(Type, FRef, RecRef);
            DeleteAllObjectDetailsLine(ObjectDetailsLine, Filter, Type);

            TableNoFRef.SetFilter(Filter);
            if RecRef.FindSet() then
                repeat
                    InsertObjectDetailsLine(RecRef, "Object Type"::Table, Type);
                until RecRef.Next() = 0;
        end;
    end;

    local procedure DeleteAllObjectDetailsLine(var ObjectDetailsLine: Record "Object Details Line"; Filter: Text; Type: Enum Types)
    begin
        ObjectDetailsLine.SetFilter(ObjectNo, Filter);
        ObjectDetailsLine.SetRange(Type, Type);
        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();
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

    procedure InsertObjectDetailsLine(RecRef: RecordRef; ObjectType: Enum "Object Type"; Type: Enum Types)
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

    // Events/Methods -> Start
    [Scope('OnPrem')]
    procedure UpdateMethodsEvents(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        GlobalMethods: List of [Text];
        LocalMethods: List of [Text];
        IntegrationEvents: List of [Text];
        BusinessEvents: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);

        IntegrationEvents := GetAllEvents(ObjectALCode, IntegrationEventLbl);
        BusinessEvents := GetAllEvents(ObjectALCode, BusinessEventLbl);
        RemoveEventsFromObject(ObjectALCode, IntegrationEvents, BusinessEvents);
        IntegrationEvents := GetFormattedEvents(IntegrationEvents);
        BusinessEvents := GetFormattedEvents(BusinessEvents);

        if ObjectALCode.IndexOf(ProcedureLbl) <> -1 then
            GlobalMethods := GetMethods(ObjectALCode, ProcedureLbl);
        if ObjectALCode.IndexOf(LocalProcedureLbl) <> -1 then
            LocalMethods := GetMethods(ObjectALCode, LocalProcedureLbl);

        if not CheckObjectDetailsLine(ObjectDetails, GlobalMethods, Types::"Global Method", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, GlobalMethods, Types::"Global Method", true);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, LocalMethods, Types::"Local Method", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, LocalMethods, Types::"Local Method", true);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, IntegrationEvents, Types::"Integration Event", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, IntegrationEvents, Types::"Integration Event", true);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, BusinessEvents, Types::"Business Event", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, BusinessEvents, Types::"Business Event", true);
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetObjectALCode(ObjectDetails: Record "Object Details"; var ObjectALCode: DotNet String)
    var
        ObjectMetadataPage: Page "Object Metadata Page";
        Encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
        InStr: InStream;
    begin
        InStr := ObjectMetadataPage.GetUserALCodeInstream(ObjectDetails.ObjectTypeCopy, ObjectDetails.ObjectNo);
        ObjectALCode := StreamReader.StreamReader(InStr, Encoding.UTF8).ReadToEnd();
    end;

    [Scope('OnPrem')]
    local procedure GetAllEvents(ObjectALCode: DotNet String; EventTypeTxt: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        TypeEvents: List of [Text];
        TypeEvent: Text;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);

        repeat
            TypeEvent := GetEventParameters(CopyObjectALCode, EventTypeTxt);
            if TypeEvent <> '' then begin
                UpdateEvents(TypeEvents, CopyObjectALCode, TypeEvent, ProcedureLbl);
                UpdateEvents(TypeEvents, CopyObjectALCode, TypeEvent, LocalProcedureLbl);
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

        if TypeEventsAux.Count() <> 0 then
            foreach Member in TypeEventsAux do begin
                TypeEvents.Add(Member);
                ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
            end;
    end;

    [Scope('OnPrem')]
    local procedure RemoveEventsFromObject(ObjectALCode: DotNet String)
    var
        IntegrationEvents: List of [Text];
        BusinessEvents: List of [Text];
    begin
        IntegrationEvents := GetAllEvents(ObjectALCode, IntegrationEventLbl);
        BusinessEvents := GetAllEvents(ObjectALCode, BusinessEventLbl);
        RemoveEventsFromObject(ObjectALCode, IntegrationEvents, BusinessEvents);
    end;

    [Scope('OnPrem')]
    local procedure RemoveEventsFromObject(ObjectALCode: DotNet String; IntegrationEvents: List of [Text]; BusinessEvents: List of [Text])
    var
        Member: Text;
    begin
        foreach Member in IntegrationEvents do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
        foreach Member in BusinessEvents do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
    end;

    local procedure GetFormattedEvents(UnformattedEvents: List of [Text]): List of [Text]
    var
        FormattedEvents: List of [Text];
        Member: Text;
    begin
        foreach Member in UnformattedEvents do begin
            FormattedEvents.Add(FormatEvent(Member));
        end;

        exit(FormattedEvents);
    end;

    local procedure FormatEvent(UnformattedEvent: Text): Text
    var
        CRLF: Text[2];
        EventType: Text;
        ProcedureFromEvent: Text;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        EventType := UnformattedEvent.Substring(1, StrPos(UnformattedEvent, CRLF) - 1);
        ProcedureFromEvent := UnformattedEvent.Substring(StrLen(EventType) + 1);
        ProcedureFromEvent := DelChr(ProcedureFromEvent, '=', CRLF);
        ProcedureFromEvent := DelChr(ProcedureFromEvent, '<', ' ');
        EventType := DelChr(EventType, '<', ' ');
        exit(EventType + CRLF + ProcedureFromEvent);
    end;

    [Scope('OnPrem')]
    local procedure GetEventParameters(ObjectALCode: DotNet String; EventType: Text): Text
    var
        TrueLbl: Label 'true';
        FalseLbl: Label 'false';
    begin
        if ObjectALCode.IndexOf(StrSubstNo(EventType, TrueLbl, TrueLbl)) <> -1 then
            exit(StrSubstNo(EventType, TrueLbl, TrueLbl));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, TrueLbl, FalseLbl)) <> -1 then
            exit(StrSubstNo(EventType, TrueLbl, FalseLbl));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, FalseLbl, TrueLbl)) <> -1 then
            exit(StrSubstNo(EventType, FalseLbl, TrueLbl));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, FalseLbl, FalseLbl)) <> -1 then
            exit(StrSubstNo(EventType, FalseLbl, FalseLbl));
    end;

    [Scope('OnPrem')]
    local procedure GetEventsWithSpecificParameters(ObjectALCode: DotNet String; EventType: Text; ProcedureTypeTxt: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        CRLF: Text[2];
        Index: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(EventType);
        CopyObjectALCode := CopyObjectALCode.Substring(Index);
        if CopyObjectALCode.IndexOf(EventType + CRLF + ProcedureTypeTxt) <> -1 then
            exit(GetEvents(CopyObjectALCode, EventType, ProcedureTypeTxt));
    end;

    [Scope('OnPrem')]
    local procedure GetMethods(ObjectALCode: DotNet String; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        Substring: DotNet String;
        Methods: List of [Text];
        CRLF: Text[2];
        Method: Text;
        Character: Text;
        Index: Integer;
        SubstringIndex: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(MethodType);

        while Index <> -1 do begin
            Character := CopyObjectALCode.Substring(CopyObjectALCode.IndexOf(MethodType) - 1, 1);
            Substring := CopyObjectALCode.Substring(Index);
            SubstringIndex := Substring.IndexOf('(');
            Method := Substring.Substring(0, SubstringIndex);

            // if character before procedure is newline
            if (Character[1] = 10) then
                Methods.Add(Delchr(Method, '<', ' '));

            CopyObjectALCode := Substring.Substring(SubstringIndex);
            Index := CopyObjectALCode.IndexOf(MethodType);
        end;

        exit(Methods);
    end;

    local procedure GetTypesFromObjectDetailsLine(ObjectDetails: Record "Object Details"; Type: Enum Types): List of [Text]
    var
        ObjectDetailsLine: Record "Object Details Line";
        Types: List of [Text];
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);
        if ObjectDetailsLine.FindSet() then
            repeat
                Types.Add(ObjectDetailsLine.Name);
            until ObjectDetailsLine.Next() = 0;

        exit(Types);
    end;

    local procedure GetMethodTypeEnumFromMethodTypeText(MethodTypeText: Text): Enum Types
    begin
        if MethodTypeText = ProcedureLbl then
            exit(Types::"Global Method");
        exit(Types::"Local Method");
    end;

    [Scope('OnPrem')]
    local procedure GetEvents(ObjectALCode: DotNet String; EventType: Text; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        Substring: DotNet String;
        Events: List of [Text];
        CRLF: Text[2];
        MyEvent: Text;
        Index: Integer;
        SubstringIndex: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(MethodType);

        while Index <> -1 do begin
            Substring := CopyObjectALCode.Substring(Index);
            SubstringIndex := Substring.IndexOf('(');

            MyEvent := Substring.Substring(0, SubstringIndex);
            Events.Add(EventType + CRLF + MyEvent);

            CopyObjectALCode := Substring.Substring(SubstringIndex);
            Index := CopyObjectALCode.IndexOf(EventType + CRLF + MethodType);

            if Index <> -1 then begin
                CopyObjectALCode := CopyObjectALCode.Substring(Index);
                Index := CopyObjectALCode.IndexOf(MethodType);
            end;
        end;

        exit(Events);
    end;

    local procedure CheckObjectDetailsLine(ObjectDetails: Record "Object Details"; GivenList: List of [Text]; Type: Enum Types; IsUsed: Boolean): Boolean
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);
        if not IsUsed then
            ObjectDetailsLine.SetRange(Used, false);

        if ObjectDetailsLine.Count() <> GivenList.Count() then
            exit(false);

        if (ObjectDetailsLine.Count() = 0) and (GivenList.Count() = 0) then
            exit(true);

        if ObjectDetailsLine.Count() = 0 then
            exit(false);

        if ObjectDetailsLine.FindSet() then
            repeat
                if not GivenList.Contains(ObjectDetailsLine.Name) then
                    exit(false);
            until ObjectDetailsLine.Next() = 0;

        exit(true);
    end;

    local procedure UpdateObjectDetailsLine(ObjectDetails: Record "Object Details"; GivenList: List of [Text]; Type: Enum Types; IsUsed: Boolean)
    var
        ObjectDetailsLine: Record "Object Details Line";
        Member: Text;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);

        if not IsUsed then begin
            ObjectDetailsLine.SetRange(Used, false);
            if Type in [Types::"Global Method", Types::"Local Method", Types::"Global Variable", Types::"Local Variable"] then begin
                ModifyUsedObjectDetailsLine(ObjectDetailsLine, GivenList);
                exit;
            end;
        end;

        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        foreach Member in GivenList do
            InsertObjectDetailsLine(ObjectDetails, Member, Type);
    end;

    local procedure ModifyUsedObjectDetailsLine(var ObjectDetailsLine: Record "Object Details Line"; GivenList: List of [Text])
    begin
        if ObjectDetailsLine.FindSet() then
            repeat
                if not GivenList.Contains(ObjectDetailsLine.Name) then begin
                    ObjectDetailsLine.Validate(Used, true);
                    ObjectDetailsLine.Modify(true);
                end;
            until ObjectDetailsLine.Next() = 0;
    end;

    local procedure InsertObjectDetailsLine(ObjectDetails: Record "Object Details"; Name: Text; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.Init();
        ObjectDetailsLine.EntryNo := 0;
        ObjectDetailsLine.Validate(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.Validate(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.Validate(Type, Type);
        ObjectDetailsLine.Validate(Name, Name);
        ObjectDetailsLine.Insert(true);
    end;
    // Events/Methods -> End

    // Unused Global/Local Methods -> Start
    [Scope('OnPrem')]
    procedure UpdateUnusedMethods(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        UnusedGlobalMethods: List of [Text];
        UnusedLocalMethods: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);
        RemoveEventsFromObject(ObjectALCode);

        UnusedLocalMethods := GetUnusedMethods(ObjectDetails, ObjectALCode, LocalProcedureLbl);
        UnusedGlobalMethods := GetUnusedGlobalMethods(ObjectDetails, ObjectALCode);

        if not CheckObjectDetailsLine(ObjectDetails, UnusedGlobalMethods, Types::"Global Method", false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedGlobalMethods, Types::"Global Method", false);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, UnusedLocalMethods, Types::"Local Method", false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedLocalMethods, Types::"Local Method", false);
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetUnusedGlobalMethods(ObjectDetails: Record "Object Details"; ObjectALCode: DotNet String): List of [Text]
    var
        ObjDetails: Record "Object Details";
        CopyObjectALCode: DotNet String;
        UnusedGlobalMethods: List of [Text];
        MethodsName: List of [Text];
        ParametersNo: List of [Integer];
        Method: Text;
        SearchText: Text;
        ProgressLbl: Label 'The Unused Global Methods are being updated...';
        Progress: Dialog;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        UnusedGlobalMethods := GetUnusedMethods(ObjectDetails, CopyObjectALCode, ProcedureLbl);
        foreach Method in UnusedGlobalMethods do begin
            MethodsName.Add(DelChr(GetMethodName(Method), '<', ' '));
        end;
        ParametersNo := GetParametersNumberForGivenMethods(ObjectALCode, UnusedGlobalMethods);
        SearchText := GetSearchText(ObjectDetails);

        ObjDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', "Object Type"::Table, "Object Type"::"TableExtension", "Object Type"::Page, "Object Type"::"PageExtension", "Object Type"::Codeunit, "Object Type"::Report);
        ObjDetails.SetFilter(ObjectNo, '<%1', 2000000000);
        if ObjDetails.FindFirst() then begin
            Progress.Open(ProgressLbl);
            repeat
                GetObjectALCode(ObjDetails, ObjectALCode);
                UpdateUnusedGlobalMethods(UnusedGlobalMethods, MethodsName, ParametersNo, ObjectALCode, SearchText);
            until (ObjDetails.Next() = 0) or (UnusedGlobalMethods.Count() = 0);
            Progress.Close();
        end;

        exit(UnusedGlobalMethods);
    end;

    local procedure GetSearchText(ObjectDetails: Record "Object Details"): Text
    var
        ObjectTypeText: Text;
        ObjectName: Text;
    begin
        ObjectTypeText := GetObjectTypeText(ObjectDetails);
        ObjectName := GetObjectNameSearchText(ObjectDetails);
        exit(': ' + ObjectTypeText + ' ' + ObjectName + ';');
    end;

    local procedure GetObjectTypeText(ObjectDetails: Record "Object Details"): Text
    var
        RecordLbl: Label 'Record';
        PageLbl: Label 'Page';
        CodeunitLbl: Label 'Codeunit';
    begin
        case ObjectDetails.ObjectType of
            "Object Type"::Table, "Object Type"::TableExtension:
                exit(RecordLbl);
            "Object Type"::Page, "Object Type"::"PageExtension":
                exit(PageLbl);
            "Object Type"::Codeunit:
                exit(CodeunitLbl);
        end
    end;

    [Scope('OnPrem')]
    local procedure UpdateUnusedGlobalMethods(var UnusedGlobalMethods: List of [Text]; var MethodsName: List of [Text]; ParametersNo: List of [Integer]; ObjectALCode: DotNet String; SearchText: Text)
    var
        VariableName: Text;
        Method: Text;
        MethodsFoundIndex: List of [Integer];
        Index: Integer;
        No: Integer;
    begin
        if ObjectALCode.IndexOf(SearchText) <> -1 then begin
            VariableName := GetVariableName(ObjectALCode, SearchText);
            foreach Method in MethodsName do
                if (ObjectALCode.IndexOf(VariableName + '.' + Method) <> -1) then
                    if CheckIfMethodIsUsedInObject(ObjectALCode, VariableName + '.' + Method, ParametersNo.Get(MethodsName.IndexOf(Method))) then begin
                        MethodsFoundIndex.Add(MethodsName.IndexOf(Method) - No);
                        No += 1;
                    end;

            if MethodsFoundIndex.Count() <> 0 then
                foreach Index in MethodsFoundIndex do begin
                    ParametersNo.RemoveAt(Index);
                    UnusedGlobalMethods.RemoveAt(Index);
                    MethodsName.RemoveAt(Index);
                end;
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetVariableName(ObjectALCode: DotNet String; SearchText: Text): Text
    var
        Index: Integer;
        StartIndex: Integer;
        EndIndex: Integer;
    begin
        Index := 1;
        EndIndex := ObjectALCode.IndexOf(SearchText);
        while (ObjectALCode.Substring(EndIndex - Index, 1) <> ' ') and (ObjectALCode.Substring(EndIndex - Index, 1) <> '(') do
            Index += 1;
        StartIndex := EndIndex - Index + 1;

        exit(ObjectALCode.Substring(StartIndex, EndIndex - StartIndex));
    end;

    local procedure GetObjectNameSearchText(ObjectDetails: Record "Object Details"): Text
    begin
        ObjectDetails.CalcFields(Name);
        if ObjectDetails.Name.Contains(' ') then
            exit('"' + ObjectDetails.Name + '"');
        exit(ObjectDetails.Name);
    end;

    local procedure GetParametersNumberForGivenMethods(ObjectALCode: DotNet String; GlobalMethods: List of [Text]): List of [Integer]
    var
        ParametersNo: List of [Integer];
        Method: Text;
    begin
        foreach Method in GlobalMethods do
            ParametersNo.Add(GetParametersNumberForMethod(ObjectALCode, Method, ';', 0));

        exit(ParametersNo);
    end;

    [Scope('OnPrem')]
    local procedure GetUnusedMethods(ObjectDetails: Record "Object Details"; ObjectALCode: DotNet String; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        Methods: List of [Text];
        UnusedMethods: List of [Text];
        Method: Text;
        MethodName: Text;
        ParametersNo: Integer;
    begin
        if ObjectALCode.IndexOf(MethodType) <> -1 then
            Methods := GetTypesFromObjectDetailsLine(ObjectDetails, GetMethodTypeEnumFromMethodTypeText(MethodType));

        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        RemoveMethodsFromObject(CopyObjectALCode);

        foreach Method in Methods do begin
            ParametersNo := GetParametersNumberForMethod(ObjectALCode, Method, ';', 0);
            MethodName := GetMethodName(Method);
            if not CheckIfMethodIsUsedInObject(CopyObjectALCode, MethodName, ParametersNo) then
                UnusedMethods.Add(Method);
        end;

        exit(UnusedMethods);
    end;

    [Scope('OnPrem')]
    local procedure GetParametersNumberForMethod(ObjectALCode: DotNet String; Method: Text; Separator: Char; ExpectedParametersNo: Integer): Integer
    var
        CopyObjectALCode: DotNet String;
        MethodHeader: DotNet String;
        ParametersNo: Integer;
        Index: Integer;
        SubstringIndex: Integer;
        SubstringIndexEnd: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(Method);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index);
            SubstringIndex := CopyObjectALCode.IndexOf('(');
            SubstringIndexEnd := CopyObjectALCode.IndexOf(')');

            // Delete the method definition from object (necessary in case of overloading)
            if Separator = ';' then
                ObjectALCode := ObjectALCode.Remove(Index, SubstringIndex);

            if SubstringIndexEnd - SubstringIndex <> 1 then begin
                MethodHeader := CopyObjectALCode.Substring(SubstringIndex, SubstringIndexEnd - SubstringIndex + 1);
                while Index <> -1 do begin
                    ParametersNo += 1;
                    Index := MethodHeader.IndexOf(Separator);
                    MethodHeader := MethodHeader.Substring(Index + 1);
                end;
            end
            else
                Index := -1;

            // If a method is overloaded in the object, search other references of it
            if (Separator = ',') and (ParametersNo <> ExpectedParametersNo) then begin
                CopyObjectALCode := CopyObjectALCode.Substring(SubstringIndexEnd + 1);
                Index := CopyObjectALCode.IndexOf(Method);
                ParametersNo := 0;
            end;
        end;

        exit(ParametersNo);
    end;

    local procedure GetMethodName(Method: Text): Text
    var
        ProcedureWithoutSpacesLbl: Label 'procedure';
        LocalProcedureWithoutSpacesLbl: Label 'local procedure';
    begin
        if Method.Contains(LocalProcedureWithoutSpacesLbl) then
            exit(Method.Remove(1, StrLen(LocalProcedureWithoutSpacesLbl)));
        exit(Method.Remove(1, StrLen(ProcedureWithoutSpacesLbl)));
    end;

    [Scope('OnPrem')]
    local procedure CheckIfMethodIsUsedInObject(ObjectALCode: DotNet String; MethodName: Text; ParametersNo: Integer): Boolean
    var
        Index: Integer;
    begin
        MethodName := GetNewMethodName(MethodName, ParametersNo);
        Index := ObjectALCode.IndexOf(MethodName);

        // If method is not used in the object
        if Index = -1 then begin
            // Check also for cases where method is used in another method: List.Add(Myfunction)
            MethodName := '(' + DelChr(MethodName, '<', ' ');
            if ObjectALCode.IndexOf(MethodName) = -1 then
                exit(false);
        end;

        // If method is used in object and doesn't have parameters
        if ParametersNo = 0 then
            exit(true);

        // If method is used in the object and has one or more parameters
        if ParametersNo <> 0 then
            if ParametersNo = GetParametersNumberForMethod(ObjectALCode, MethodName, ',', ParametersNo) then
                exit(true);

        exit(false);
    end;

    local procedure GetNewMethodName(MethodName: Text; Count: Integer): Text
    begin
        if Count = 0 then
            exit(MethodName);
        exit(MethodName + '(');
    end;

    [Scope('OnPrem')]
    local procedure RemoveMethodsFromObject(ObjectALCode: DotNet String)
    var
        GlobalMethods: List of [Text];
        LocalMethods: List of [Text];
    begin
        if ObjectALCode.IndexOf(ProcedureLbl) <> -1 then
            GlobalMethods := GetMethods(ObjectALCode, ProcedureLbl);
        if ObjectALCode.IndexOf(LocalProcedureLbl) <> -1 then
            LocalMethods := GetMethods(ObjectALCode, LocalProcedureLbl);
        RemoveMethodsFromObject(ObjectALCode, GlobalMethods, LocalMethods);
    end;

    [Scope('OnPrem')]
    local procedure RemoveMethodsFromObject(ObjectALCode: DotNet String; GlobalMethods: List of [Text]; LocalMethods: List of [Text])
    var
        Member: Text;
    begin
        foreach Member in GlobalMethods do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
        foreach Member in LocalMethods do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member), StrLen(Member));
    end;
    // Unused Global/Local Methods -> End

    // Unused Parameters -> Start
    [Scope('OnPrem')]
    procedure UpdateUnusedParameters(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        UnusedParamsFromProcedures: List of [Text];
        UnusedParamsFromLocalProcedures: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);
        RemoveEventsFromObject(ObjectALCode);

        UnusedParamsFromProcedures := GetUnusedParameters(ObjectALCode, ProcedureLbl);
        UnusedParamsFromLocalProcedures := GetUnusedParameters(ObjectALCode, LocalProcedureLbl);

        if not CheckObjectDetailsLine(ObjectDetails, UnusedParamsFromProcedures, Types::Parameter, false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedParamsFromProcedures, Types::Parameter, false);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, UnusedParamsFromLocalProcedures, Types::Parameter, false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedParamsFromLocalProcedures, Types::Parameter, false);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetUnusedParameters(ObjectALCode: DotNet String; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        MethodHeader: DotNet String;
        MethodBody: DotNet String;
        StringComparison: DotNet StringComparison;
        UnusedParameters: List of [Text];
        ParametersList: List of [Text];
        Parameter: Text;
        ParameterVarLbl: Label 'var ';
        Index: Integer;
        BeginIndex: Integer;
        EndIndex: Integer;
        SubstringIndex: Integer;
        SubstringIndexEnd: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := GetIndexOfLabel(CopyObjectALCode, MethodType);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
            SubstringIndex := CopyObjectALCode.IndexOf('(');
            SubstringIndexEnd := CopyObjectALCode.IndexOf(')');
            BeginIndex := GetIndexOfLabel(CopyObjectALCode, BeginLbl);
            EndIndex := GetIndexOfLabel(CopyObjectALCode, EndLbl);
            MethodHeader := CopyObjectALCode.Substring(0, SubstringIndexEnd + 1);
            MethodBody := CopyObjectALCode.Substring(BeginIndex, EndIndex - BeginIndex + StrLen(EndLbl));

            if SubstringIndexEnd - SubstringIndex <> 1 then
                while (SubstringIndex <> 0) do begin
                    MethodHeader := MethodHeader.Substring(SubstringIndex);
                    SubstringIndex := MethodHeader.IndexOf(':');
                    Parameter := MethodHeader.Substring(1, SubstringIndex - 1);
                    if Parameter.Contains(ParameterVarLbl) then
                        Parameter := Parameter.Remove(1, 4);
                    ParametersList.Add(' ' + Parameter);
                    SubstringIndex := MethodHeader.IndexOf(';') + 1;
                end;
            Index := GetIndexOfLabel(CopyObjectALCode, MethodType);

            foreach Parameter in ParametersList do
                if MethodBody.IndexOf(Parameter, StringComparison.OrdinalIgnoreCase) = -1 then
                    if MethodBody.IndexOf('(' + DelChr(Parameter, '<', ' '), StringComparison.OrdinalIgnoreCase) = -1 then
                        UnusedParameters.Add(Parameter);

            ParametersList.RemoveRange(1, ParametersList.Count());
        end;

        exit(UnusedParameters);
    end;

    [Scope('OnPrem')]
    local procedure GetIndexOfLabel(ObjectALCode: DotNet String; GivenLabel: Text): Integer
    var
        Character: Text;
    begin
        if ObjectALCode.IndexOf(GivenLabel) = -1 then
            exit(-1);

        Character := ObjectALCode.Substring(ObjectALCode.IndexOf(GivenLabel) - 1, 1);
        // while character before given label is not newline search for the next one
        while (Character[1] <> 10) do begin
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(GivenLabel), StrLen(GivenLabel));

            if ObjectALCode.IndexOf(GivenLabel) <> -1 then
                Character := ObjectALCode.Substring(ObjectALCode.IndexOf(GivenLabel) - 1, 1)
            else
                Character[1] := 10;
        end;

        exit(ObjectALCode.IndexOf(GivenLabel));
    end;
    // Unused Parameters -> End

    // Unused Return Values -> Start
    [Scope('OnPrem')]
    procedure UpdateUnusedReturnValues(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        UnusedReturnValuesFromProcedures: List of [Text];
        UnusedReturnValuesFromLocalProcedures: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);

        UnusedReturnValuesFromProcedures := GetUnusedReturnValues(ObjectALCode, ProcedureLbl);
        UnusedReturnValuesFromLocalProcedures := GetUnusedReturnValues(ObjectALCode, LocalProcedureLbl);

        if not CheckObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromProcedures, Types::"Return Value", false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromProcedures, Types::"Return Value", false);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromLocalProcedures, Types::"Return Value", false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromLocalProcedures, Types::"Return Value", false);
        end;
    end;

    [Scope('OnPrem')]
    procedure GetUnusedReturnValues(ObjectALCode: DotNet String; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        MethodHeader: DotNet String;
        MethodBody: DotNet String;
        UnusedReturnValues: List of [Text];
        CRLF: Text[2];
        ReturnValueType: Text;
        ExitLbl: Label '    exit(';
        Index: Integer;
        BeginIndex: Integer;
        EndIndex: Integer;
        SubstringIndex: Integer;
        SubstringIndexEnd: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(MethodType);
        CRLF[1] := 13;
        CRLF[2] := 10;

        while Index <> -1 do begin
            MethodHeader := CopyObjectALCode.Substring(Index + 4);
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
            SubstringIndex := CopyObjectALCode.IndexOf('(');
            SubstringIndexEnd := CopyObjectALCode.IndexOf(')');
            MethodHeader := MethodHeader.Substring(0, SubstringIndexEnd + 2);

            if MethodHeader.Chars(MethodHeader.Length - 1) = ':' then begin
                ReturnValueType := CopyObjectALCode.Substring(SubstringIndexEnd + 3, CopyObjectALCode.IndexOf(CRLF) - (SubstringIndexEnd + 4) + StrLen(CRLF));
                BeginIndex := GetIndexOfLabel(CopyObjectALCode, BeginLbl);
                EndIndex := GetIndexOfLabel(CopyObjectALCode, EndLbl);
                MethodBody := CopyObjectALCode.Substring(BeginIndex, EndIndex - BeginIndex + StrLen(EndLbl));

                if MethodBody.IndexOf(ExitLbl) = -1 then
                    UnusedReturnValues.Add(ReturnValueType);
            end;

            Index := CopyObjectALCode.IndexOf(MethodType);
        end;

        exit(UnusedReturnValues);
    end;
    // Unused Return Values -> End

    //  -------- Object Details Line (METHODS and EVENTS) --------> END



    //  -------- Object Details Line (VARIABLES) --------> START

    // Global/Local Variables -> Start
    [Scope('OnPrem')]
    procedure UpdateVariables(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        GlobalVariables: List of [Text];
        LocalVariables: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);

        LocalVariables := GetLocalVariables(ObjectALCode, true);
        GlobalVariables := GetGlobalVariables(ObjectALCode);

        if not CheckObjectDetailsLine(ObjectDetails, GlobalVariables, Types::"Global Variable", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, GlobalVariables, Types::"Global Variable", true);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, LocalVariables, Types::"Local Variable", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, LocalVariables, Types::"Local Variable", true);
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetLocalVariables(ObjectALCode: DotNet String; IsUsed: Boolean): List of [Text]
    var
        VariablesFromTriggers: List of [Text];
        VariablesFromFieldTriggers: List of [Text];
        VariablesFromProcedures: List of [Text];
        VariablesFromLocalProcedures: List of [Text];
    begin
        VariablesFromTriggers := GetVariables(ObjectALCode, TriggerLbl, IsUsed);
        VariablesFromFieldTriggers := GetVariables(ObjectALCode, FieldTriggerLbl, IsUsed);
        VariablesFromProcedures := GetVariables(ObjectALCode, ProcedureLbl, IsUsed);
        VariablesFromLocalProcedures := GetVariables(ObjectALCode, LocalProcedureLbl, IsUsed);

        exit(GetListSum(VariablesFromTriggers, VariablesFromFieldTriggers, VariablesFromProcedures, VariablesFromLocalProcedures));
    end;

    [Scope('OnPrem')]
    local procedure GetVariables(ObjectALCode: DotNet String; Type: Text; IsUsed: Boolean): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        MethodVariables: DotNet String;
        MethodBody: DotNet String;
        StringComparison: DotNet StringComparison;
        VariablesList: List of [Text];
        UnusedVariablesList: List of [Text];
        Variable: Text;
        TextToSearch: Text;
        LocalVarLbl: Text;
        LocalBeginLbl: Text;
        LocalEndLbl: Text;
        Index: Integer;
        VarIndex: Integer;
        VariableIndex: Integer;
        BeginIndex: Integer;
        EndIndex: Integer;
        SubstringIndex: Integer;
        RemoveIndex: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := GetIndexOfLabel(CopyObjectALCode, Type);
        TextToSearch := GetTextToSearch(Type);
        SetLocalLabels(TextToSearch, LocalVarLbl, LocalBeginLbl, LocalEndLbl);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
            RemoveIndex := ObjectALCode.IndexOf(CopyObjectALCode);
            VarIndex := GetIndexOfLabel(CopyObjectALCode, LocalVarLbl);
            BeginIndex := GetIndexOfLabel(CopyObjectALCode, LocalBeginLbl);

            if not IsUsed then begin
                EndIndex := GetIndexOfLabel(CopyObjectALCode, LocalEndLbl);
                MethodBody := CopyObjectALCode.Substring(BeginIndex, EndIndex - BeginIndex + StrLen(LocalEndLbl));
            end;

            if (VarIndex <> -1) and (VarIndex < BeginIndex) then begin
                MethodVariables := CopyObjectALCode.Substring(VarIndex, BeginIndex - VarIndex);
                RemoveIndex += VarIndex;
                ObjectALCode := ObjectALCode.Remove(RemoveIndex, StrLen(LocalVarLbl));
                SubstringIndex := MethodVariables.IndexOf(TextToSearch) + StrLen(TextToSearch);

                while (SubstringIndex <> StrLen(TextToSearch) - 1) do begin
                    MethodVariables := MethodVariables.Substring(SubstringIndex);
                    SubstringIndex := MethodVariables.IndexOf(':');
                    Variable := MethodVariables.Substring(0, SubstringIndex);
                    VariablesList.Add(Variable);
                    MethodVariables := MethodVariables.Substring(MethodVariables.IndexOf(';'));
                    SubstringIndex := MethodVariables.IndexOf(TextToSearch) + StrLen(TextToSearch);
                end;

                if not IsUsed then begin
                    foreach Variable in VariablesList do begin
                        if MethodBody.IndexOf(' ' + Variable, StringComparison.OrdinalIgnoreCase) = -1 then
                            if MethodBody.IndexOf('(' + Variable, StringComparison.OrdinalIgnoreCase) = -1 then
                                UnusedVariablesList.Add(Variable);

                        VariableIndex := GetVariableIndex(MethodBody, Variable);
                        while VariableIndex <> -1 do begin
                            MethodBody := MethodBody.Remove(VariableIndex, StrLen(Variable) + 1);
                            VariableIndex := GetVariableIndex(MethodBody, Variable);
                        end;
                    end;

                    VariablesList.RemoveRange(1, VariablesList.Count());
                end;
            end;

            if not IsUsed then
                ModifiedObjectALCode := MethodBody.Concat(ModifiedObjectALCode, MethodBody);

            Index := GetIndexOfLabel(CopyObjectALCode, Type);
        end;

        if IsUsed then
            exit(VariablesList);

        exit(UnusedVariablesList);
    end;

    local procedure SetLocalLabels(TextToSearch: Text; var LocalVarLbl: Text; var LocalBeginLbl: Text; var LocalEndLbl: Text)
    begin
        if StrLen(TextToSearch) > 8 then begin
            LocalVarLbl := FieldVarLbl;
            LocalBeginLbl := FieldBeginLbl;
            LocalEndLbl := FieldEndLbl;
            exit;
        end;

        LocalVarLbl := VarLbl;
        LocalBeginLbl := BeginLbl;
        LocalEndLbl := EndLbl;
    end;

    local procedure SetLocalLabels(TextToSearch: Text; var LocalVarLbl: Text; var LocalBeginLbl: Text)
    begin
        if StrLen(TextToSearch) > 8 then begin
            LocalVarLbl := FieldVarLbl;
            LocalBeginLbl := FieldBeginLbl;
            exit;
        end;

        LocalVarLbl := VarLbl;
        LocalBeginLbl := BeginLbl;
    end;

    [Scope('OnPrem')]
    local procedure GetVariableIndex(Method: DotNet String; Variable: Text): Integer
    var
        Index: Integer;
    begin
        Index := SearchIndexForVariable(Method, ' ' + Variable);
        if Index <> -1 then
            exit(Index);

        Index := SearchIndexForVariable(Method, '(' + Variable);
        if Index <> -1 then
            exit(Index);

        exit(-1);
    end;

    [Scope('OnPrem')]
    local procedure SearchIndexForVariable(Method: DotNet String; Variable: Text): Integer
    begin
        if Method.IndexOf(Variable) <> -1 then begin
            if (Method.IndexOf(Variable + ' ') <> -1) then
                exit(Method.IndexOf(Variable + ' '));
            if (Method.IndexOf(Variable + ')') <> -1) then
                exit(Method.IndexOf(Variable + ')'));
            if (Method.IndexOf(Variable + ';') <> -1) then
                exit(Method.IndexOf(Variable + ';'));
            if (Method.IndexOf(Variable + '.') <> -1) then
                exit(Method.IndexOf(Variable + '.'));
            if (Method.IndexOf(Variable + ',') <> -1) then
                exit(Method.IndexOf(Variable + ','));
        end;

        exit(-1);
    end;

    local procedure GetListSum(FirstList: List of [Text]; SecondList: List of [Text]): List of [Text]
    var
        Element: Text;
    begin
        foreach Element in FirstList do
            SecondList.Add(Element);

        exit(SecondList);
    end;

    local procedure GetListSum(FirstList: List of [Text]; SecondList: List of [Text]; ThirdList: List of [Text]): List of [Text]
    var
        Element: Text;
    begin
        foreach Element in FirstList do
            SecondList.Add(Element);

        exit(GetListSum(SecondList, ThirdList));
    end;

    local procedure GetListSum(FirstList: List of [Text]; SecondList: List of [Text]; ThirdList: List of [Text]; FourthList: List of [Text]): List of [Text]
    var
        Element: Text;
    begin
        foreach Element in FirstList do
            SecondList.Add(Element);

        exit(GetListSum(SecondList, ThirdList, FourthList));
    end;

    local procedure DeleteDuplicates(GivenList: List of [Text]): List of [Text]
    var
        Element: Text;
        ResultList: List of [Text];
    begin
        foreach Element in GivenList do
            if not ResultList.Contains(Element) then
                ResultList.Add(Element);

        exit(ResultList);
    end;

    [Scope('OnPrem')]
    local procedure GetGlobalVariables(ObjectALCode: DotNet String): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        VariablesList: List of [Text];
        Variable: Text;
        Index: Integer;
        SubstringIndex: Integer;
        EndOfGlobalVariables: Boolean;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := GetIndexOfLabel(ObjectALCode, VarLbl);

        if Index <> -1 then begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index);
            SubstringIndex := CopyObjectALCode.IndexOf('        ') + StrLen('        ');

            while (SubstringIndex <> 7) and not EndOfGlobalVariables do begin
                CopyObjectALCode := CopyObjectALCode.Substring(SubstringIndex);
                SubstringIndex := CopyObjectALCode.IndexOf(':');
                Variable := CopyObjectALCode.Substring(0, SubstringIndex);
                VariablesList.Add(Variable);
                SubstringIndex := CopyObjectALCode.IndexOf(';');
                CopyObjectALCode := CopyObjectALCode.Substring(SubstringIndex);
                SubstringIndex := CopyObjectALCode.IndexOf('        ');
                EndOfGlobalVariables := GetEndOfGlobalVariables(CopyObjectALCode, SubstringIndex);
                SubstringIndex += StrLen('        ');
            end;
        end;

        exit(VariablesList);
    end;

    [Scope('OnPrem')]
    local procedure GetEndOfGlobalVariables(ObjectALCode: DotNet String; IndexOfNextPossibleGlobalVariable: Integer): Boolean
    var
        CopyObjectALCode: DotNet String;
        TriggerIndex: Integer;
        ProcedureIndex: Integer;
        LocalProcedureIndex: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        TriggerIndex := GetIndexOfLabel(CopyObjectALCode, TriggerLbl);
        ProcedureIndex := GetIndexOfLabel(CopyObjectALCode, ProcedureLbl);
        LocalProcedureIndex := GetIndexOfLabel(CopyObjectALCode, LocalProcedureLbl);

        if ((IndexOfNextPossibleGlobalVariable > TriggerIndex) and (TriggerIndex <> -1)) or
            ((IndexOfNextPossibleGlobalVariable > ProcedureIndex) and (ProcedureIndex <> -1)) or
            ((IndexOfNextPossibleGlobalVariable > LocalProcedureIndex) and (LocalProcedureIndex <> -1)) then
            exit(true);

        exit(false);
    end;

    [Scope('OnPrem')]
    procedure UpdateUnusedVariables(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        UnusedGlobalVariables: List of [Text];
        UnusedLocalVariables: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);

        UnusedLocalVariables := GetLocalVariables(ObjectALCode, false);
        UnusedGlobalVariables := GetUnusedGlobalVariables(ObjectALCode, ObjectDetails);

        if not CheckObjectDetailsLine(ObjectDetails, UnusedGlobalVariables, Types::"Global Variable", false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedGlobalVariables, Types::"Global Variable", false);
        end;
        if not CheckObjectDetailsLine(ObjectDetails, UnusedLocalVariables, Types::"Local Variable", false) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, UnusedLocalVariables, Types::"Local Variable", false);
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetUnusedGlobalVariables(ObjectALCode: DotNet String; ObjectDetails: Record "Object Details"): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        GlobalVariables: List of [Text];
        UnusedGlobalVariables: List of [Text];
        Variable: Text;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        GlobalVariables := GetTypesFromObjectDetailsLine(ObjectDetails, Types::"Global Variable");

        if not ModifiedObjectALCode.IsNullOrEmpty(ModifiedObjectALCode) then
            CopyObjectALCode := CopyObjectALCode.Copy(ModifiedObjectALCode);

        foreach Variable in GlobalVariables do
            if GetVariableIndex(CopyObjectALCode, Variable) = -1 then
                UnusedGlobalVariables.Add(Variable);

        exit(UnusedGlobalVariables);
    end;
    // Global/Local Variables -> End

    //  -------- Object Details Line (VARIABLES) --------> END



    //  -------- Object Details Line (RELATIONS) --------> START

    // Relations From / Relations To -> Start
    procedure UpdateRelations(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean; RelationType: Enum Types)
    begin
        if not CheckRelations(ObjectDetails, RelationType) then begin
            NeedsUpdate := true;
            UpdateRelationType(ObjectDetails, RelationType);
        end;
    end;

    local procedure CheckRelations(ObjectDetails: Record "Object Details"; RelationType: Enum Types): Boolean
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
        ObjectDetailsLine: Record "Object Details Line";
    begin
        SetCorrectRangeBasedOnRelationType(TableRelationsMetadata, ObjectDetails, RelationType);
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, RelationType);

        if ObjectDetailsLine.Count() <> TableRelationsMetadata.Count() then
            exit(false);

        if (ObjectDetailsLine.Count() = 0) and (TableRelationsMetadata.Count() = 0) then
            exit(true);

        if ObjectDetailsLine.Count() = 0 then
            exit(false);

        if TableRelationsMetadata.FindSet() then
            repeat
                SetCorrectRangeObjectDetailsLineBasedOnRelationType(TableRelationsMetadata, ObjectDetailsLine, RelationType);
                ObjectDetailsLine.SetFilter(TypeName, '%1', Format(TableRelationsMetadata."Field No.") + ' "' + TableRelationsMetadata."Field Name" + '"');
                if ObjectDetailsLine.IsEmpty() then
                    exit(false);
            until TableRelationsMetadata.Next() = 0;

        exit(true);
    end;

    local procedure UpdateRelationType(ObjectDetails: Record "Object Details"; RelationType: Enum Types)
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, RelationType);

        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        SetCorrectRangeBasedOnRelationType(TableRelationsMetadata, ObjectDetails, RelationType);

        if TableRelationsMetadata.FindSet() then
            repeat
                InsertRelationObjectDetailsLine(ObjectDetails, TableRelationsMetadata, RelationType);
            until TableRelationsMetadata.Next() = 0;
    end;

    local procedure InsertRelationObjectDetailsLine(ObjectDetails: Record "Object Details"; TableRelationsMetadata: Record "Table Relations Metadata"; RelationType: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.Init();
        ObjectDetailsLine.ObjectType := "Object Type"::Table;
        ObjectDetailsLine.ObjectNo := ObjectDetails.ObjectNo;
        ObjectDetailsLine.Type := RelationType;
        ObjectDetailsLine.ID := GetTableIDFromRelationType(TableRelationsMetadata, RelationType);
        ObjectDetailsLine.Name := GetTableNameFromRelationType(TableRelationsMetadata, RelationType);
        ObjectDetailsLine.TypeName := Format(TableRelationsMetadata."Field No.") + ' "' + TableRelationsMetadata."Field Name" + '"';
        ObjectDetailsLine.Insert(true);
    end;

    local procedure GetTableIDFromRelationType(TableRelationsMetadata: Record "Table Relations Metadata"; RelationType: Enum Types): Integer
    begin
        if RelationType = RelationType::"Relation (External)" then
            exit(TableRelationsMetadata."Table ID");
        exit(TableRelationsMetadata."Related Table ID");
    end;

    local procedure GetTableNameFromRelationType(TableRelationsMetadata: Record "Table Relations Metadata"; RelationType: Enum Types): Text[30]
    begin
        if RelationType = RelationType::"Relation (External)" then
            exit(TableRelationsMetadata."Table Name");
        exit(TableRelationsMetadata."Related Table Name");
    end;

    local procedure SetCorrectRangeBasedOnRelationType(var TableRelationsMetadata: Record "Table Relations Metadata"; ObjectDetails: Record "Object Details"; RelationType: Enum Types)
    begin
        if RelationType = Types::"Relation (Internal)" then
            TableRelationsMetadata.SetRange("Table ID", ObjectDetails.ObjectNo)
        else
            TableRelationsMetadata.SetRange("Related Table ID", ObjectDetails.ObjectNo);
    end;

    local procedure SetCorrectRangeObjectDetailsLineBasedOnRelationType(TableRelationsMetadata: Record "Table Relations Metadata"; var ObjectDetailsLine: Record "Object Details Line"; RelationType: Enum Types)
    begin
        if RelationType = Types::"Relation (Internal)" then
            ObjectDetailsLine.SetRange(ID, TableRelationsMetadata."Related Table ID")
        else
            ObjectDetailsLine.SetRange(ID, TableRelationsMetadata."Table ID");
    end;
    // Relations From / Relations To -> End


    // No. of Objects Used in -> Start
    [Scope('OnPrem')]
    procedure UpdateNoOfObjectsUsedIn(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        ObjectALCode: DotNet String;
        ObjectsUsedInCode: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);

        ObjectsUsedInCode := GetObjectsUsedInCode(ObjectALCode);

        if not CheckObjectDetailsLine(ObjectDetails, ObjectsUsedInCode, Types::"Object (Internal)", true) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, ObjectsUsedInCode, Types::"Object (Internal)", true);
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetObjectsUsedInCode(ObjectALCode: DotNet String): List of [Text]
    var
        ObjectsUsedInTriggers: List of [Text];
        ObjectsUsedInFieldTriggers: List of [Text];
        ObjectsUsedInProcedures: List of [Text];
        ObjectsUsedInLocalProcedures: List of [Text];
    begin
        ObjectsUsedInTriggers := GetObjectsUsedIn(ObjectALCode, TriggerLbl);
        ObjectsUsedInFieldTriggers := GetObjectsUsedIn(ObjectALCode, FieldTriggerLbl);
        ObjectsUsedInProcedures := GetObjectsUsedIn(ObjectALCode, ProcedureLbl);
        ObjectsUsedInLocalProcedures := GetObjectsUsedIn(ObjectALCode, LocalProcedureLbl);

        exit(DeleteDuplicates(GetListSum(ObjectsUsedInTriggers, ObjectsUsedInFieldTriggers, ObjectsUsedInProcedures, ObjectsUsedInLocalProcedures)));
    end;

    [Scope('OnPrem')]
    local procedure GetObjectsUsedIn(ObjectALCode: DotNet String; Type: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        CodeFromType: Dotnet String;
        TotalObjectsUsedIn: List of [Text];
        ObjectsFromParameters: List of [Text];
        ObjectsFromVariables: List of [Text];
        Index: Integer;
        EndIndex: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := GetIndexOfLabel(CopyObjectALCode, Type);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
            EndIndex := GetIndexOfLabel(CopyObjectALCode, EndLbl);
            CodeFromType := CopyObjectALCode.Substring(0, EndIndex + StrLen(EndLbl));

            ObjectsFromParameters := GetObjectsFromParameters(CodeFromType);
            ObjectsFromVariables := GetObjectsFromVariables(CodeFromType, Type);
            if (ObjectsFromParameters.Count() <> 0) or (ObjectsFromVariables.Count() <> 0) then
                TotalObjectsUsedIn := GetListSum(TotalObjectsUsedIn, ObjectsFromParameters, ObjectsFromVariables);

            CopyObjectALCode := CopyObjectALCode.Substring(EndIndex + StrLen(EndLbl));
            Index := GetIndexOfLabel(CopyObjectALCode, Type);
        end;

        exit(TotalObjectsUsedIn);
    end;

    [Scope('OnPrem')]
    local procedure GetObjectsFromParameters(ALCode: DotNet String): List of [Text]
    var
        CopyALCode: DotNet String;
        ObjectsFromParameters: List of [Text];
        ParameterType: Text;
        Index: Integer;
        OpenParanthesisIndex: Integer;
        CloseParanthesisIndex: Integer;
    begin
        CopyALCode := CopyALCode.Copy(ALCode);
        OpenParanthesisIndex := CopyALCode.IndexOf('(');
        CloseParanthesisIndex := CopyALCode.IndexOf(')');
        CopyALCode := CopyALCode.Substring(OpenParanthesisIndex, CloseParanthesisIndex - OpenParanthesisIndex + 1);

        if (CloseParanthesisIndex - OpenParanthesisIndex <> 1) then begin
            Index := CopyALCode.IndexOf(';');

            while Index <> -1 do begin
                ParameterType := CopyALCode.Substring(CopyALCode.IndexOf(':') + 2, Index - (CopyALCode.IndexOf(':') + 2));
                if ParameterType.Contains(RecordLbl) then
                    ObjectsFromParameters.Add(ParameterType);

                CopyALCode := CopyALCode.Substring(Index + 2);
                Index := CopyALCode.IndexOf(';');
            end;

            ParameterType := CopyALCode.Substring(CopyALCode.IndexOf(':') + 2, CopyALCode.IndexOf(')') - (CopyALCode.IndexOf(':') + 2));
            if ParameterType.Contains(RecordLbl) then
                ObjectsFromParameters.Add(ParameterType);
        end;

        exit(ObjectsFromParameters);
    end;

    [Scope('OnPrem')]
    local procedure GetObjectsFromVariables(ALCode: DotNet String; Type: Text): List of [Text]
    var
        CopyALCode: DotNet String;
        ObjectsFromVariables: List of [Text];
        VariableType: Text;
        TextToSearch: Text;
        LocalVarLbl: Text;
        LocalBeginLbl: Text;
        Index: Integer;
        VarIndex: Integer;
        BeginIndex: Integer;
    begin
        CopyALCode := CopyALCode.Copy(ALCode);
        TextToSearch := GetTextToSearch(Type);
        SetLocalLabels(TextToSearch, LocalVarLbl, LocalBeginLbl);
        VarIndex := CopyALCode.IndexOf(LocalVarLbl);

        if VarIndex = -1 then
            exit;

        BeginIndex := CopyALCode.IndexOf(LocalBeginLbl);
        CopyALCode := CopyALCode.Substring(VarIndex, BeginIndex - VarIndex);

        Index := CopyALCode.IndexOf(TextToSearch) + StrLen(TextToSearch);
        while (Index <> StrLen(TextToSearch) - 1) do begin
            CopyALCode := CopyALCode.Substring(Index);
            Index := CopyALCode.IndexOf(':');
            VariableType := CopyALCode.Substring(Index + 2, CopyALCode.IndexOf(';') - (Index + 2));

            if VariableType.Contains(RecordLbl) or VariableType.Contains(PageLbl)
                or VariableType.Contains(ReportLbl) or VariableType.Contains(CodeunitLbl) then
                ObjectsFromVariables.Add(VariableType);

            CopyALCode := CopyALCode.Substring(CopyALCode.IndexOf(';') + 1);
            Index := CopyALCode.IndexOf(TextToSearch) + StrLen(TextToSearch);
        end;

        exit(ObjectsFromVariables);
    end;

    local procedure GetTextToSearch(Type: Text): Text
    begin
        if Type = FieldTriggerLbl then
            exit('                ');
        exit('        ');
    end;
    // No. of Objects Used in -> End


    // Used in No. of Objects -> Start
    [Scope('OnPrem')]
    procedure UpdateUsedInNoOfObjects(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        UsedInNoObjectsList: List of [Text];
    begin
        UsedInNoObjectsList := GetUsedInNoObjectsList(ObjectDetails);

        if not CheckUsedInNoObjectsObjectDetailsLine(ObjectDetails, UsedInNoObjectsList, Types::"Object (External)") then begin
            NeedsUpdate := true;
            UpdateUsedInNoObjectsObjectDetailsLine(ObjectDetails, UsedInNoObjectsList, Types::"Object (External)");
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetUsedInNoObjectsList(ObjectDetails: Record "Object Details"): List of [Text]
    var
        ObjDetails: Record "Object Details";
        ObjectALCode: DotNet String;
        UsedInNoObjectsList: List of [Text];
        SearchText: Text;
        ProgressLbl: Label 'The number of times the object is used in other objects is being updated...';
        Progress: Dialog;
    begin
        SearchText := GetSearchText(ObjectDetails);

        ObjDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', "Object Type"::Table, "Object Type"::"TableExtension", "Object Type"::Page, "Object Type"::"PageExtension", "Object Type"::Codeunit, "Object Type"::Report);
        ObjDetails.SetFilter(ObjectNo, '<%1', 2000000000);
        if ObjDetails.FindFirst() then begin
            Progress.Open(ProgressLbl);
            repeat
                GetObjectALCode(ObjDetails, ObjectALCode);
                UpdateUsedInNoObjectsList(ObjDetails, UsedInNoObjectsList, ObjectALCode, SearchText);
            until (ObjDetails.Next() = 0);
            Progress.Close();
        end;

        exit(UsedInNoObjectsList);
    end;

    local procedure UpdateUsedInNoObjectsList(ObjectDetails: Record "Object Details"; var UsedInNoObjectsList: List of [Text]; ObjectALCode: Dotnet String; SearchText: Text)
    begin
        if ObjectALCode.IndexOf(SearchText) <> -1 then begin
            UsedInNoObjectsList.Add(Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + GetObjectNameSearchText(ObjectDetails));
        end;
    end;

    local procedure CheckUsedInNoObjectsObjectDetailsLine(ObjectDetails: Record "Object Details"; UsedInNoObjectsList: List of [Text]; Type: Enum Types): Boolean
    var
        ObjectDetailsLine: Record "Object Details Line";
        Object: Text;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);

        if (ObjectDetailsLine.Count() <> UsedInNoObjectsList.Count()) or (ObjectDetailsLine.Count() = 0) then
            exit(false);

        if (ObjectDetailsLine.Count() = 0) and (UsedInNoObjectsList.Count() = 0) then
            exit(true);

        foreach Object in UsedInNoObjectsList do begin
            ObjectDetailsLine.SetRange(ID, GetObjectID(Object));
            ObjectDetailsLine.SetRange(Name, GetObjectName(Object));
            ObjectDetailsLine.SetRange(TypeName, Object);

            if ObjectDetailsLine.IsEmpty() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure GetObjectID(Object: Text): Integer
    var
        ID: Integer;
    begin
        Object := CopyStr(Object, StrPos(Object, ' ') + 1, StrLen(Object) - 1);
        Evaluate(ID, CopyStr(Object, 1, StrPos(Object, ' ') - 1));

        exit(ID);
    end;

    local procedure GetObjectName(Object: Text): Text
    var
        Index: Integer;
    begin
        for Index := 1 to 2 do
            Object := CopyStr(Object, StrPos(Object, ' ') + 1, StrLen(Object) - 1);

        Object := DelChr(Object, '>', '"');
        Object := DelChr(Object, '<', '"');

        exit(Object);
    end;

    local procedure UpdateUsedInNoObjectsObjectDetailsLine(ObjectDetails: Record "Object Details"; UsedInNoObjectsList: List of [Text]; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
        Object: Text;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);

        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        foreach Object in UsedInNoObjectsList do
            InsertUsedInNoObjectsObjectDetailsLine(ObjectDetails, Object, Type);

    end;

    local procedure InsertUsedInNoObjectsObjectDetailsLine(ObjectDetails: Record "Object Details"; Object: Text; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.Init();
        ObjectDetailsLine.ObjectType := ObjectDetails.ObjectType;
        ObjectDetailsLine.ObjectNo := ObjectDetails.ObjectNo;
        ObjectDetailsLine.Type := Type;
        ObjectDetailsLine.ID := GetObjectID(Object);
        ObjectDetailsLine.Name := GetObjectName(Object);
        ObjectDetailsLine.TypeName := Object;
        ObjectDetailsLine.Insert(true);
    end;
    // Used in No. of Objects -> End


    //  -------- Object Details Line (RELATIONS) --------> END



    //  -------- Others -------> START
    procedure GetObjectTypeFromObjectDetails(ObjectDetails: Record "Object Details"): Integer
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
