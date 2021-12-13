page 50145 "Object Metadata Page"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Application Object Metadata";
    SourceTableView = sorting("Object Type", "Object ID");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {
                }
                field("Object ID"; Rec."Object ID")
                {
                }
                field(Metadata; Rec.Metadata)
                {
                    trigger OnDrillDown()
                    var
                        InStr: InStream;
                    begin
                        Rec.CalcFields(Metadata);
                        if Rec.Metadata.HasValue() then begin
                            Rec.Metadata.CreateInStream(InStr);
                            "ProcessBlob&View"(Rec.FieldNo(Metadata), Instr);
                        end else
                            error('Metadata is not available for this object');
                    end;
                }
                field("User Code"; Rec."User Code")
                {
                    trigger OnDrillDown()
                    var
                        InStr: InStream;
                    begin
                        Rec.CalcFields("User Code");
                        if Rec."User Code".HasValue() then begin
                            Rec."User Code".CreateInStream(InStr);
                            "ProcessBlob&View"(Rec.FieldNo("User Code"), InStr);
                        end else
                            error('User Code is not available for this object');
                    end;
                }
                field("User AL Code"; Rec."User AL Code")
                {
                    trigger OnDrillDown()
                    var
                        InStr: InStream;
                    begin
                        Rec.CalcFields("User AL Code");
                        if Rec."User AL Code".HasValue() then begin
                            Rec."User AL Code".CreateInStream(InStr);
                            "ProcessBlob&View"(Rec.FieldNo("User AL Code"), InStr);
                        end else
                            error('User AL Code is not available for this object');
                    end;
                }
                field("Metadata Version"; Rec."Metadata Version")
                {
                }
                field("Object Subtype"; Rec."Object Subtype")
                {
                }
            }
        }
    }

    [Scope('OnPrem')]
    local procedure "ProcessBlob&View"(FieldNo: Integer; InStr: InStream)
    var
        BlobViewPage: Page "Blob View Page";
        Encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
        PageTitle: Text;
    begin
        StreamReader := StreamReader.StreamReader(InStr, Encoding.UTF8);
        Clear(BlobViewPage);
        BlobViewPage.SetText(StreamReader.ReadToEnd());
        PageTitle := Format(Rec."Object Type") + ' ' + Format(Rec."Object ID");
        case FieldNo of
            Rec.FieldNo(Metadata):
                PageTitle += ' - ' + Rec.FieldName(Metadata) + '.xml';
            Rec.FieldNo("User Code"):
                PageTitle += ' - ' + Rec.FieldName("User Code") + '.cs';
            Rec.FieldNo("User AL Code"):
                PageTitle += ' - ' + Rec.FieldName("User AL Code") + '.txt';
        end;
        BlobViewPage.Caption(PageTitle);
        BlobViewPage.RunModal();
    end;

    procedure GetKeyForObject(ObjectType: Text; ObjectID: Text): Text
    begin
        exit(ObjectType + ObjectID);
    end;

    procedure GetUserALCodeInstream(ObjectType: Option; ObjectID: Integer): InStream
    var
        InStr: InStream;
    begin
        Rec.SetRange("Object Type", ObjectType);
        Rec.SetRange("Object ID", ObjectID);
        if Rec.FindFirst() then begin
            Rec.CalcFields("User AL Code");
            Rec."User AL Code".CreateInStream(InStr);
        end;
        exit(InStr);
    end;
}

