codeunit 50102 "Object Details Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Module: ModuleInfo;
        ObjectDetailsManagement: Codeunit "Object Details Management";
        NeedsUpdate: Boolean;
    begin
        NavApp.GetCurrentModuleInfo(Module);
        if Module.DataVersion.Major = 1 then begin
            if ObjectDetailsManagement.CheckUpdateObjectDetails() then
                ObjectDetailsManagement.UpdateObjectDetails();

            ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Types::Field, NeedsUpdate);
            ObjectDetailsManagement.UpdateTypeObjectDetailsLine(Types::"Key", NeedsUpdate);
        end;
    end;

}