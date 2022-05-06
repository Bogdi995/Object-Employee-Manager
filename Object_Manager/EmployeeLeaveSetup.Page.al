page 50106 "Employee Leave Setup"
{
    PageType = Card;
    SourceTable = "Employee Leave Setup";
    Caption = 'Employee Leave Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(WebServiceDetails)
            {
                Caption = 'Web Service Details';
                field(APIKey; Rec.APIKey)
                {
                    ToolTip = 'Specifies the API key';
                    ApplicationArea = All;
                }
                field(EndpointURI; Rec.EndpointURI)
                {
                    ToolTip = 'Specifies the endpoint URI';
                    ApplicationArea = All;
                }
                field(DatasetLink; Rec.DatasetLink)
                {
                    ToolTip = 'Specifies the link to the dataset';
                    ApplicationArea = All;
                }
            }
        }
    }
}