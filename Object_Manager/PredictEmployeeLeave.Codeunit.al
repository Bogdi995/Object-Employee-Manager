codeunit 50107 "Predict Employee Leave"
{
    procedure PredictBatch()
    var
        Employee: Record Employee;
        Progress: Dialog;
        PredictLbl: Label 'Predicting if the employees will leave...';
    begin
        if Employee.FindSet() then begin
            Progress.Open(PredictLbl);
            repeat
                Predict(Employee);
            until Employee.Next() = 0;
            Progress.Close();
        end;
    end;

    procedure Predict(Employee: Record Employee)
    var
        MLPredictionManagement: Codeunit "ML Prediction Management";
        EmployeeLeaveSetup: Record "Employee Leave Setup";
        EmployeeLeaveHistory: Record "Employee Leave History" temporary;
    begin
        EmployeeLeaveSetup.Get();
        EmployeeLeaveSetup.TestField(Model);

        MLPredictionManagement.Initialize(EmployeeLeaveSetup.EndpointURI, EmployeeLeaveSetup.APIKey, 0);
        PrepareData(Employee, EmployeeLeaveHistory);
        MLPredictionManagement.SetRecord(EmployeeLeaveHistory);

        AddFeatures(MLPredictionManagement, EmployeeLeaveHistory);
        MLPredictionManagement.SetLabel(EmployeeLeaveHistory.FieldNo(left));
        MLPredictionManagement.SetConfidence(EmployeeLeaveHistory.FieldNo(Accuracy));
        MLPredictionManagement.Predict(EmployeeLeaveSetup.GetEmployeeLeaveModel());
        SavePredictionResult(EmployeeLeaveHistory, Employee);
    end;

    local procedure AddFeatures(var MLPredictionManagement: Codeunit "ML Prediction Management"; EmployeeLeaveHistory: Record "Employee Leave History")
    begin
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(AverageMonthlyHours));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(LastEvaluation));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(NumberProject));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(PromotionLast5years));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(Salary));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(Sales));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(SatisfactionLevel));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(TimeSpendCompany));
        MLPredictionManagement.AddFeature(EmployeeLeaveHistory.FieldNo(WorkAccident));
    end;

    local procedure PrepareData(Employee: Record Employee; var TempEmployeeleaveHistory: Record "Employee Leave History" temporary)
    var
        EmployeeLeaveHistory: Record "Employee Leave History";
        SecretaryLbl: Label 'Secretary';
        DesignerLbl: Label 'Designer';
        SalesManagerLbl: Label 'Sales Manager';
        ProductionAssistantLbl: Label 'Production Assistant';
        ManagingDirectorLbl: Label 'Managing Director';
        AccountingLbl: Label 'accounting';
        MarketingLbl: Label 'marketing';
        SalesLbl: Label 'sales';
        ProductMngLbl: Label 'product_mng';
        ManagementLbl: Label 'management';
    begin
        case Employee."Job Title" of
            SecretaryLbl:
                EmployeeLeaveHistory.Setrange(Sales, AccountingLbl);
            DesignerLbl:
                EmployeeLeaveHistory.Setrange(Sales, MarketingLbl);
            SalesManagerLbl:
                EmployeeLeaveHistory.Setrange(Sales, SalesLbl);
            ProductionAssistantLbl:
                EmployeeLeaveHistory.Setrange(Sales, ProductMngLbl);
            ManagingDirectorLbl:
                EmployeeLeaveHistory.Setrange(Sales, ManagementLbl);
        end;

        if EmployeeLeaveHistory.FindLast() then;
        InsertTempEmployeeLeaveHistory(EmployeeLeaveHistory, TempEmployeeleaveHistory, Employee);
    end;

    local procedure InsertTempEmployeeLeaveHistory(var EmployeeLeaveHistory: Record "Employee Leave History"; var TempEmployeeLeaveHistory: Record "Employee Leave History" temporary; Employee: Record Employee)
    begin
        TempEmployeeLeaveHistory.Init();
        TempEmployeeLeaveHistory.LineNo := 0;
        TempEmployeeLeaveHistory.SatisfactionLevel := Random(100) / 100;
        TempEmployeeLeaveHistory.LastEvaluation := Random(100) / 100;
        TempEmployeeLeaveHistory.NumberProject := Random(10);
        TempEmployeeLeaveHistory.AverageMonthlyHours := 200 + Random(20);
        TempEmployeeLeaveHistory.PromotionLast5years := Random(1);
        TempEmployeeLeaveHistory.WorkAccident := Random(1);
        TempEmployeeLeaveHistory.Sales := EmployeeLeaveHistory.Sales;
        TempEmployeeLeaveHistory.Salary := EmployeeLeaveHistory.Salary;
        TempEmployeeLeaveHistory.TimeSpendCompany := Date2DMY(Today, 3) - Date2DMY(Employee."Employment Date", 3);
        TempEmployeeLeaveHistory.Insert(true);
    end;

    local procedure SavePredictionResult(var EmployeeLeaveHistory: Record "Employee Leave History" temporary; var Employee: Record Employee)
    begin
        if EmployeeLeaveHistory.Find() then;
        Employee.LeavePrediction := GetEmployeeLeavePrediction(EmployeeLeaveHistory);
        Employee."PredictionAccuracy%" := Round(EmployeeLeaveHistory.Accuracy * 100, 1);
        Employee.PredictionAccuracy := GetPredictionAccuracy(EmployeeLeaveHistory.Accuracy);
        Employee.Modify(true);
    end;

    local procedure GetEmployeeLeavePrediction(var EmployeeLeaveHistory: Record "Employee Leave History" temporary): Enum "Leave Prediction"
    begin
        if EmployeeLeaveHistory.Left then
            exit("Leave Prediction"::Leave);

        if EmployeeLeaveHistory.Accuracy >= 0.8 then
            exit("Leave Prediction"::ChanceLeave);

        exit("Leave Prediction"::Stay);
    end;

    local procedure GetPredictionAccuracy(Accuracy: Decimal): Enum "Prediction Accuracy"
    begin
        if (Accuracy >= 0.9) then
            exit("Prediction Accuracy"::High);

        if (Accuracy >= 0.8) then
            exit("Prediction Accuracy"::Medium);

        if (Accuracy = 0) then
            exit("Prediction Accuracy"::" ");

        exit("Prediction Accuracy"::Low);
    end;
}