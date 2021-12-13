page 50144 "Blob View Page"
{
    Editable = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            field(MyText; MyText)
            {
                MultiLine = true;
            }
        }
    }

    var
        MyText: Text;

    [Scope('OnPrem')]
    procedure SetText(pMytext: Text)
    begin
        MyText := pMytext;
    end;

    [Scope('OnPrem')]
    procedure GetText(): Text
    begin
        exit(MyText);
    end;
}

