table 50100 "Object Details"
{
    DataClassification = ToBeClassified;
    CaptionML = DEU = 'Objektdetails', ENU = 'Object Details';

    fields
    {
        field(1; ObjectType; Option)
        {
            CaptionML = DEU = 'Objektart', ENU = 'Object Type';
            OptionMembers = "Table","Page","Report","Codeunit";
        }
        field(2; ObjectNo; Integer)
        {
            CaptionML = DEU = 'Objektnr.', ENU = 'Object No.';
        }
        field(10; Name; Text[250])
        {
            CaptionML = DEU = 'Name', ENU = 'Name';
        }
        field(20; Caption; Text[250])
        {
            CaptionML = DEU = 'Beschriftung', ENU = 'Caption';
        }
        field(30; LastDateModified; Date)
        {
            CaptionML = DEU = 'Letztes Änderungsdatum', ENU = 'Last Date Modified';
        }
        field(40; LastTimeModified; Time)
        {
            CaptionML = DEU = 'Letztes Mal geändert', ENU = 'Last Time Modified';
        }
        field(50; NoTimesUsed; Integer)
        {
            CaptionML = DEU = 'Anzahl der Verwendungen', ENU = 'No. of Times Used';
        }
        field(60; NoPrimaryKeys; Integer)
        {
            CaptionML = DEU = 'Anzahl der Primärschlüssel', ENU = 'No. of Primary Keys';
        }
        field(70; NoKeys; Integer)
        {
            CaptionML = DEU = 'Anzahl der Schlüssel', ENU = 'No. of Keys';
        }
        field(80; NoFields; Integer)
        {
            CaptionML = DEU = 'Anzal der Felder', ENU = 'No. of fields';
        }
        field(90; NoGlobalFunctions; Integer)
        {
            CaptionML = DEU = 'Anzahl der globalen Funktionen', ENU = 'No. of Global Functions';
        }
        field(100; NoUnusedGlobalFunctions; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten globalen Funktionen', ENU = 'No. of Unused Global Functions';
        }
        field(110; NoLocalFuntions; Integer)
        {
            CaptionML = DEU = 'Anzahl der lokalen Funktionen', ENU = 'No. of Local Functions';
        }
        field(120; NoUnusedLocalFunctions; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten lokalen Funktionen', ENU = 'No. of Unused Local Functions';
        }
        field(130; NoTotalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der Gesamtvariablen', ENU = 'No. of Total Variables';
        }
        field(140; NoUnusedTotalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten Gesamtvariablen', ENU = 'No. of Unused Total Variables';
        }
        field(150; NoGlobalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der globalen Variablen', ENU = 'No. of Global Variables';
        }
        field(160; NoUnusedGlobalVariables; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten globalen Variablen', ENU = 'No. of Unused Global Variables';
        }
        field(170; NoUnusedParameters; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten Parameter', ENU = 'No. of Unused Parameters';
        }
        field(180; NoUnusedReturnValues; Integer)
        {
            CaptionML = DEU = 'Anzahl der nicht verwendeten Rückgabewerte', ENU = 'No. of Unused Return Values';
        }

    }

    keys
    {
        key(PK; ObjectType, ObjectNo)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}