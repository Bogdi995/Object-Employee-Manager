codeunit 50101 "Object Details Install"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        ObjectDetails: Record "Object Details";
    begin
        if ObjectDetails.IsEmpty() then
            InitializeObjects();
    end;

    procedure InitializeObjects()
    begin
        InitializeTables();
        InitializeTableExtensions();
        InitializePages();
        InitializePageExtensions();
        InitializeReports();
        InitializeCodeunits();
        InitializeEnums();
        InitializeEnumExtensions();
        InitializeXMLPorts();
        InitializeQueries();
        InitializeMenuSuites();
    end;

    procedure InitializeTables()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        InsertInObjectDetails(AllObj, "Object Type"::Table);
    end;

    procedure InitializeTableExtensions()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::"TableExtension");
        InsertInObjectDetails(AllObj, "Object Type"::"TableExtension");
    end;

    procedure InitializePages()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Page);
        InsertInObjectDetails(AllObj, "Object Type"::Page);
    end;

    procedure InitializePageExtensions()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::"PageExtension");
        InsertInObjectDetails(AllObj, "Object Type"::"PageExtension");
    end;

    procedure InitializeReports()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Report);
        InsertInObjectDetails(AllObj, "Object Type"::Report);
    end;

    procedure InitializeCodeunits()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
        InsertInObjectDetails(AllObj, "Object Type"::Codeunit);
    end;

    procedure InitializeEnums()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Enum);
        InsertInObjectDetails(AllObj, "Object Type"::Enum);
    end;

    procedure InitializeEnumExtensions()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::EnumExtension);
        InsertInObjectDetails(AllObj, "Object Type"::EnumExtension);
    end;

    procedure InitializeXMLPorts()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::XMLport);
        InsertInObjectDetails(AllObj, "Object Type"::XMLPort);
    end;

    procedure InitializeQueries()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::Query);
        InsertInObjectDetails(AllObj, "Object Type"::Query);
    end;

    procedure InitializeMenuSuites()
    var
        AllObj: Record AllObj;
    begin
        AllObj.SetRange("Object Type", AllObj."Object Type"::MenuSuite);
        InsertInObjectDetails(AllObj, "Object Type"::MenuSuite);
    end;

    procedure InsertInObjectDetails(var AllObj: Record AllObj; ObjectTypes: Enum "Object Type")
    var
        ObjectDetails: Record "Object Details";
    begin
        if AllObj.FindFirst() then
            repeat
                ObjectDetails.Init();
                ObjectDetails.Validate(ObjectType, ObjectTypes);
                ObjectDetails.Validate(ObjectNo, AllObj."Object ID");
                ObjectDetails.Insert(true);
            until AllObj.Next() = 0;
    end;

}