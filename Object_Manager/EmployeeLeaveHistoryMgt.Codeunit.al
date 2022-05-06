codeunit 50105 "Employee Leave History Mgt"
{
    procedure UpdateHistory();
    var
        EmployeeLeaveHistory: Record "Employee Leave History";
        EmployeeLeaveSetup: Record "Employee Leave Setup";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JArray: JsonArray;
        JObject: JsonObject;
        JValue: JsonValue;
        JToken: JsonToken;
        JText: Text;
        Progress: Dialog;
        UpdateEmployeeLeaveHistory: Label 'The employee leave history is being updated...#1';
        UserAgentLbl: Label 'User-Agent';
        BusinessCentralLbl: Label 'Business Central';
        WebServiceFailedLbl: Label 'The call to the web service failed.';
        WebServiceErrorLbl: Label 'The web service returned an error message:\ Status code: %1 \ Description: %2';
        DataRefreshedSuccessfullyLbl: Label 'History updated successfully!';
        Index: Integer;
    begin
        EmployeeLeaveSetup.Get();
        EmployeeLeaveHistory.DeleteAll();

        Client.DefaultRequestHeaders.Add(UserAgentLbl, BusinessCentralLbl);
        if not Client.Get(EmployeeLeaveSetup.DatasetLink, ResponseMessage) then
            Error(WebServiceFailedLbl);

        if not ResponseMessage.IsSuccessStatusCode then
            Error(WebServiceErrorLbl, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);

        ResponseMessage.Content.ReadAs(JText);

        if not JArray.ReadFrom(JText) then begin
            JToken.ReadFrom(JText);
            InsertEmployeeLeaveHistoryData(JToken);
        end else begin
            Progress.Open(UpdateEmployeeLeaveHistory, Index);
            for Index := 0 to JArray.Count - 1 do begin
                JArray.Get(Index, JToken);
                Progress.Update();
                InsertEmployeeLeaveHistoryData(JToken);
            end;
            Progress.Close();
        end;

        Message(DataRefreshedSuccessfullyLbl);
    end;

    procedure InsertEmployeeLeaveHistoryData(JToken: JsonToken);
    var
        EmployeeLeaveHistory: Record "Employee Leave History";
        JObject: JsonObject;
        SatisfactionLevelLbl: Label 'satisfaction_level';
        LastEvaluationLbl: Label 'last_evaluation';
        NumberProjectLbl: Label 'number_project';
        AverageMonthlyHoursLbl: Label 'average_montly_hours';
        TimeSpendCompanyLbl: Label 'time_spend_company';
        WorkAccidentLbl: Label 'Work_accident';
        LeftLbl: Label 'left';
        PromotionLast5YearsLbl: Label 'promotion_last_5years';
        SalesLbl: Label 'sales';
        SalaryLbl: Label 'salary';
    begin
        JObject := JToken.AsObject;
        EmployeeLeaveHistory.Init();

        EmployeeLeaveHistory.SatisfactionLevel := GetJsonToken(JObject, SatisfactionLevelLbl).AsValue.AsDecimal;
        EmployeeLeaveHistory.LastEvaluation := GetJsonToken(JObject, LastEvaluationLbl).AsValue.AsDecimal;
        EmployeeLeaveHistory.NumberProject := GetJsonToken(JObject, NumberProjectLbl).AsValue.AsInteger;
        EmployeeLeaveHistory.AverageMonthlyHours := GetJsonToken(JObject, AverageMonthlyHoursLbl).AsValue.AsInteger;
        EmployeeLeaveHistory.TimeSpendCompany := GetJsonToken(JObject, TimeSpendCompanyLbl).AsValue.AsInteger;
        EmployeeLeaveHistory.WorkAccident := GetJsonToken(JObject, WorkAccidentLbl).AsValue.AsInteger;
        EmployeeLeaveHistory.Left := (GetJsonToken(JObject, LeftLbl).AsValue.AsInteger = 1);
        EmployeeLeaveHistory.PromotionLast5years := GetJsonToken(JObject, PromotionLast5YearsLbl).AsValue.AsInteger;
        EmployeeLeaveHistory.Sales := CopyStr(GetJsonToken(JObject, SalesLbl).AsValue.AsText, 1, 250);
        EmployeeLeaveHistory.Salary := CopyStr(GetJsonToken(JObject, SalaryLbl).AsValue.AsText, 1, 250);

        EmployeeLeaveHistory.Insert(true);
    end;

    procedure GetJsonToken(JObject: JsonObject; TokenKey: Text) JToken: JsonToken;
    var
        ErrorTokenKeyLbl: Label 'Could not find a token with key %1';
    begin
        if not JObject.Get(TokenKey, JToken) then
            Error(ErrorTokenKeyLbl, TokenKey);
    end;
}
