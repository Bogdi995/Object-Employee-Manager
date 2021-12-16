page 50145 "Object Metadata Page"
{
    PageType = List;
    SourceTable = "Application Object Metadata";
    Caption = 'Object Details Line List';
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
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
                            ShowBlob(Instr);
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
                            ShowBlob(InStr);
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
                            ShowBlob(InStr);
                        end else
                            error('User AL Code is not available for this object');
                    end;
                }
            }
        }
    }

    [Scope('OnPrem')]
    local procedure ShowBlob(InStr: InStream)
    var
        Encoding: DotNet Encoding;
        StreamReader: DotNet StreamReader;
    begin
        Message(StreamReader.StreamReader(InStr, Encoding.UTF8).ReadToEnd());
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

