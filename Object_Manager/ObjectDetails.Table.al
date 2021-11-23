table 50100 "Object Details"
{
    DataClassification = ToBeClassified;
    CaptionML = DEU = 'Objektdetails', ENU = 'Object Details';

    fields
    {
        field(1; ObjectType; Option)
        {
            CaptionML = DEU = 'Objekttyp', ENU = 'Object Type';
            OptionMembers = "TableData","Table",,"Report",,"Codeunit","XMLport","MenuSuite","Page","Query","System","FieldNumber",,,"PageExtension","TableExtension","Enum","EnumExtension","Profile","ProfileExtension";
            OptionCaptionML = DEU = 'TableData,Tabelle,,Bericht,,Codeunit,XMLport,MenuSuite,Seite,Abfrage,System,FieldNumber,,,PageExtension,TableExtension,Enum,EnumExtension,Profile,ProfileExtension',
                              ENU = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query,System,FieldNumber,,,PageExtension,TableExtension,Enum,EnumExtension,Profile,ProfileExtension';
            DataClassification = CustomerContent;
        }
        field(2; ObjectNo; Integer)
        {
            CaptionML = DEU = 'Objektnr.', ENU = 'Object No.';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" where("Object Type" = field(ObjectType));
        }
        field(10; Name; Text[30])
        {
            CaptionML = DEU = 'Name', ENU = 'Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = field(ObjectType), "Object ID" = field(ObjectNo)));
        }
        field(20; Caption; Text[250])
        {
            CaptionML = DEU = 'Beschriftung', ENU = 'Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = field(ObjectType), "Object ID" = field(ObjectNo)));
        }
        field(25; ObjectSubtype; Text[30])
        {
            CaptionML = DEU = 'Objektuntertyp', ENU = 'Object Subtype';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Subtype" where("Object Type" = field(ObjectType), "Object ID" = field(ObjectNo)));
        }
        field(30; LastDateModified; Date)
        {
            CaptionML = DEU = 'Letztes Änderungsdatum', ENU = 'Last Date Modified';
            DataClassification = CustomerContent;
        }
        field(40; LastTimeModified; Time)
        {
            CaptionML = DEU = 'Letztes Mal geändert', ENU = 'Last Time Modified';
            DataClassification = CustomerContent;
        }
        field(50; NoTimesUsed; Integer)
        {
            CaptionML = DEU = 'Anzahl der Verwendungen', ENU = 'No. of Times Used';
            DataClassification = CustomerContent;
        }
        field(60; NoPrimaryKeys; Integer)
        {
            CaptionML = DEU = 'Anzahl der Primärschlüssel', ENU = 'No. of Primary Keys';
            DataClassification = CustomerContent;
        }
        field(70; NoKeys; Integer)
        {
            CaptionML = DEU = 'Anzahl der Schlüssel', ENU = 'No. of Keys';
            DataClassification = CustomerContent;
        }
        field(80; NoFields; Integer)
        {
            CaptionML = DEU = 'Anzal der Felder', ENU = 'No. of fields';
            DataClassification = CustomerContent;
        }
        field(90; NoGlobalFunctions; Integer)
        {
            CaptionML = DEU = 'Anzahl der globalen Funktionen', ENU = 'No. of Global Functions';
            DataClassification = CustomerContent;
        }
        field(100; NoUnusedGlobalFunctions; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten globalen Funktionen', ENU = 'No. of Unused Global Functions';
            DataClassification = CustomerContent;
        }
        field(110; NoLocalFuntions; Integer)
        {
            CaptionML = DEU = 'Anzahl der lokalen Funktionen', ENU = 'No. of Local Functions';
            DataClassification = CustomerContent;
        }
        field(120; NoUnusedLocalFunctions; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten lokalen Funktionen', ENU = 'No. of Unused Local Functions';
            DataClassification = CustomerContent;
        }
        field(130; NoTotalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der Gesamtvariablen', ENU = 'No. of Total Variables';
            DataClassification = CustomerContent;
        }
        field(140; NoUnusedTotalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten Gesamtvariablen', ENU = 'No. of Unused Total Variables';
            DataClassification = CustomerContent;
        }
        field(150; NoGlobalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der globalen Variablen', ENU = 'No. of Global Variables';
            DataClassification = CustomerContent;
        }
        field(160; NoUnusedGlobalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten globalen Variablen', ENU = 'No. of Unused Global Variables';
            DataClassification = CustomerContent;
        }
        field(170; NoUnusedParameters; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten Parameter', ENU = 'No. of Unused Parameters';
            DataClassification = CustomerContent;
        }
        field(180; NoUnusedReturnValues; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten Rückgabewerte', ENU = 'No. of Unused Return Values';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; ObjectType, ObjectNo)
        {
            Clustered = true;
        }
    }
}