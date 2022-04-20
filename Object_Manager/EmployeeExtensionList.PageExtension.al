pageextension 50105 "Employee Extension List" extends "Employee List"
{
    Caption = 'Employees';
    PromotedActionCategories = 'New,Process,Report,Leave';

    layout
    {
        addafter(FullName)
        {
            field(LeavePrediction; Rec.LeavePrediction)
            {
                Caption = 'Leave Prediction';
                ToolTip = 'Predicts if the employee will leave or not.';
                ApplicationArea = All;
                StyleExpr = Style;
            }
            field(PredictionAccuracy; Rec.PredictionAccuracy)
            {
                Caption = 'Prediction Accuracy';
                ToolTip = 'Specifies the accuracy of the leave prediction. High is above 90%, Medium is between 80% and 90%, and Low is less than 80%.';
                ApplicationArea = All;
                StyleExpr = Style;
            }
            field("PredictionAccuracy%"; Rec."PredictionAccuracy%")
            {
                Caption = 'Prediction Accuracy %';
                ToolTip = 'Specifies the percentage of the prediction accuracy.';
                ApplicationArea = All;
                StyleExpr = Style;
                BlankZero = true;
            }
        }
    }

    actions
    {
        addafter("E&mployee")
        {
            action(LeaveHistory)
            {
                Caption = 'Leave History';
                Image = History;
                ApplicationArea = All;
                RunObject = page "Employee Leave History";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
            }
        }
    }

    var
        Style: Text;

    trigger OnAfterGetRecord()
    begin
        Style := SetStyle;
        // ShowPdfInViewer();
    end;

    procedure SetStyle(): Text
    begin
        if Rec.LeavePrediction = Rec.LeavePrediction::Leave then
            exit('Attention');
        exit('')
    end;

    // local procedure ShowPdfInViewer()
    // var
    //     TrainEmployeeLeaveML: Codeunit "Train EmployeeLeave ML";
    // begin
    //     CurrPage.PDFViewer.Page.LoadPdfFromBase64(TrainEmployeeLeaveML.GetPlotOfTheModel());
    // end;
}