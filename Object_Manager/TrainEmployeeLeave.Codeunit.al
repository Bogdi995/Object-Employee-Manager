codeunit 50106 "Train Employee Leavee"
{
    procedure Train();
    var
        EmployeeLeaveSetup: Record "Employee Leave Setup";
        EmployeeLeaveHistory: Record "Employee Leave History";
        MLPredictionManagement: Codeunit "ML Prediction Management";
        MyModel: Text;
        Progress: Dialog;
        TrainModelLbl: Label 'The model is being trained...';
        ModelTrainedLbl: Label 'The model is trained. The quality is %1%';
        MyModelQuality: Decimal;
    begin
        Progress.Open(TrainModelLbl);
        EmployeeLeaveSetup.Get();
        MLPredictionManagement.Initialize(EmployeeLeaveSetup.EndpointURI, EmployeeLeaveSetup.APIKey, 0);
        MLPredictionManagement.SetRecord(EmployeeLeaveHistory);

        AddFeatures(MLPredictionManagement, EmployeeLeaveHistory);
        MLPredictionManagement.SetLabel(EmployeeLeaveHistory.FieldNo(Left));
        MLPredictionManagement.Train(MyModel, MyModelQuality);

        EmployeeLeaveSetup.InsertIfNotExists();
        EmployeeLeaveSetup.SetEmployeeLeaveModel(MyModel);
        EmployeeLeaveSetup.Validate(ModelQuality, MyModelQuality);
        EmployeeLeaveSetup.Validate(Features, 'average_montly_hours,last_evaluation,number_project,promotion_last_5years,salary,sales,satisfaction_level,time_spend_company,Work_accident');
        EmployeeLeaveSetup.Validate(Label, 'left');
        EmployeeLeaveSetup.Modify(true);
        Progress.Close();

        Message(StrSubstNo(ModelTrainedLbl, Round(MyModelQuality * 100, 1)));
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

    procedure DownloadPlotOfTheModel()
    var
        MLPrediction: Codeunit "ML Prediction Management";
        PlotBase64: Text;
        Setup: Record "Employee Leave Setup";
    begin
        Setup.Get();
        MLPrediction.Initialize(Setup.EndpointURI, Setup.APIKey, 0);
        PlotBase64 := MLPrediction.PlotModel(Setup.GetEmployeeLeaveModel(), Setup.Features, Setup.Label);
        MLPrediction.DownloadPlot(PlotBase64, 'EmployeeLeavePrediction');
    end;
}