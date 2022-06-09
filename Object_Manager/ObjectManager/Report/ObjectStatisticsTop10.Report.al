report 50101 "Object Statistics Top 10"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ObjectStatisticsTop10.rdlc';

    Caption = 'Object Statistics Top 10';
    PreviewMode = PrintLayout;
    EnableHyperlinks = true;
    Extensible = true;
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(ObjectDetails; "Object Details")
        {
            DataItemTableView = sorting("Object Type", ObjectNo) order(ascending);

            trigger OnPreDataItem()
            begin
                Progress.Open(SortingObjectsTxt, Number);
                Index := 0;
                ObjectDetailsAmount.DeleteAll();
            end;

            trigger OnAfterGetRecord()
            var
                ObjectDetailsRef: RecordRef;
                FRef: FieldRef;
            begin
                Number += 1;
                Progress.Update();
                ObjectDetailsRef.GetTable(ObjectDetails);
                FRef := ObjectDetailsRef.Field(GetFieldNoFromOptionType());
                FRef.CalcField();
                Evaluate(FieldCount, Format(FRef));

                if FieldCount = 0 then
                    CurrReport.Skip();

                ObjectDetailsAmount.Init();
                ObjectDetailsAmount."Object Type" := "Object Type";
                ObjectDetailsAmount.ObjectNo := ObjectNo;
                ObjectDetailsAmount.FieldCount := FieldCount;
                ObjectDetailsAmount.Insert();

                if Index < NoOfRecordsToPrint then
                    Index := Index + 1
                else begin
                    if ObjectDetailsAmount.FindFirst() then
                        ObjectDetailsAmount.Delete();
                end;

                TotalCount += FieldCount;
            end;
        }

        dataitem("Integer"; "Integer")
        {
            DataItemTableView = sorting(Number) order(ascending) where(Number = filter(1 ..));

            column(CurrUserID; Format(UserId))
            {
            }
            column(CurrDay; Format(Today))
            {
            }
            column(ReportID; CopyStr(CurrReport.ObjectId(false), 7))
            {
            }
            column(CompanyName; CompanyName)
            {
            }
            column(Filters; Filters)
            {
            }
            column(ChartTitle; ChartTitle)
            {
            }
            column(ChartType; ChartType)
            {
            }
            column(OptionTypes; OptionTypes)
            {
            }
            column(ObjectType_ObjectDetails; ObjectDetails."Object Type")
            {
            }
            column(ObjectNo_ObjectDetails; ObjectDetails.ObjectNo)
            {
            }
            column(Name_ObjectDetails; ObjectDetails.Name)
            {
            }
            column(FieldCount; FieldCount)
            {
            }
            column(TotalCount; TotalCount)
            {
            }

            trigger OnPreDataItem()
            begin
                Progress.Close;
            end;

            trigger OnAfterGetRecord()
            var
                ObjectDetailsRef: RecordRef;
                FRef: FieldRef;
            begin
                if Number = 1 then begin
                    if not ObjectDetailsAmount.FindFirst() then
                        CurrReport.Break();
                end else
                    if ObjectDetailsAmount.Next() = 0 then
                        CurrReport.Break();

                if ObjectDetails.Get(ObjectDetailsAmount."Object Type", ObjectDetailsAmount.ObjectNo) then begin
                    ObjectDetails.CalcFields(Name);
                    ObjectDetailsRef.GetTable(ObjectDetails);
                    FRef := ObjectDetailsRef.Field(GetFieldNoFromOptionType());
                    FRef.CalcField();
                    Evaluate(FieldCount, Format(FRef));
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(OptionTypes; OptionTypes)
                    {
                        Caption = 'Option Types';
                        ApplicationArea = All;

                        trigger OnValidate()
                        var
                            ErrorNotEmptyLbl: Label 'Option Type cannot be empty!';
                        begin
                            case OptionTypes of
                                OptionTypes::" ":
                                    begin
                                        Error(ErrorNotEmptyLbl);
                                    end;
                                OptionTypes::"Key", OptionTypes::Field, OptionTypes::"Integration Event", OptionTypes::"Business Event", OptionTypes::"Relations From", OptionTypes::"Relations To", OptionTypes::"No. of Objects Used in", OptionTypes::"Used in No. of Objects", OptionTypes::"No. of Times Used":
                                    begin
                                        Used := true;
                                        IsEditable := false;
                                    end;
                                OptionTypes::Parameter, OptionTypes::"Return Value":
                                    begin
                                        Used := false;
                                        IsEditable := false;
                                    end;
                                else begin
                                        IsEditable := true;
                                    end;
                            end
                        end;
                    }
                    field(Used; Used)
                    {
                        Caption = 'Used';
                        Editable = IsEditable;
                        ApplicationArea = All;
                    }
                    field(NoOfRecordsToPrint; NoOfRecordsToPrint)
                    {
                        Caption = 'Number of Objects';
                        ToolTip = 'Specifies the number of objects that will be included in the report.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        var
                            NoOfRecordsToPrintErr: Label 'The value must be a positive number.';
                        begin
                            if NoOfRecordsToPrint <= 0 then
                                Error(NoOfRecordsToPrintErr);
                        end;
                    }
                    field(ChartType; ChartType)
                    {
                        Caption = 'Chart Type';
                        OptionCaption = 'Column chart,Line chart,Pie chart,Bar chart,Area chart,Range chart,Scatter chart,Polar chart';
                        ToolTip = 'Specifies the chart type.';
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if NoOfRecordsToPrint = 0 then
                NoOfRecordsToPrint := 10;
        end;
    }

    labels
    {
        ReportNameLbl = 'Object Statistics Top 10';
        ObjectTypeLbl = 'Object Type';
        ObjectNoLbl = 'Object No.';
        NameLbl = 'Name';
        CountLbl = 'Count';
        TotalLbl = 'Total';
        TotalDatabase = 'Total database';
        TotalDatabasePercent = 'Total database %';
        InternalRelationsLbl = '*relations from other objects';
        ExternalRelationsLbl = '*relations to other objects';
        InternalObjectsLbl = '*most objects used in one object';
        ExternalObjectsLbl = '*objects used in most other objects';
        ObjectsUsedLbl = '*objects most often used in other objects';
        RelationsFromLbl = 'Relations From';
        RelationsToLbl = 'Relations To';
        NoObjectsUsedInLbl = 'No. of Objects Used in';
        UsedInNoObjectsLbl = 'Used in No. of Objects';
        NoTimesUsedLbl = 'No. of Times Used';
    }

    trigger OnPreReport()
    begin
        Filters := GetFilters();
        ChartTitle := StrSubstNo(ChartTitleTxt, NoOfRecordsToPrint, GetTextFromOptionType());
    end;

    var
        ObjectDetailsAmount: Record "Object Details Amount" temporary;
        OptionTypes: Option " ","Key","Field","Integration Event","Business Event","Global Method","Local Method","Global Variable","Total Variable","Parameter","Return Value","Relations From","Relations To","No. of Objects Used in","Used in No. of Objects","No. of Times Used";
        ChartType: Option "Column chart","Line chart","Pie chart","Bar chart","Area chart","Range chart","Scatter chart","Polar chart";
        Filters: Text;
        ChartTitle: Text;
        Progress: Dialog;
        SortingObjectsTxt: Label 'Sorting the objects... #1';
        ChartTitleTxt: Label 'Top %1 objects from database with most %2';
        NoOfRecordsToPrint: Integer;
        TotalCount: Integer;
        FieldCount: Integer;
        Number: Integer;
        Index: Integer;
        Used: Boolean;
        [InDataSet]
        IsEditable: Boolean;

    local procedure GetFilters(): Text
    var
        Filters: Text;
        OptionsLbl: Label 'Options: ';
        TypeLbl: Label 'Type: ';
        UsedLbl: Label 'Used: ';
        NoObjectsLbl: Label 'Number of Objects: ';
        ChartTypeLbl: Label 'Chart Type: ';
    begin
        Filters += OptionsLbl;
        Filters += TypeLbl + Format(OptionTypes) + ', ';
        Filters += UsedLbl + Format(Used) + ', ';
        Filters += NoObjectsLbl + Format(NoOfRecordsToPrint) + ', ';
        Filters += ChartTypeLbl + Format(ChartType);

        exit(Filters);
    end;

    local procedure GetFieldNoFromOptionType(): Integer
    var
        ObjectDetails: Record "Object Details";
    begin
        case OptionTypes of
            OptionTypes::"Key":
                exit(ObjectDetails.FieldNo(NoKeys));
            OptionTypes::Field:
                exit(ObjectDetails.FieldNo(NoFields));
            OptionTypes::"Integration Event":
                exit(ObjectDetails.FieldNo(NoIntegrationEvents));
            OptionTypes::"Business Event":
                exit(ObjectDetails.FieldNo(NoBusinessEvents));
            OptionTypes::"Global Method":
                exit(ObjectDetails.FieldNo(NoGlobalMethods));
            OptionTypes::"Local Method":
                exit(ObjectDetails.FieldNo(NoLocalMethods));
            OptionTypes::Parameter:
                exit(ObjectDetails.FieldNo(NoUnusedParameters));
            OptionTypes::"Return Value":
                exit(ObjectDetails.FieldNo(NoUnusedReturnValues));
            OptionTypes::"Global Variable":
                exit(ObjectDetails.FieldNo(NoGlobalVariables));
            OptionTypes::"Total Variable":
                exit(ObjectDetails.FieldNo(NoTotalVariables));
            OptionTypes::"Relations From":
                exit(ObjectDetails.FieldNo(RelationsFrom));
            OptionTypes::"Relations To":
                exit(ObjectDetails.FieldNo(RelationsTo));
            OptionTypes::"No. of Objects Used in":
                exit(ObjectDetails.FieldNo(NoObjectsUsedIn));
            OptionTypes::"Used in No. of Objects":
                exit(ObjectDetails.FieldNo(UsedInNoObjects));
            OptionTypes::"No. of Times Used":
                exit(ObjectDetails.FieldNo(NoObjectsUsedIn));
        end;
    end;

    local procedure GetTextFromOptionType(): Text
    var
        KeysLbl: Label 'keys';
        FieldsLbl: Label 'fields';
        IntegrationEventsLbl: Label 'integration events';
        BusinessEventsLbl: Label 'business events';
        GlobalMethodsLbl: Label 'global methods';
        UnusedGlobalMethodsLbl: Label 'unused global methods';
        LocalMethodsLbl: Label 'local methods';
        UnusedLocalMethodsLbl: Label 'unused local methods';
        UnusedParametersLbl: Label 'unused parameters';
        UnusedReturnValuesLbl: Label 'unused return values';
        GlobalVariablesLbl: Label 'global variables';
        UnusedGlobalVariablesLbl: Label 'unused global variables';
        TotalVariablesLbl: Label 'variables';
        UnusedTotalVariablesLbl: Label 'unused variables';
        RelationsFromLbl: Label 'external relations*';
        RelationsToLbl: Label 'internal relations*';
        NoObjectsUsedInLbl: Label 'internal objects*';
        UsedInNoObjectsLbl: Label 'external objects*';
        NoTimesUsedLbl: Label 'objects used*';
    begin
        case OptionTypes of
            OptionTypes::"Key":
                exit(KeysLbl);
            OptionTypes::Field:
                exit(FieldsLbl);
            OptionTypes::"Integration Event":
                exit(IntegrationEventsLbl);
            OptionTypes::"Business Event":
                exit(BusinessEventsLbl);
            OptionTypes::"Global Method":
                begin
                    if Used then
                        exit(GlobalMethodsLbl);
                    exit(UnusedGlobalMethodsLbl);
                end;
            OptionTypes::"Local Method":
                begin
                    if Used then
                        exit(LocalMethodsLbl);
                    exit(UnusedLocalMethodsLbl);
                end;
            OptionTypes::Parameter:
                exit(UnusedParametersLbl);
            OptionTypes::"Return Value":
                exit(UnusedReturnValuesLbl);
            OptionTypes::"Global Variable":
                begin
                    if Used then
                        exit(GlobalVariablesLbl);
                    exit(UnusedGlobalVariablesLbl);
                end;
            OptionTypes::"Total Variable":
                begin
                    if Used then
                        exit(TotalVariablesLbl);
                    exit(UnusedTotalVariablesLbl);
                end;
            OptionTypes::"Relations From":
                exit(RelationsFromLbl);
            OptionTypes::"Relations To":
                exit(RelationsToLbl);
            OptionTypes::"No. of Objects Used in":
                exit(NoObjectsUsedInLbl);
            OptionTypes::"Used in No. of Objects":
                exit(UsedInNoObjectsLbl);
            OptionTypes::"No. of Times Used":
                exit(NoTimesUsedLbl);
        end;
    end;
}