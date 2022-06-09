table 50105 "Employee Leave History"
{
    Caption = 'Employee Leave History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; LineNo; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; SatisfactionLevel; Decimal)
        {
            Caption = 'Satisfaction Level';
            DataClassification = CustomerContent;
        }
        field(20; LastEvaluation; Decimal)
        {
            Caption = 'Last Evaluation';
            DataClassification = CustomerContent;
        }
        field(30; NumberProject; Integer)
        {
            Caption = 'Number Project';
            DataClassification = CustomerContent;
        }
        field(40; AverageMonthlyHours; Integer)
        {
            Caption = 'Average Monthly Hours';
            DataClassification = CustomerContent;
        }
        field(50; TimeSpendCompany; Integer)
        {
            Caption = 'Time Spend Company';
            DataClassification = CustomerContent;
        }
        field(60; WorkAccident; Integer)
        {
            Caption = 'Work Accident';
            DataClassification = CustomerContent;
        }
        field(70; Left; Boolean)
        {
            Caption = 'Left';
            DataClassification = CustomerContent;
        }
        field(80; PromotionLast5years; Integer)
        {
            Caption = 'Promotion Last 5 years';
            DataClassification = CustomerContent;
        }
        field(90; Sales; Text[250])
        {
            Caption = 'Sales';
            DataClassification = CustomerContent;
        }
        field(100; Salary; Text[250])
        {
            Caption = 'Salary';
            DataClassification = CustomerContent;
        }
        field(110; Confidence; Decimal)
        {
            Caption = 'Confidence';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key("PK"; LineNo)
        {
            Clustered = true;
        }
    }

    procedure UpdateEmployeeLeaveHistoryMgt();
    var
        EmployeeLeaveHistoryMgt: Codeunit "Employee Leave History Mgt";
    begin
        EmployeeLeaveHistoryMgt.UpdateHistory();
    end;

}
