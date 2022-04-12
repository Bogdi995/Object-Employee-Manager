codeunit 50100 "Object Details Management"
{
    var
        ModifiedObjectALCode: DotNet String;
        StringComparison: DotNet StringComparison;
        TriggerLbl: Label '    trigger';
        FieldTriggerLbl: Label '            trigger';
        ProcedureLbl: Label '    procedure';
        LocalProcedureLbl: Label '    local procedure';
        InternalProcedureLbl: Label '    internal procedure';
        ProtectedProcedureLbl: Label '    protected procedure';
        IntegrationEventLbl: Label '    [IntegrationEvent(%1, %2)]';
        BusinessEventLbl: Label '    [BusinessEvent(%1, %2)]';
        VarLbl: Label '    var';
        FieldVarLbl: Label '            var';
        BeginLbl: Label '    begin';
        FieldBeginLbl: Label '            begin';
        EndLbl: Label '    end;';
        FieldEndLbl: Label '            end;';
        ScopeOnPremLbl: Label '    [Scope(''OnPrem'')]';
        NonDebuggableLbl: Label '    [NonDebuggable]';
        ObsoleteLbl: Label '    [Obsolete';
        CommentLbl: Label '    //';

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

    procedure UpdateAllType(Type: Enum Types)
    var
        AllObj: Record AllObj;
        ObjectDetails: Record "Object Details";
        Progress: Dialog;
        Object: Text;
    begin
        ObjectDetails.SetRange(ObjectType, ObjectDetails.ObjectType::Table);

        if ObjectDetails.FindSet() then begin
            Progress.Open(GetLabel(Type), Object);
            repeat
                ObjectDetails.CalcFields(Name);
                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                Progress.Update();

                if CheckUpdateTypeObjectDetailsLine(ObjectDetails, Type) then
                    UpdateTypeObjectDetailsLine(Format(ObjectDetails.ObjectNo), Type);
            until ObjectDetails.Next() = 0;
            Progress.Close();
        end;
    end;

    local procedure GetLabel(Type: Enum Types): Text
    var
        UpdateFieldsLbl: Label 'The fields are beign updated...\\#1';
        UpdateKeysLbl: Label 'The keys are beign updated...\\#1';
    begin
        if Type = Type::Field then
            exit(UpdateFieldsLbl);
        exit(UpdateKeysLbl);
    end;
    //  -------- Object Details Line (FIELDS and KEYS) --------> END



    //  -------- Object Details Line (METHODS and EVENTS) --------> START

    // Events/Methods -> Start
    [Scope('OnPrem')]
    procedure UpdateMethodsEvents(ObjectDetails: Record "Object Details"; var NeedsUpdate: array[4] of Boolean; UpdateUnusedGlobal: Boolean)
    var
        ObjectALCode: DotNet String;
        GlobalMethods: List of [Text];
        LocalMethods: List of [Text];
        InternalMethods: List of [Text];
        ProtectedMethods: List of [Text];
        IntegrationEvents: List of [Text];
        BusinessEvents: List of [Text];
    begin
        GetObjectALCode(ObjectDetails, ObjectALCode);
        RemoveTypeFromObject(ObjectALCode, ScopeOnPremLbl);
        RemoveTypeFromObject(ObjectALCode, NonDebuggableLbl);
        RemoveObsoleteFromObject(ObjectALCode);

        IntegrationEvents := GetAllEvents(ObjectALCode, IntegrationEventLbl);
        BusinessEvents := GetAllEvents(ObjectALCode, BusinessEventLbl);
        RemoveEventsFromObject(ObjectALCode, IntegrationEvents, BusinessEvents);
        IntegrationEvents := GetFormattedEvents(IntegrationEvents);
        BusinessEvents := GetFormattedEvents(BusinessEvents);

        if ObjectALCode.IndexOf(ProcedureLbl, StringComparison.OrdinalIgnoreCase) <> -1 then
            GlobalMethods := GetMethods(ObjectALCode, ProcedureLbl);
        if ObjectALCode.IndexOf(LocalProcedureLbl, StringComparison.OrdinalIgnoreCase) <> -1 then
            LocalMethods := GetMethods(ObjectALCode, LocalProcedureLbl);
        if ObjectALCode.IndexOf(InternalProcedureLbl, StringComparison.OrdinalIgnoreCase) <> -1 then
            InternalMethods := GetMethods(ObjectALCode, InternalProcedureLbl);
        if ObjectALCode.IndexOf(ProtectedProcedureLbl, StringComparison.OrdinalIgnoreCase) <> -1 then
            ProtectedMethods := GetMethods(ObjectALCode, ProtectedProcedureLbl);

        CheckAndUpdateObjectDetailsLine(ObjectDetails, GlobalMethods, Types::"Global Method", true, NeedsUpdate[1]);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, LocalMethods, Types::"Local Method", true, NeedsUpdate[1]);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, InternalMethods, Types::"Internal Method", true, NeedsUpdate[1]);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, IntegrationEvents, Types::"Integration Event", true, NeedsUpdate[1]);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, BusinessEvents, Types::"Business Event", true, NeedsUpdate[1]);

        UpdateUnusedMethods(ObjectDetails, ObjectALCode, NeedsUpdate[2], UpdateUnusedGlobal);
        UpdateUnusedParameters(ObjectDetails, ObjectALCode, NeedsUpdate[3]);
        UpdateUnusedReturnValues(ObjectDetails, ObjectALCode, NeedsUpdate[4]);
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
                UpdateEvents(TypeEvents, CopyObjectALCode, TypeEvent, InternalProcedureLbl);
                UpdateEvents(TypeEvents, CopyObjectALCode, TypeEvent, ProtectedProcedureLbl);
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
                ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member, StringComparison.OrdinalIgnoreCase), StrLen(Member));
            end;
    end;

    [Scope('OnPrem')]
    local procedure RemoveEventsFromObject(ObjectALCode: DotNet String; IntegrationEvents: List of [Text]; BusinessEvents: List of [Text])
    var
        Member: Text;
    begin
        foreach Member in IntegrationEvents do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member, StringComparison.OrdinalIgnoreCase), StrLen(Member));
        foreach Member in BusinessEvents do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(Member, StringComparison.OrdinalIgnoreCase), StrLen(Member));
    end;

    [Scope('OnPrem')]
    local procedure RemoveTypeFromObject(ObjectALCode: DotNet String; GivenType: Text)
    begin
        while ObjectALCode.IndexOf(GivenType, StringComparison.OrdinalIgnoreCase) <> -1 do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(GivenType, StringComparison.OrdinalIgnoreCase) - 2, StrLen(GivenType) + 2);
    end;

    [Scope('OnPrem')]
    local procedure RemoveObsoleteFromObject(ObjectALCode: DotNet String)
    var
        ObsoleteString: DotNet String;
        ObsoleteIndex: Integer;
    begin
        ObsoleteIndex := ObjectALCode.IndexOf(ObsoleteLbl, StringComparison.OrdinalIgnoreCase);

        while ObsoleteIndex <> -1 do begin
            ObsoleteString := ObjectALCode.Substring(ObsoleteIndex);
            ObsoleteString := ObsoleteString.Substring(0, ObsoleteString.IndexOf(']') + 1);
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(ObsoleteString, StringComparison.OrdinalIgnoreCase) - 2, StrLen(ObsoleteString) + 2);
            ObsoleteIndex := ObjectALCode.IndexOf(ObsoleteLbl, StringComparison.OrdinalIgnoreCase);
        end;
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
        if ObjectALCode.IndexOf(StrSubstNo(EventType, TrueLbl, TrueLbl), StringComparison.OrdinalIgnoreCase) <> -1 then
            exit(StrSubstNo(EventType, TrueLbl, TrueLbl));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, TrueLbl, FalseLbl), StringComparison.OrdinalIgnoreCase) <> -1 then
            exit(StrSubstNo(EventType, TrueLbl, FalseLbl));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, FalseLbl, TrueLbl), StringComparison.OrdinalIgnoreCase) <> -1 then
            exit(StrSubstNo(EventType, FalseLbl, TrueLbl));
        if ObjectALCode.IndexOf(StrSubstNo(EventType, FalseLbl, FalseLbl), StringComparison.OrdinalIgnoreCase) <> -1 then
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
        Index := CopyObjectALCode.IndexOf(EventType + CRLF + ProcedureTypeTxt, StringComparison.OrdinalIgnoreCase);

        if Index <> -1 then begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index);
            exit(GetEvents(CopyObjectALCode, EventType, ProcedureTypeTxt));
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetMethods(ObjectALCode: DotNet String; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        Substring: DotNet String;
        Methods: List of [Text];
        Method: Text;
        Character: Text;
        Index: Integer;
        SubstringIndex: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        Index := CopyObjectALCode.IndexOf(MethodType, StringComparison.OrdinalIgnoreCase);

        while Index <> -1 do begin
            Character := CopyObjectALCode.Substring(CopyObjectALCode.IndexOf(MethodType, StringComparison.OrdinalIgnoreCase) - 1, 1);
            Substring := CopyObjectALCode.Substring(Index);
            SubstringIndex := Substring.IndexOf('(');
            Method := Substring.Substring(0, SubstringIndex);

            // if character before procedure is newline
            if (Character[1] = 10) then
                Methods.Add(Delchr(Method, '<', ' '));

            CopyObjectALCode := Substring.Substring(SubstringIndex);
            Index := CopyObjectALCode.IndexOf(MethodType, StringComparison.OrdinalIgnoreCase);
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
        MethodDefinition: DotNet String;
        Events: List of [Text];
        CRLF: Text[2];
        Index: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index);
            CopyObjectALCode := CopyObjectALCode.Substring(CopyObjectALCode.IndexOf(MethodType));
            MethodDefinition := CopyObjectALCode.Substring(0, CopyObjectALCode.IndexOf('('));
            Events.Add(EventType + CRLF + MethodDefinition);
            Index := CopyObjectALCode.IndexOf(EventType + CRLF + MethodType, StringComparison.OrdinalIgnoreCase);
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

        if (ObjectDetailsLine.Count() = 0) and (GivenList.Count() = 0) then
            exit(true);

        if (ObjectDetailsLine.Count() <> GivenList.Count()) or (ObjectDetailsLine.Count() = 0) then
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

    local procedure CheckAndUpdateObjectDetailsLine(ObjectDetails: Record "Object Details"; GivenList: List of [Text]; Type: Enum Types; IsUsed: Boolean; var NeedsUpdate: Boolean)
    begin
        if not CheckObjectDetailsLine(ObjectDetails, GivenList, Type, IsUsed) then begin
            NeedsUpdate := true;
            UpdateObjectDetailsLine(ObjectDetails, GivenList, Type, IsUsed);
        end;
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
    procedure UpdateUnusedMethods(ObjectDetails: Record "Object Details"; ObjectALCode: DotNet String; var NeedsUpdate: Boolean; UpdateUnusedGlobal: Boolean)
    var
        UnusedGlobalMethods: List of [Text];
        UnusedLocalMethods: List of [Text];
    begin
        UnusedLocalMethods := GetUnusedMethods(ObjectDetails, ObjectALCode, LocalProcedureLbl);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedLocalMethods, Types::"Local Method", false, NeedsUpdate);

        if UpdateUnusedGlobal then begin
            UnusedGlobalMethods := GetUnusedGlobalMethods(ObjectDetails, ObjectALCode);
            CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedGlobalMethods, Types::"Global Method", false, NeedsUpdate);
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
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        UnusedGlobalMethods := GetUnusedMethods(ObjectDetails, CopyObjectALCode, ProcedureLbl);
        foreach Method in UnusedGlobalMethods do begin
            MethodsName.Add(DelChr(GetMethodName(Method), '<', ' '));
        end;
        ParametersNo := GetParametersNumberForGivenMethods(ObjectALCode, UnusedGlobalMethods);
        SearchText := GetSearchText(ObjectDetails);

        ObjDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', "Object Type"::Table,
                                "Object Type"::"TableExtension", "Object Type"::Page,
                                "Object Type"::"PageExtension", "Object Type"::Codeunit,
                                "Object Type"::Report);
        ObjDetails.SetFilter(ObjectNo, '<%1', 2000000000);
        if ObjDetails.FindSet() then
            repeat
                GetObjectALCode(ObjDetails, CopyObjectALCode);
                UpdateUnusedGlobalMethods(UnusedGlobalMethods, MethodsName, ParametersNo, CopyObjectALCode, SearchText);
            until (ObjDetails.Next() = 0) or (UnusedGlobalMethods.Count() = 0);

        exit(UnusedGlobalMethods);
    end;

    local procedure GetSearchText(ObjectDetails: Record "Object Details"): Text
    var
        ObjectTypeText: Text;
        ObjectName: Text;
    begin
        ObjectTypeText := GetObjectTypeText(ObjectDetails);
        ObjectName := GetObjectNameSearchText(ObjectDetails);
        exit(': ' + ObjectTypeText + ' ' + ObjectName);
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
        if ObjectALCode.IndexOf(SearchText, StringComparison.OrdinalIgnoreCase) <> -1 then begin
            VariableName := GetVariableName(ObjectALCode, SearchText);
            foreach Method in MethodsName do
                if (ObjectALCode.IndexOf(VariableName + '.' + Method, StringComparison.OrdinalIgnoreCase) <> -1) then
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
        EndIndex := ObjectALCode.IndexOf(SearchText, StringComparison.OrdinalIgnoreCase);
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
        if ObjectALCode.IndexOf(MethodType, StringComparison.OrdinalIgnoreCase) <> -1 then
            Methods := GetTypesFromObjectDetailsLine(ObjectDetails, GetMethodTypeEnumFromMethodTypeText(MethodType));

        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        RemoveMethodsFromObject(ObjectDetails, CopyObjectALCode);

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
        Index := CopyObjectALCode.IndexOf(Method, StringComparison.OrdinalIgnoreCase);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 1);
            SubstringIndex := CopyObjectALCode.IndexOf('(');
            SubstringIndexEnd := GetEndOfMethod(CopyObjectALCode);

            // Delete the method definition from object (necessary in case of overloading)
            if Separator = ';' then begin
                SubstringIndexEnd := CopyObjectALCode.IndexOf(')');
                ObjectALCode := ObjectALCode.Remove(Index, SubstringIndex);
            end;

            if SubstringIndexEnd - SubstringIndex <> 1 then begin
                MethodHeader := CopyObjectALCode.Substring(SubstringIndex + 1, SubstringIndexEnd - SubstringIndex + 1);
                while Index <> -1 do begin
                    ParametersNo += 1;
                    Index := GetSeparatorIndex(MethodHeader, Separator);
                    MethodHeader := MethodHeader.Substring(Index + 1);
                end;
            end
            else
                Index := -1;

            // If a method is overloaded in the object, search other references of it
            if (Separator = ',') and (ParametersNo <> ExpectedParametersNo) then begin
                CopyObjectALCode := CopyObjectALCode.Substring(SubstringIndexEnd + 1);
                Index := CopyObjectALCode.IndexOf(Method, StringComparison.OrdinalIgnoreCase);
                ParametersNo := 0;
            end;
        end;

        exit(ParametersNo);
    end;

    [Scope('OnPrem')]
    local procedure GetSeparatorIndex(MethodHeader: DotNet String; Separator: Char): Integer
    begin
        // for cases like:  MyFunction(param1, CallFunc(x, y), param3);
        if Separator = ',' then
            if (MethodHeader.IndexOf('(') <> -1) and (MethodHeader.IndexOf(Separator) > MethodHeader.IndexOf('(')) then
                MethodHeader := MethodHeader.Substring(MethodHeader.IndexOf(')'));

        exit(MethodHeader.IndexOf(Separator));
    end;

    [Scope('OnPrem')]
    local procedure GetEndOfMethod(ObjectALCode: DotNet String): Integer
    var
        CRLF: Text[2];
        Cnt: Integer;
        Index: array[6] of Integer;
        MinimumIndex: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        MinimumIndex := 2000000000;
        Index[1] := ObjectALCode.IndexOf(');');
        Index[2] := ObjectALCode.IndexOf(') ');
        Index[3] := ObjectALCode.IndexOf(')' + CRLF);
        Index[4] := ObjectALCode.IndexOf('));');
        Index[5] := ObjectALCode.IndexOf(')) ');
        Index[6] := ObjectALCode.IndexOf('))' + CRLF);
        for Cnt := 1 to 4 do
            if (Index[Cnt] <> -1) and (Index[Cnt] < MinimumIndex) then
                MinimumIndex := Index[Cnt];

        exit(MinimumIndex);
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
        Index := ObjectALCode.IndexOf(MethodName, StringComparison.OrdinalIgnoreCase);

        // If method is not used in the object
        if Index = -1 then begin
            // Check also for cases where method is used in another method: List.Add(Myfunction)
            MethodName := '(' + DelChr(MethodName, '<', ' ');
            if ObjectALCode.IndexOf(MethodName, StringComparison.OrdinalIgnoreCase) = -1 then
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
    local procedure RemoveMethodsFromObject(ObjectDetails: Record "Object Details"; ObjectALCode: DotNet String)
    var
        GlobalMethods: List of [Text];
        LocalMethods: List of [Text];
    begin
        if ObjectALCode.IndexOf(ProcedureLbl, StringComparison.OrdinalIgnoreCase) <> -1 then
            GlobalMethods := GetTypesFromObjectDetailsLine(ObjectDetails, Types::"Global Method");
        if ObjectALCode.IndexOf(LocalProcedureLbl, StringComparison.OrdinalIgnoreCase) <> -1 then
            LocalMethods := GetTypesFromObjectDetailsLine(ObjectDetails, Types::"Local Method");
        RemoveMethodsFromObject(ObjectALCode, GlobalMethods, LocalMethods);
    end;

    [Scope('OnPrem')]
    local procedure RemoveMethodsFromObject(ObjectALCode: DotNet String; GlobalMethods: List of [Text]; LocalMethods: List of [Text])
    var
        Member: Text;
    begin
        foreach Member in GlobalMethods do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf('    ' + Member), StrLen('    ') + StrLen(Member));
        foreach Member in LocalMethods do
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf('    ' + Member), StrLen('    ') + StrLen(Member));
    end;
    // Unused Global/Local Methods -> End

    // Unused Parameters -> Start
    [Scope('OnPrem')]
    procedure UpdateUnusedParameters(ObjectDetails: Record "Object Details"; ObjectALCode: DotNet String; var NeedsUpdate: Boolean)
    var
        UnusedParamsFromProcedures: List of [Text];
        UnusedParamsFromLocalProcedures: List of [Text];
        UnusedParamsFromInternalProcedures: List of [Text];
        UnusedParamsFromProtectedProcedures: List of [Text];
    begin
        UnusedParamsFromProcedures := GetUnusedParameters(ObjectALCode, ProcedureLbl);
        UnusedParamsFromLocalProcedures := GetUnusedParameters(ObjectALCode, LocalProcedureLbl);
        UnusedParamsFromInternalProcedures := GetUnusedParameters(ObjectALCode, InternalProcedureLbl);
        UnusedParamsFromProtectedProcedures := GetUnusedParameters(ObjectALCode, ProtectedProcedureLbl);

        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedParamsFromProcedures, Types::Parameter, false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedParamsFromLocalProcedures, Types::Parameter, false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedParamsFromInternalProcedures, Types::Parameter, false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedParamsFromProtectedProcedures, Types::Parameter, false, NeedsUpdate);
    end;

    [Scope('OnPrem')]
    procedure GetUnusedParameters(ObjectALCode: DotNet String; MethodType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        MethodHeader: DotNet String;
        MethodBody: DotNet String;
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
        CopyObjectALCode: DotNet String;
        Character: Text;
        IndexOfGivenLabel: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        CopyObjectALCode := CopyObjectALCode.ToLower();
        IndexOfGivenLabel := CopyObjectALCode.IndexOf(GivenLabel);

        if IndexOfGivenLabel = -1 then
            exit(-1);

        Character := CopyObjectALCode.Substring(IndexOfGivenLabel - 1, 1);
        while (Character[1] <> 10) do begin
            ObjectALCode := ObjectALCode.Remove(IndexOfGivenLabel, StrLen(GivenLabel));
            CopyObjectALCode := CopyObjectALCode.Remove(IndexOfGivenLabel, StrLen(GivenLabel));
            IndexOfGivenLabel := CopyObjectALCode.IndexOf(GivenLabel);

            if IndexOfGivenLabel <> -1 then
                Character := CopyObjectALCode.Substring(IndexOfGivenLabel - 1, 1)
            else
                Character[1] := 10;
        end;

        exit(IndexOfGivenLabel);
    end;

    [Scope('OnPrem')]
    local procedure GetIndexOfLabel(ObjectALCode: DotNet String; GivenLabel: Text; var TextLengthDeletedFromOriginal: Integer): Integer
    var
        Character: Text;
    begin
        if ObjectALCode.IndexOf(GivenLabel, StringComparison.OrdinalIgnoreCase) = -1 then
            exit(-1);

        Character := ObjectALCode.Substring(ObjectALCode.IndexOf(GivenLabel, StringComparison.OrdinalIgnoreCase) - 1, 1);
        while (Character[1] <> 10) do begin
            ObjectALCode := ObjectALCode.Remove(ObjectALCode.IndexOf(GivenLabel, StringComparison.OrdinalIgnoreCase), StrLen(GivenLabel));
            TextLengthDeletedFromOriginal += StrLen(GivenLabel);

            if ObjectALCode.IndexOf(GivenLabel, StringComparison.OrdinalIgnoreCase) <> -1 then
                Character := ObjectALCode.Substring(ObjectALCode.IndexOf(GivenLabel, StringComparison.OrdinalIgnoreCase) - 1, 1)
            else
                Character[1] := 10;
        end;

        exit(ObjectALCode.IndexOf(GivenLabel, StringComparison.OrdinalIgnoreCase));
    end;
    // Unused Parameters -> End

    // Unused Return Values -> Start
    [Scope('OnPrem')]
    procedure UpdateUnusedReturnValues(ObjectDetails: Record "Object Details"; ObjectALCode: DotNet String; var NeedsUpdate: Boolean)
    var
        UnusedReturnValuesFromProcedures: List of [Text];
        UnusedReturnValuesFromLocalProcedures: List of [Text];
        UnusedReturnValuesFromInternalProcedures: List of [Text];
        UnusedReturnValuesFromProtectedProcedures: List of [Text];
    begin
        UnusedReturnValuesFromProcedures := GetUnusedReturnValues(ObjectALCode, ProcedureLbl);
        UnusedReturnValuesFromLocalProcedures := GetUnusedReturnValues(ObjectALCode, LocalProcedureLbl);
        UnusedReturnValuesFromInternalProcedures := GetUnusedReturnValues(ObjectALCode, InternalProcedureLbl);
        UnusedReturnValuesFromProtectedProcedures := GetUnusedReturnValues(ObjectALCode, ProtectedProcedureLbl);

        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromProcedures, Types::"Return Value", false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromLocalProcedures, Types::"Return Value", false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromInternalProcedures, Types::"Return Value", false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedReturnValuesFromProtectedProcedures, Types::Parameter, false, NeedsUpdate);
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
        Index := CopyObjectALCode.IndexOf(MethodType, StringComparison.OrdinalIgnoreCase);
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

                if MethodBody.IndexOf(ExitLbl, StringComparison.OrdinalIgnoreCase) = -1 then
                    UnusedReturnValues.Add(ReturnValueType);
            end;

            Index := CopyObjectALCode.IndexOf(MethodType, StringComparison.OrdinalIgnoreCase);
        end;

        exit(UnusedReturnValues);
    end;
    // Unused Return Values -> End

    procedure UpdateAllMethodsEvents()
    var
        ObjectDetails: Record "Object Details";
        Object: Text;
        Progress: Dialog;
        UpdateMethodsEventsLbl: Label 'The methods and events are beign updated...\\#1';
        NeedsUpdate: array[4] of Boolean;
    begin
        // ObjectDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', ObjectDetails.ObjectType::Table,
        //                             ObjectDetails.ObjectType::"TableExtension", ObjectDetails.ObjectType::Page,
        //                             ObjectDetails.ObjectType::"PageExtension", ObjectDetails.ObjectType::Codeunit,
        //                             ObjectDetails.ObjectType::Report);
        // ObjectDetails.SetFilter(ObjectNo, '<%1', 2000000000);

        ObjectDetails.SetFilter(ObjectType, '%1', ObjectDetails.ObjectType::Codeunit);
        ObjectDetails.SetFilter(ObjectNo, '>%1&<%2', 20200, 2000000000);


        if ObjectDetails.FindSet() then begin
            Progress.Open(UpdateMethodsEventsLbl, Object);
            repeat
                ObjectDetails.CalcFields(Name);
                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                Progress.Update();
                UpdateMethodsEvents(ObjectDetails, NeedsUpdate, false);
            until ObjectDetails.Next() = 0;
            Progress.Close();
        end;
    end;

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

        CheckAndUpdateObjectDetailsLine(ObjectDetails, GlobalVariables, Types::"Global Variable", true, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, LocalVariables, Types::"Local Variable", true, NeedsUpdate);
    end;

    [Scope('OnPrem')]
    local procedure GetLocalVariables(ObjectALCode: DotNet String; IsUsed: Boolean): List of [Text]
    var
        VariablesFromTriggers: List of [Text];
        VariablesFromFieldTriggers: List of [Text];
        VariablesFromProcedures: List of [Text];
        VariablesFromLocalProcedures: List of [Text];
        VariablesFromInternalProcedures: List of [Text];
        VariablesFromProtectedProcedures: List of [Text];
    begin
        VariablesFromTriggers := GetVariables(ObjectALCode, TriggerLbl, IsUsed);
        VariablesFromFieldTriggers := GetVariables(ObjectALCode, FieldTriggerLbl, IsUsed);
        VariablesFromProcedures := GetVariables(ObjectALCode, ProcedureLbl, IsUsed);
        VariablesFromLocalProcedures := GetVariables(ObjectALCode, LocalProcedureLbl, IsUsed);
        VariablesFromInternalProcedures := GetVariables(ObjectALCode, InternalProcedureLbl, IsUsed);
        VariablesFromProtectedProcedures := GetVariables(ObjectALCode, ProtectedProcedureLbl, IsUsed);

        exit(GetListSum(GetListSum(VariablesFromTriggers, VariablesFromFieldTriggers, VariablesFromProcedures, VariablesFromLocalProcedures, VariablesFromInternalProcedures), VariablesFromProtectedProcedures));
    end;

    [Scope('OnPrem')]
    local procedure GetVariables(ObjectALCode: DotNet String; Type: Text; IsUsed: Boolean): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        MethodVariables: DotNet String;
        MethodBody: DotNet String;
        VariablesList: List of [Text];
        UnusedVariablesList: List of [Text];
        Variable: Text;
        TextToSearch: Text;
        LocalVarLbl: Text;
        LocalBeginLbl: Text;
        LocalEndLbl: Text;
        TextLengthDeletedFromOriginal: Integer;
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
        LocalBeginLbl := GetLocalBeginLbl(TextToSearch);
        LocalEndLbl := GetLocalEndLbl(TextToSearch);
        LocalVarLbl := GetLocalVarLbl(TextToSearch);

        while Index <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(Index + 4);
            RemoveIndex := ObjectALCode.IndexOf(CopyObjectALCode);
            TextLengthDeletedFromOriginal := 0;
            VarIndex := GetIndexOfLabel(CopyObjectALCode, LocalVarLbl, TextLengthDeletedFromOriginal);
            BeginIndex := GetIndexOfLabel(CopyObjectALCode, LocalBeginLbl);

            if not IsUsed then begin
                EndIndex := GetIndexOfLabel(CopyObjectALCode, LocalEndLbl);
                MethodBody := CopyObjectALCode.Substring(BeginIndex, EndIndex - BeginIndex + StrLen(LocalEndLbl));
            end;

            if (VarIndex <> -1) and (VarIndex < BeginIndex) then begin
                MethodVariables := CopyObjectALCode.Substring(VarIndex, BeginIndex - VarIndex);
                RemoveIndex += VarIndex + TextLengthDeletedFromOriginal;
                ObjectALCode := ObjectALCode.Remove(RemoveIndex, StrLen(LocalVarLbl));
                SubstringIndex := MethodVariables.IndexOf(TextToSearch, StringComparison.OrdinalIgnoreCase) + StrLen(TextToSearch);

                while (SubstringIndex <> StrLen(TextToSearch) - 1) do begin
                    MethodVariables := MethodVariables.Substring(SubstringIndex);
                    SubstringIndex := MethodVariables.IndexOf(':');
                    if SubstringIndex = -1 then
                        break;
                    Variable := MethodVariables.Substring(0, SubstringIndex);
                    VariablesList.Add(Variable);
                    MethodVariables := MethodVariables.Substring(MethodVariables.IndexOf(';'));
                    SubstringIndex := MethodVariables.IndexOf(TextToSearch, StringComparison.OrdinalIgnoreCase) + StrLen(TextToSearch);
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

    local procedure GetLocalBeginLbl(TextToSearch: Text): Text
    begin
        if StrLen(TextToSearch) > 8 then
            exit(FieldBeginLbl);
        exit(BeginLbl);
    end;

    local procedure GetLocalEndLbl(TextToSearch: Text): Text
    begin
        if StrLen(TextToSearch) > 8 then
            exit(FieldEndLbl);
        exit(EndLbl);
    end;

    local procedure GetLocalVarLbl(TextToSearch: Text): Text
    begin
        if StrLen(TextToSearch) > 8 then
            exit(FieldVarLbl);
        exit(VarLbl);
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
        if Method.IndexOf(Variable, StringComparison.OrdinalIgnoreCase) <> -1 then begin
            if (Method.IndexOf(Variable + ' ', StringComparison.OrdinalIgnoreCase) <> -1) then
                exit(Method.IndexOf(Variable + ' ', StringComparison.OrdinalIgnoreCase));
            if (Method.IndexOf(Variable + ')', StringComparison.OrdinalIgnoreCase) <> -1) then
                exit(Method.IndexOf(Variable + ')', StringComparison.OrdinalIgnoreCase));
            if (Method.IndexOf(Variable + ';', StringComparison.OrdinalIgnoreCase) <> -1) then
                exit(Method.IndexOf(Variable + ';', StringComparison.OrdinalIgnoreCase));
            if (Method.IndexOf(Variable + '.', StringComparison.OrdinalIgnoreCase) <> -1) then
                exit(Method.IndexOf(Variable + '.', StringComparison.OrdinalIgnoreCase));
            if (Method.IndexOf(Variable + ',', StringComparison.OrdinalIgnoreCase) <> -1) then
                exit(Method.IndexOf(Variable + ',', StringComparison.OrdinalIgnoreCase));
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

    local procedure GetListSum(FirstList: List of [Text]; SecondList: List of [Text]; ThirdList: List of [Text]; FourthList: List of [Text]; FifthList: List of [Text]): List of [Text]
    var
        Element: Text;
    begin
        foreach Element in FirstList do
            SecondList.Add(Element);

        exit(GetListSum(SecondList, ThirdList, FourthList, FifthList));
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
        IndexesForNextGlobalVar: array[3] of Integer;
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
                SubstringIndex := CopyObjectALCode.IndexOf(';') + 1;
                CopyObjectALCode := CopyObjectALCode.Substring(SubstringIndex);
                SetIndexesForNextGlobalVar(CopyObjectALCode, IndexesForNextGlobalVar);
                EndOfGlobalVariables := GetEndOfGlobalVariables(CopyObjectALCode, IndexesForNextGlobalVar);
                SubstringIndex := CopyObjectALCode.IndexOf('        ') + StrLen('        ');
            end;
        end;

        exit(VariablesList);
    end;

    [Scope('OnPrem')]
    local procedure SetIndexesForNextGlobalVar(ObjectALCode: DotNet String;
    var
        IndexesForNextGlobalVar: array[3] of Integer)
    begin
        IndexesForNextGlobalVar[1] := ObjectALCode.IndexOf('        ');
        IndexesForNextGlobalVar[2] := ObjectALCode.IndexOf(':');
        IndexesForNextGlobalVar[3] := ObjectALCode.IndexOf(';');
    end;

    [Scope('OnPrem')]
    local procedure GetEndOfGlobalVariables(ObjectALCode: DotNet String; IndexOfNextPossibleGlobalVariable: array[3] of Integer): Boolean
    var
        CopyObjectALCode: DotNet String;
        TriggerIndex: Integer;
        ProcedureIndex: Integer;
        LocalProcedureIndex: Integer;
        InternalProcedureIndex: Integer;
        ProtectedProcedureIndex: Integer;
    begin
        if not CheckCorrectIndexOfNextPossibleVariable(IndexOfNextPossibleGlobalVariable) then
            exit(true);

        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        TriggerIndex := GetIndexOfLabel(CopyObjectALCode, TriggerLbl);
        ProcedureIndex := GetIndexOfLabel(CopyObjectALCode, ProcedureLbl);
        LocalProcedureIndex := GetIndexOfLabel(CopyObjectALCode, LocalProcedureLbl);
        InternalProcedureIndex := GetIndexOfLabel(CopyObjectALCode, InternalProcedureLbl);
        ProtectedProcedureIndex := GetIndexOfLabel(CopyObjectALCode, ProtectedProcedureLbl);

        if CheckEndGivenIndex(TriggerIndex, IndexOfNextPossibleGlobalVariable) or CheckEndGivenIndex(ProcedureIndex, IndexOfNextPossibleGlobalVariable)
            or CheckEndGivenIndex(LocalProcedureIndex, IndexOfNextPossibleGlobalVariable) or CheckEndGivenIndex(InternalProcedureIndex, IndexOfNextPossibleGlobalVariable)
            or CheckEndGivenIndex(ProtectedProcedureIndex, IndexOfNextPossibleGlobalVariable) then
            exit(true);

        exit(false);
    end;

    local procedure CheckCorrectIndexOfNextPossibleVariable(IndexOfNextPossibleGlobalVariable: array[3] of Integer): Boolean
    begin
        if (IndexOfNextPossibleGlobalVariable[1] < IndexOfNextPossibleGlobalVariable[2]) and
            (IndexOfNextPossibleGlobalVariable[2] < IndexOfNextPossibleGlobalVariable[3]) then
            exit(true);
        exit(false);
    end;

    local procedure CheckEndGivenIndex(GivenIndex: Integer; IndexOfNextPossibleGlobalVariable: array[3] of Integer): Boolean
    var
        Index: Integer;
    begin
        if GivenIndex <> -1 then
            for Index := 1 to 3 do
                if IndexOfNextPossibleGlobalVariable[Index] > GivenIndex then
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

        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedGlobalVariables, Types::"Global Variable", false, NeedsUpdate);
        CheckAndUpdateObjectDetailsLine(ObjectDetails, UnusedLocalVariables, Types::"Local Variable", false, NeedsUpdate);
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

    procedure UpdateAllVariables()
    var
        ObjectDetails: Record "Object Details";
        Progress: Dialog;
        Object: Text;
        UpdateVariablesLbl: Label 'The variables are beign updated...\\#1';
        NeedsUpdate: array[4] of Boolean;
    begin
        ObjectDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5', ObjectDetails.ObjectType::Table,
                                    ObjectDetails.ObjectType::"TableExtension", ObjectDetails.ObjectType::Page,
                                    ObjectDetails.ObjectType::"PageExtension", ObjectDetails.ObjectType::Codeunit);
        ObjectDetails.SetFilter(ObjectNo, '<%1', 2000000000);

        if ObjectDetails.FindSet() then begin
            Progress.Open(UpdateVariablesLbl, Object);
            repeat
                ObjectDetails.CalcFields(Name);
                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                Progress.Update();
                UpdateVariables(ObjectDetails, NeedsUpdate[1]);
                UpdateUnusedVariables(ObjectDetails, NeedsUpdate[2]);
            until ObjectDetails.Next() = 0;
            Progress.Close();
        end;
    end;

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

        if not CheckObjectsObjectDetailsLine(ObjectDetails, ObjectsUsedInCode, Types::"Object (Internal)") then begin
            NeedsUpdate := true;
            UpdateObjectsObjectDetailsLine(ObjectDetails, ObjectsUsedInCode, Types::"Object (Internal)");
        end;
    end;

    [Scope('OnPrem')]
    local procedure GetObjectsUsedInCode(ObjectALCode: DotNet String): List of [Text]
    var
        RecordsUsedInCode: List of [Text];
        PagesUsedInCode: List of [Text];
        CodeunitsUsedInCode: List of [Text];
        ReportsUsedInCode: List of [Text];
        RecordLbl: Label ': Record ';
        PageLbl: Label ': Page ';
        ReportLbl: Label ': Report ';
        CodeunitLbl: Label ': Codeunit ';
    begin
        RecordsUsedInCode := GetObjectTypeUsedIn(ObjectALCode, RecordLbl);
        PagesUsedInCode := GetObjectTypeUsedIn(ObjectALCode, PageLbl);
        ReportsUsedInCode := GetObjectTypeUsedIn(ObjectALCode, ReportLbl);
        CodeunitsUsedInCode := GetObjectTypeUsedIn(ObjectALCode, CodeunitLbl);

        exit(DeleteDuplicates(GetListSum(RecordsUsedInCode, PagesUsedInCode, ReportsUsedInCode, CodeunitsUsedInCode)));
    end;

    [Scope('OnPrem')]
    local procedure GetObjectTypeUsedIn(ObjectALCode: DotNet String; GivenObjectType: Text): List of [Text]
    var
        CopyObjectALCode: DotNet String;
        ObjectsUsedIn: List of [Text];
        Object: Text;
        StartIndex: Integer;
        EndIndex: Integer;
    begin
        CopyObjectALCode := CopyObjectALCode.Copy(ObjectALCode);
        StartIndex := CopyObjectALCode.IndexOf(GivenObjectType, StringComparison.OrdinalIgnoreCase);

        while StartIndex <> -1 do begin
            CopyObjectALCode := CopyObjectALCode.Substring(StartIndex);
            EndIndex := GetEndIndex(CopyObjectALCode);
            Object := CopyObjectALCode.Substring(2, EndIndex - 2);
            Object := GetObjectUsedIn(Object, GivenObjectType);
            if Object <> '' then
                ObjectsUsedIn.Add(Object);
            CopyObjectALCode := CopyObjectALCode.Substring(EndIndex);
            StartIndex := CopyObjectALCode.IndexOf(GivenObjectType, StringComparison.OrdinalIgnoreCase);
        end;

        exit(ObjectsUsedIn);
    end;

    local procedure GetObjectUsedIn(Object: Text; ObjectType: Text): Text
    var
        ObjectDetails: Record "Object Details";
        RecordLbl: Label ': Record ';
        PageLbl: Label ': Page ';
        ReportLbl: Label ': Report ';
        CodeunitLbl: Label ': Codeunit ';
    begin
        case ObjectType of
            RecordLbl:
                begin
                    Object := CopyStr(Object, 8, StrLen(Object) - 6);
                    ObjectDetails.SetRange(ObjectType, ObjectDetails.ObjectType::Table);
                end;
            PageLbl:
                begin
                    Object := CopyStr(Object, 6, StrLen(Object) - 4);
                    ObjectDetails.SetRange(ObjectType, ObjectDetails.ObjectType::Page);
                end;
            ReportLbl:
                begin
                    Object := CopyStr(Object, 8, StrLen(Object) - 6);
                    ObjectDetails.SetRange(ObjectType, ObjectDetails.ObjectType::Report);
                end;
            CodeunitLbl:
                begin
                    Object := CopyStr(Object, 10, StrLen(Object) - 8);
                    ObjectDetails.SetRange(ObjectType, ObjectDetails.ObjectType::Codeunit);
                end;
        end;

        if StrPos(LowerCase(Object), ' temporary') > 0 then
            Object := CopyStr(Object, 1, StrPos(LowerCase(Object), ' temporary') - 1);
        Object := DelChr(Object, '<', '"');
        Object := DelChr(Object, '>', '"');
        ObjectDetails.SetRange(Name, Object);
        if ObjectDetails.FindFirst() then
            exit(Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + GetObjectNameSearchText(ObjectDetails));

    end;

    [Scope('OnPrem')]
    local procedure GetEndIndex(ObjectALCode: DotNet String): Integer
    var
        IndexOfSemiColon: Integer;
        IndexOfCloseParanthesis: Integer;
    begin
        IndexOfSemiColon := ObjectALCode.IndexOf(';');
        IndexOfCloseParanthesis := ObjectALCode.IndexOf(')');

        if IndexOfSemiColon = -1 then
            exit(IndexOfCloseParanthesis);

        if IndexOfCloseParanthesis = -1 then
            exit(IndexOfSemiColon);

        if (IndexOfSemiColon < IndexOfCloseParanthesis) then
            exit(IndexOfSemiColon);

        exit(IndexOfCloseParanthesis);
    end;

    local procedure GetTextToSearch(Type: Text): Text
    begin
        if Type = FieldTriggerLbl then
            exit('                ');
        exit('        ');
    end;
    // No. of Objects Used in -> End


    // Used in No. of Objects -> Start
    procedure UpdateUsedInNoOfObjects(ObjectDetails: Record "Object Details"; var NeedsUpdate: Boolean)
    var
        UsedInNoObjectsList: List of [Text];
    begin
        UsedInNoObjectsList := GetUsedInNoObjectsList(ObjectDetails);

        if not CheckObjectsObjectDetailsLine(ObjectDetails, UsedInNoObjectsList, Types::"Object (External)") then begin
            NeedsUpdate := true;
            UpdateObjectsObjectDetailsLine(ObjectDetails, UsedInNoObjectsList, Types::"Object (External)");
        end;
    end;

    local procedure GetUsedInNoObjectsList(ObjectDetails: Record "Object Details"): List of [Text]
    var
        ObjDetails: Record "Object Details";
        ObjectALCode: DotNet String;
        UsedInNoObjectsList: List of [Text];
        SearchText: Text;
    begin
        SearchText := GetSearchText(ObjectDetails);

        ObjDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', "Object Type"::Table,
                             "Object Type"::"TableExtension", "Object Type"::Page,
                             "Object Type"::"PageExtension", "Object Type"::Codeunit,
                             "Object Type"::Report);
        ObjDetails.SetFilter(ObjectNo, '<%1', 2000000000);
        if ObjDetails.FindSet() then
            repeat
                GetObjectALCode(ObjDetails, ObjectALCode);
                UpdateUsedInNoObjectsList(ObjDetails, UsedInNoObjectsList, ObjectALCode, SearchText);
            until (ObjDetails.Next() = 0);

        exit(UsedInNoObjectsList);
    end;

    [Scope('OnPrem')]
    local procedure UpdateUsedInNoObjectsList(ObjectDetails: Record "Object Details"; var UsedInNoObjectsList: List of [Text]; ObjectALCode: Dotnet String; SearchText: Text)
    begin
        if ObjectALCode.IndexOf(SearchText, StringComparison.OrdinalIgnoreCase) <> -1 then
            UsedInNoObjectsList.Add(Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + GetObjectNameSearchText(ObjectDetails));
    end;

    local procedure CheckObjectsObjectDetailsLine(ObjectDetails: Record "Object Details"; ObjectsList: List of [Text]; Type: Enum Types): Boolean
    var
        ObjectDetailsLine: Record "Object Details Line";
        Object: Text;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);

        if (ObjectDetailsLine.Count() <> ObjectsList.Count()) or (ObjectDetailsLine.Count() = 0) then
            exit(false);

        if (ObjectDetailsLine.Count() = 0) and (ObjectsList.Count() = 0) then
            exit(true);

        foreach Object in ObjectsList do begin
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

    local procedure UpdateObjectsObjectDetailsLine(ObjectDetails: Record "Object Details"; ObjectsList: List of [Text]; Type: Enum Types)
    var
        ObjectDetailsLine: Record "Object Details Line";
        Object: Text;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Type);

        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        foreach Object in ObjectsList do
            InsertObjectsObjectDetailsLine(ObjectDetails, Object, Type, 0);

    end;

    local procedure InsertObjectsObjectDetailsLine(ObjectDetails: Record "Object Details"; Object: Text; Type: Enum Types; NoTimesUsed: Integer)
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
        if NoTimesUsed <> 0 then
            ObjectDetailsLine.NoTimesUsed := NoTimesUsed;
        ObjectDetailsLine.Insert(true);
    end;

    procedure UpdateAllUsedInNoOfObjects(ObjectDetails: Record "Object Details")
    var
        ObjDetails: Record "Object Details";
        ObjectDetailsLine: Record "Object Details Line";
        UsedInNoObjectsList: List of [Text];
        SearchText: Text;
    begin
        SearchText := GetObjectTypeText(ObjectDetails) + ' ' + GetObjectNameSearchText(ObjectDetails);

        ObjectDetailsLine.SetRange(Type, Types::"Object (Internal)");
        ObjectDetailsLine.SetRange(Name, SearchText);
        if ObjectDetailsLine.FindSet() then
            repeat
                if ObjDetails.Get(ObjectDetailsLine.ObjectType, ObjectDetailsLine.ObjectNo) then
                    UsedInNoObjectsList.Add(Format(ObjDetails.ObjectType) + ' ' + Format(ObjDetails.ObjectNo) + ' ' + GetObjectNameSearchText(ObjDetails));
            until ObjectDetailsLine.Next() = 0;

        if not CheckObjectsObjectDetailsLine(ObjectDetails, UsedInNoObjectsList, Types::"Object (External)") then
            UpdateObjectsObjectDetailsLine(ObjectDetails, UsedInNoObjectsList, Types::"Object (External)");
    end;
    // Used in No. of Objects -> End

    // No of Times Used -> Begin
    procedure UpdateNoTimesUsed(ObjectDetails: Record "Object Details")
    var
        ObjectDetailsLine: Record "Object Details Line";
        NoTimesUsed: Integer;
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Types::"Object (Used)");
        if ObjectDetailsLine.FindSet() then
            ObjectDetailsLine.DeleteAll();

        ObjectDetailsLine.SetRange(Type, Types::"Object (External)");
        if ObjectDetailsLine.FindSet() then
            repeat
                NoTimesUsed := GetNoTimesUsedInGivenObject(ObjectDetails, ObjectDetailsLine);
                InsertObjectsObjectDetailsLine(ObjectDetails, ObjectDetailsLine.TypeName, Types::"Object (Used)", NoTimesUsed);
            until ObjectDetailsLine.Next() = 0;
    end;

    local procedure GetNoTimesUsedInGivenObject(ObjectDetails: Record "Object Details"; ObjectDetailsLine: Record "Object Details Line"): Integer
    var
        ObjDetails: Record "Object Details";
        ObjectALCode: DotNet String;
        ObjectNames: List of [Text];
        Object: Text;
        SearchText: Text;
        ObjectType: Text;
        Index: Integer;
        NoTimesUsed: Integer;
    begin
        SearchText := GetSearchText(ObjectDetails);
        ObjectType := CopyStr(ObjectDetailsLine.TypeName, 1, StrPos(ObjectDetailsLine.TypeName, ' ') - 1);
        if ObjDetails.Get(GetObjectTypeEnumFromText(ObjectType), ObjectDetailsLine.ID) then
            GetObjectALCode(ObjDetails, ObjectALCode);

        ObjectNames := GetObjectNames(ObjectALCode, SearchText);
        foreach Object in ObjectNames do begin
            Index := ObjectALCode.IndexOf(Object, StringComparison.OrdinalIgnoreCase);
            while (Index <> -1) do begin
                NoTimesUsed += 1;
                ObjectALCode := ObjectALCode.Remove(Index, StrLen(Object));
                Index := ObjectALCode.IndexOf(Object, StringComparison.OrdinalIgnoreCase);
            end;
        end;

        exit(NoTimesUsed);
    end;

    local procedure GetObjectTypeEnumFromText(TextType: Text): Enum "Object Type"
    var
        TableLbl: Label 'Table';
        PageLbl: Label 'Page';
        CodeunitLbl: Label 'Codeunit';
        ReportLbl: Label 'Report';
    begin
        case TextType of
            TableLbl:
                exit("Object Type"::Table);
            PageLbl:
                exit("Object Type"::Page);
            CodeunitLbl:
                exit("Object Type"::Codeunit);
            ReportLbl:
                exit("Object Type"::Report);
        end;
    end;

    local procedure GetObjectNames(ObjectALCode: DotNet String; SearchText: Text): List of [Text]
    var
        ObjectNames: List of [Text];
        IndexObject: Integer;
        Index: Integer;
    begin
        IndexObject := ObjectALCode.IndexOf(SearchText, StringComparison.OrdinalIgnoreCase);
        while (IndexObject <> -1) do begin
            Index := IndexObject - 2;
            while (ObjectALCode.Substring(Index, 1) <> ' ') do
                Index -= 1;

            ObjectNames.Add(' ' + ObjectALCode.Substring(Index + 1, IndexObject - Index - 1) + '.');
            ObjectNames.Add('(' + ObjectALCode.Substring(Index + 1, IndexObject - Index - 1) + '.');
            ObjectALCode := ObjectALCode.Remove(IndexObject, StrLen(SearchText));
            IndexObject := ObjectALCode.IndexOf(SearchText, StringComparison.OrdinalIgnoreCase);
        end;

        exit(DeleteDuplicates(ObjectNames));
    end;

    procedure GetNoTimesUsed(ObjectDetails: Record "Object Details"): Integer
    var
        NoTimesUsed: Integer;
        ObjectDetailsLine: Record "Object Details Line";
    begin
        ObjectDetailsLine.SetRange(ObjectType, ObjectDetails.ObjectType);
        ObjectDetailsLine.SetRange(ObjectNo, ObjectDetails.ObjectNo);
        ObjectDetailsLine.SetRange(Type, Types::"Object (Used)");
        if ObjectDetailsLine.FindSet() then
            repeat
                NoTimesUsed += ObjectDetailsLine.NoTimesUsed;
            until ObjectDetailsLine.Next() = 0;

        exit(NoTimesUsed);
    end;
    // No of Times Used -> End

    procedure UpdateAllRelationsInternalUsageOfObjects()
    var
        ObjectDetails: Record "Object Details";
        Object: Text;
        Progress: Dialog;
        UpdateRelationsLbl: Label 'The relations are beign updated...\\#1';
        NeedsUpdate: array[4] of Boolean;
    begin
        ObjectDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', ObjectDetails.ObjectType::Table,
                                    ObjectDetails.ObjectType::"TableExtension", ObjectDetails.ObjectType::Page,
                                    ObjectDetails.ObjectType::"PageExtension", ObjectDetails.ObjectType::Codeunit,
                                    ObjectDetails.ObjectType::Report);
        ObjectDetails.SetFilter(ObjectNo, '<%1', 2000000000);

        if ObjectDetails.FindSet() then begin
            Progress.Open(UpdateRelationsLbl, Object);
            repeat
                ObjectDetails.CalcFields(Name);
                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                Progress.Update();

                if ObjectDetails.ObjectType = ObjectDetails.ObjectType::Table then begin
                    UpdateRelations(ObjectDetails, NeedsUpdate[1], Types::"Relation (External)");
                    UpdateRelations(ObjectDetails, NeedsUpdate[2], Types::"Relation (Internal)");
                end;
                UpdateNoOfObjectsUsedIn(ObjectDetails, NeedsUpdate[3]);
            until ObjectDetails.Next() = 0;
            Progress.Close();
        end;
    end;

    procedure UpdateAllExternalUsageOfObject()
    var
        ObjectDetails: Record "Object Details";
        Progress: Dialog;
        Object: Text;
        UpdateRelationsLbl: Label 'The usage of objects is being updated...\\#1';
        UsageSuccessfullyUpdatedLbl: Label 'The usage of all objects is successfully updated.';
    begin
        ObjectDetails.SetFilter(ObjectType, '%1|%2|%3|%4|%5|%6', ObjectDetails.ObjectType::Table,
                                    ObjectDetails.ObjectType::"TableExtension", ObjectDetails.ObjectType::Page,
                                    ObjectDetails.ObjectType::"PageExtension", ObjectDetails.ObjectType::Codeunit,
                                    ObjectDetails.ObjectType::Report);
        ObjectDetails.SetFilter(ObjectNo, '<%1', 2000000000);

        if ObjectDetails.FindSet() then begin
            Progress.Open(UpdateRelationsLbl, Object);
            repeat
                ObjectDetails.CalcFields(Name);
                Object := Format(ObjectDetails.ObjectType) + ' ' + Format(ObjectDetails.ObjectNo) + ' ' + ObjectDetails.Name;
                Progress.Update();
                UpdateAllUsedInNoOfObjects(ObjectDetails);
                UpdateNoTimesUsed(ObjectDetails);
            until ObjectDetails.Next() = 0;
            Progress.Close();
            Message(UsageSuccessfullyUpdatedLbl);
        end;
    end;

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
