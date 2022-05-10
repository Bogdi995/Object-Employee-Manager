report 50101 "Object Statistics Top 10"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ObjectStatisticsTop10.rdlc';

    Extensible = true;
    Caption = 'Object Statistics Top 10';
    PreviewMode = PrintLayout;
    EnableHyperlinks = true;
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(Header; "Integer")
        {
            DataItemTableView = sorting(Number) order(ascending) where(Number = const(1));

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
        }

        dataitem(ObjectDetailsLine; "Object Details Line")
        {
            DataItemTableView = sorting(EntryNo) order(ascending);

            column(Object_Type; "Object Type")
            {
            }
            column(ObjectNo; ObjectNo)
            {
            }
            column(Type; Type)
            {
            }
            column(ID; ID)
            {
            }
            column(Name; Name)
            {
            }

            trigger OnPreDataItem()
            begin
                ObjectDetailsLine.SetRange(Type, GetEnumTypeFromOptionsType(OptionTypes));
                if not Used then
                    ObjectDetailsLine.SetRange(Used, false);

                FilterTop10Objects(ObjectDetailsLine, OptionTypes, Used);
            end;
        }
    }

    requestpage
    {
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
                }
            }
        }
    }

    labels
    {
        ReportNameLbl = 'Object Statistics Top 10';
    }

    trigger OnPreReport()
    begin
        Filters := GetFilters();
    end;

    var
        OptionTypes: Option " ","Key","Field","Integration Event","Business Event","Global Method","Local Method","Global Variable","Local Variable","Parameter","Return Value","Relations From","Relations To","No. of Objects Used in","Used in No. of Objects","No. of Times Used";
        Filters: Text;
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

    local procedure FilterTop10Objects(var ObjectDetailsLine: Record "Object Details Line"; OptionTypes: Option " ","Key","Field","Integration Event","Business Event","Global Method","Local Method","Global Variable","Local Variable","Parameter","Return Value","Relations From","Relations To","No. of Objects Used in","Used in No. of Objects","No. of Times Used"; Used: Boolean)

    local procedure GetEnumTypeFromOptionsType(OptionTypes: Option " ","Key","Field","Integration Event","Business Event","Global Method","Local Method","Global Variable","Local Variable","Parameter","Return Value","Relations From","Relations To","No. of Objects Used in","Used in No. of Objects","No. of Times Used"): Enum Types
    begin
        case OptionTypes of
            OptionTypes::"Key":
                exit(Types::"Key");
            OptionTypes::Field:
                exit(Types::Field);
            OptionTypes::"Integration Event":
                exit(Types::"Integration Event");
            OptionTypes::"Business Event":
                exit(Types::"Business Event");
            OptionTypes::"Global Method":
                exit(Types::"Global Method");
            OptionTypes::"Local Method":
                exit(Types::"Local Method");
            OptionTypes::Parameter:
                exit(Types::Parameter);
            OptionTypes::"Return Value":
                exit(Types::"Return Value");
            OptionTypes::"Global Variable":
                exit(Types::"Global Variable");
            OptionTypes::"Local Variable":
                exit(Types::"Local Variable");
            OptionTypes::"Relations From":
                exit(Types::"Relation (Internal)");
            OptionTypes::"Relations To":
                exit(Types::"Relation (External)");
            OptionTypes::"No. of Objects Used in":
                exit(Types::"Object (Internal)");
            OptionTypes::"Used in No. of Objects":
                exit(Types::"Object (External)");
            OptionTypes::"No. of Times Used":
                exit(Types::"Object (Used)");
        end;
    end;
}