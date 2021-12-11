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
                    begin
                        Rec.CalcFields(Metadata);
                        if Rec.Metadata.HasValue() then begin
                            Rec.Metadata.CreateInStream(InStr);
                            "ProcessBlob&View"(Rec.FieldNo(Metadata));
                        end else
                            error('Metadata is not available for this object');
                    end;
                }
                field("User Code"; Rec."User Code")
                {
                    trigger OnDrillDown()
                    begin
                        Rec.CalcFields("User Code");
                        if Rec."User Code".HasValue() then begin
                            Rec."User Code".CreateInStream(InStr);
                            "ProcessBlob&View"(Rec.FieldNo("User Code"));
                        end else
                            error('User Code is not available for this object');
                    end;
                }
                field("User AL Code"; Rec."User AL Code")
                {

                    trigger OnDrillDown()
                    begin
                        Rec.CalcFields("User AL Code");
                        IF Rec."User AL Code".HasValue() then begin
                            Rec."User AL Code".CreateInStream(InStr);
                            "ProcessBlob&View"(Rec.FieldNo("User AL Code"));
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

    trigger OnOpenPage()
    begin
        Rec.SetFilter("Object ID", '50000..50149');
    end;

    var
        InStr: InStream;
        Encoding: DotNet Encoding;
        BlobViewPage: Page "Blob View Page";
        StreamReader: DotNet StreamReader;
        RecRef: RecordRef;

    [Scope('OnPrem')]
    local procedure "ProcessBlob&View"(EventFieldArgs: Integer)
    var
        PageTittleL: Text;
    begin
        StreamReader := StreamReader.StreamReader(InStr, Encoding.UTF8);
        Clear(BlobViewPage);
        BlobViewPage.SetText(StreamReader.ReadToEnd);
        PageTittleL := Format(Rec."Object Type") + ' ' + Format(Rec."Object ID");
        case EventFieldArgs of
            Rec.FieldNo(Metadata):
                PageTittleL += ' - ' + Rec.FieldName(Metadata) + '.xml';
            Rec.FieldNo("User Code"):
                PageTittleL += ' - ' + Rec.FieldName("User Code") + '.cs';
            Rec.FieldNo("User AL Code"):
                PageTittleL += ' - ' + Rec.FieldName("User AL Code") + '.txt';
        end;
        BlobViewPage.Caption(PageTittleL);
        BlobViewPage.RunModal();
    end;
}

