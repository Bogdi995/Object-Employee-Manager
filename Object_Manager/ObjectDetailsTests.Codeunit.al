codeunit 50145 MyCodeunit
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('FirstMessageHandler')]
    procedure FirstTest()
    begin
        Message('It works');
    end;

    [MessageHandler]
    procedure FirstMessageHandler(Message: Text[1024])
    begin
    end;
}