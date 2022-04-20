table 50106 "Employee Leave Setup"
{
    Caption = 'Employee Leave Setup';
    DataClassification = CustomerContent;

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

    procedure GetEndpointURI(): Text
    begin
        exit('https://ussouthcentral.services.azureml.net/workspaces/820c7d417fb24e968b51e2f5c3d91e75/services/3adcd177fb384c2091ccf49f31dbbe0d/execute?api-version=2.0&details=true');
    end;

    procedure GetAPIKey(): Text
    begin
        exit('NreopaOqYw3WSJd6twUV4gP4FftpraAbUW0aUrOw/4b5zKeLelZlvgTJHFs+XpEFb0+be3UicRkCB5YYXnCACw==');
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