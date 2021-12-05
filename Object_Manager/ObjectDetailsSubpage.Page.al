page 50103 "Object Details Subpage"
{

    Caption = 'Object Details Subpage';
    PageType = ListPart;
    SourceTable = "Object Details Line";
    SourceTableView = sorting(Type, ID) order(ascending) where(Type = filter("Trigger" | "Key" | "Field"));

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                }
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field.';
                    ApplicationArea = All;
                }
                field(Name; GetName())
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = All;
                }
                field(Caption; GetCaption())
                {
                    ToolTip = 'Specifies the value of the Caption field.';
                    ApplicationArea = All;
                }
                field(TypeName; GetTypeName())
                {
                    ToolTip = 'Specifies the value of the Type Name field.';
                    ApplicationArea = All;
                }
            }
        }
    }

    local procedure GetName(): Text[250]
    var
        Field: Record Field;
        Keys: Record "Key";
    begin
        if (Rec.ObjectType = "Object Type"::Table) and (Rec.Type = Types::Field) then
            if Field.Get(Rec.ObjectNo, Rec.ID) then
                exit(Field.FieldName);

        if (Rec.ObjectType = "Object Type"::Table) and (Rec.Type = Types::"Key") then
            if Keys.Get(Rec.ObjectNo, Rec.ID) then
                exit(Keys."Key");

        exit(Rec.Name);
    end;

    local procedure GetCaption(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec.ObjectType <> "Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.Caption);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field."Field Caption");
    end;

    local procedure GetTypeName(): Text[250]
    var
        Field: Record Field;
    begin
        if (Rec.ObjectType <> "Object Type"::Table) or (Rec.Type <> Types::Field) then
            exit(Rec.TypeName);
        if Field.Get(Rec.ObjectNo, Rec.ID) then
            exit(Field."Type Name");
    end;

}
