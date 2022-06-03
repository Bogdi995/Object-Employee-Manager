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
                ToolTip = 'Specifies the accuracy of the leave prediction. "Low" is less than 80%, "Medium" is between 80% and 90% and "High" is above 90%.';
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
            action(PredictLeave)
            {
                Caption = 'Predict Leave';
                Image = Calculate;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    PredictEmployeeLeave: Codeunit "Predict Employee Leave";
                begin
                    PredictEmployeeLeave.PredictBatch();
                    CurrPage.Update();
                end;
            }

            action(WhyLeave)
            {
                Caption = 'Why Leave';
                Image = Questionaire;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    TrainEmployeeLeaveML: Codeunit "Train Employee Leave";
                begin
                    TrainEmployeeLeaveML.DownloadPlotOfTheModel();
                end;
            }

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
    end;

    procedure SetStyle(): Text
    var
        FavorableLbl: Label 'Favorable';
        AmbiguousLbl: Label 'Ambiguous';
        AttentionLbl: Label 'Attention';
    begin
        case Rec.LeavePrediction of
            Rec.LeavePrediction::Stay:
                exit(FavorableLbl);
            Rec.LeavePrediction::ChanceLeave:
                exit(AmbiguousLbl);
            Rec.LeavePrediction::Leave:
                exit(AttentionLbl);
        end;
    end;
}