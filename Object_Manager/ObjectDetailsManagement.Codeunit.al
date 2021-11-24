codeunit 50100 "Object Details Management"
{
    trigger OnRun()
    begin

    end;

    procedure CheckIfUpdateNeeded(): Boolean
    var
        AllObj: Record "AllObj";
        ObjectDetails: Record "Object Details";
        ConfirmUpdate: Label '"Object Details" is not updated. Do you want to update it?';
    begin
        if AllObj.Count <> ObjectDetails.Count then begin
            if Confirm(ConfirmUpdate, true) then
                exit(true);
        end;
        exit(false);
    end;

    procedure UpdateObjectDetails()
    var
        AllObj: Record "AllObj";
        ObjectDetails: Record "Object Details";
    begin
        if AllObj.FindFirst() then
            repeat
                if not ObjectDetails.Get(AllObj."Object Type", AllObj."Object ID") then begin
                    ObjectDetails.Init();
                    ObjectDetails.Validate(ObjectType, AllObj."Object Type");
                    ObjectDetails.Validate(ObjectNo, AllObj."Object ID");
                    ObjectDetails.Insert();
                end;
            until AllObj.Next = 0;
    end;

}