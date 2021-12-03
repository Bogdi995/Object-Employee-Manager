codeunit 50102 "Object Details Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Module: ModuleInfo;
        ObjectDetailsManagement: Codeunit "Object Details Management";
    begin
        NavApp.GetCurrentModuleInfo(Module);
        if Module.DataVersion.Major = 1 then begin
            if ObjectDetailsManagement.CheckIfUpdateNeeded() then
                ObjectDetailsManagement.UpdateObjectDetails();
        end;
    end;

}