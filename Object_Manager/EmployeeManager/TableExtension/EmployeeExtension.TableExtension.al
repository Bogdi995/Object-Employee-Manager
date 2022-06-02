tableextension 50105 "Employee Extension" extends Employee
{
    Caption = 'Employee Extension';

    fields
    {
        field(50000; LeavePrediction; Enum "Leave Prediction")
        {
            Caption = 'Leave Prediction';
            DataClassification = CustomerContent;
        }
        field(50010; PredictionAccuracy; Enum "Prediction Accuracy")
        {
            Caption = 'Prediction Accuracy';
            DataClassification = CustomerContent;
        }
        field(50020; "PredictionAccuracy%"; Decimal)
        {
            Caption = 'Prediction Accuracy %';
            DataClassification = CustomerContent;
        }

    }

    fieldgroups
    {
        addlast(Brick; LeavePrediction, PredictionAccuracy)
        {
        }
    }

}