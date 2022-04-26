enum 50105 "Leave Prediction"
{
    Caption = 'Leave Prediction';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Stay)
    {
        Caption = 'Will probably stay';
    }
    value(2; ChanceLeave)
    {
        Caption = 'There''s a chance to leave';
    }
    value(3; Leave)
    {
        Caption = 'Will probably leave';
    }

}