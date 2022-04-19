page 50105 "Employee Leave History"
{
    PageType = List;
    SourceTable = "Employee Leave History";
    Caption = 'Employee Leave History';
    Editable = false;
    SourceTableView = order(descending);
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(SatisfactionLevel; Rec.SatisfactionLevel)
                {
                    ToolTip = 'Specifies the satisfaction level of the employee.';
                    ApplicationArea = All;
                }
                field(LastEvaluation; Rec.LastEvaluation)
                {
                    ToolTip = 'Specifies the last evaluation satisfaction level of the employee.';
                    ApplicationArea = All;
                }
                field(NumberProject; Rec.NumberProject)
                {
                    ToolTip = 'Specifies the number of projects the employee had in the company.';
                    ApplicationArea = All;
                }
                field(AverageMonthlyHours; Rec.AverageMonthlyHours)
                {
                    ToolTip = 'Specifies how many hours the employee worked on average monthly.';
                    ApplicationArea = All;
                }
                field(TimeSpendCompany; Rec.TimeSpendCompany)
                {
                    ToolTip = 'Specifies how many years the employee spent in the company.';
                    ApplicationArea = All;
                }
                field(WorkAccident; Rec.WorkAccident)
                {
                    ToolTip = 'Specifies how many work related accidents the employee had.';
                    ApplicationArea = All;
                }
                field(Left; Rec.Left)
                {
                    ToolTip = 'Specifies if the employee left or not';
                    ApplicationArea = All;
                }
                field(PromotionLast5years; Rec.PromotionLast5years)
                {
                    ToolTip = 'Specifies how many promotions the employee got in the last 5 years.';
                    ApplicationArea = All;
                }
                field(Sales; Rec.Sales)
                {
                    ToolTip = 'Specifies the department in which the employee worked.';
                    ApplicationArea = All;
                }
                field(Salary; Rec.Salary)
                {
                    ToolTip = 'Specifies the salary of the employee (low, medium, high).';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(UpdateHistory)
            {
                Caption = 'Update History';
                Image = RefreshLines;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    Rec.UpdateEmployeeLeaveHistoryMgt();
                    CurrPage.Update();
                    if Rec.FindFirst() then;
                end;
            }
        }
    }

}
