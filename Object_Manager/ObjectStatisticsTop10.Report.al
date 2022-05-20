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
                FRef := ObjectDetailsRef.Field(GetFieldNoFromOptionsType(OptionTypes));
                FRef.CalcField();
                Evaluate(FieldCount, Format(FRef));

                if FieldCount = 0 then
                    CurrReport.Skip();

                ObjectDetailsAmount.Init();
                ObjectDetailsAmount."Object Type" := "Object Type";
                ObjectDetailsAmount.ObjectNo := ObjectNo;
                ObjectDetailsAmount.FieldCount := FieldCount;
                ObjectDetailsAmount.Insert();

                if (NoOfRecordsToPrint = 0) or (Index < NoOfRecordsToPrint) then
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
            column(ChartType; ChartType)
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
                    FRef := ObjectDetailsRef.Field(GetFieldNoFromOptionsType(OptionTypes));
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
                        Caption = 'Options Types';
                        ApplicationArea = All;

                        trigger OnValidate()
                        var
                            ErrorNotEmptyLbl: Label 'Options Type cannot be empty!';
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
    }

    trigger OnPreReport()
    begin
        Filters := GetFilters();
    end;

    var
        ObjectDetailsAmount: Record "Object Details Amount" temporary;
        OptionTypes: Option " ","Key","Field","Integration Event","Business Event","Global Method","Local Method","Global Variable","Total Variable","Parameter","Return Value","Relations From","Relations To","No. of Objects Used in","Used in No. of Objects","No. of Times Used";
        ChartType: Option "Column chart","Line chart","Pie chart","Bar chart","Area chart","Range chart","Scatter chart","Polar chart";
        Filters: Text;
        Progress: Dialog;
        SortingObjectsTxt: Label 'Sorting the objects...#1';
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
    begin
        Filters += OptionsLbl;
        Filters += TypeLbl + Format(OptionTypes) + ', ';
        Filters += UsedLbl + Format(Used);

        exit(Filters);
    end;

    local procedure GetFieldNoFromOptionsType(OptionTypes: Option " ","Key","Field","Integration Event","Business Event","Global Method","Local Method","Global Variable","Total Variable","Parameter","Return Value","Relations From","Relations To","No. of Objects Used in","Used in No. of Objects","No. of Times Used"): Integer
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
}