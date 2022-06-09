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
        field(50010; PredictionConfidence; Enum "Prediction Confidence")
        {
            Caption = 'Prediction Confidence';
            DataClassification = CustomerContent;
        }
        field(50020; "PredictionConfidence%"; Decimal)
        {
            Caption = 'Prediction Confidence %';
            DataClassification = CustomerContent;
        }

    }

    fieldgroups
    {
        addlast(Brick; LeavePrediction, PredictionConfidence)
        {
        }
    }

}