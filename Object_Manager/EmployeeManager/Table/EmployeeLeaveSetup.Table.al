table 50106 "Employee Leave Setup"
{
    Caption = 'Employee Leave Setup';
    DataClassification = CustomerContent;
    LookupPageId = "Object Details List";
    DrillDownPageId = "Object Details List";

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; Model; Blob)
        {
            Caption = 'Model';
            DataClassification = CustomerContent;
        }
        field(20; ModelQuality; Decimal)
        {
            Caption = 'Model Quality';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
            MaxValue = 1;
        }
        field(30; Features; Text[1024])
        {
            Caption = 'Features';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; Label; Text[250])
        {
            Caption = 'Label';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; APIKey; Text[512])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(60; EndpointURI; Text[1024])
        {
            Caption = 'Endpoint URI';
            DataClassification = CustomerContent;
        }
        field(70; DatasetLink; Text[2048])
        {
            Caption = 'Dataset Link';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }

    procedure InsertIfNotExists()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;

    procedure SetEmployeeLeaveModel(ModelAsText: Text)
    var
        OStream: OutStream;
    begin
        Model.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.Write(ModelAsText);
    end;

    procedure GetEmployeeLeaveModel() Content: Text
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
    begin
        TempBlob.FromRecord(Rec, FieldNo(Model));
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        IStream.Read(Content);
    end;
}