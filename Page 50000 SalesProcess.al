page 50000 "Sales Requisitions"
{

    ApplicationArea = All;
    Caption = 'Sales Requisitions';
    PageType = List;
    SourceTable = "Sales Requisition";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specifies the Customer No.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'It Specifies the Customer Name';
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specifies the Item No.';
                }
                field("Item Description"; rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specified the Item Description';
                }

                field("Sales Person Code"; Rec."Sales Person Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specifies the Sales person Code';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'it specifies the Quantity';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specified Date';
                }
                field("Salesperson Email"; Rec."Salesperson Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specifies the Salesperson Email';
                }
                field("Order Created"; Rec."Order Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'It Specified Order Created';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'It specifies Sales Order No.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Make Order")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    MakeOrder();
                end;
            }
        }
    }

    local procedure MakeOrder()
    var
        SalesReq: Record "Sales Requisition";
        SalesReq2: Record "Sales Requisition";
        CustNo: Code[20];
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LineNo: Integer;

        ProcessCompleted: Label 'Process Completed Successfully';
        Created: Boolean;
        ConfirmTxt: Label 'Do you want to confirm making the Orders?';
        ErrorTxt: Label 'No New Lines found for Order Creation';
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Order Nos.");
        IF not Confirm(ConfirmTxt) then
            EXIT;

        Created := false;
        SalesReq.RESET;
        SalesReq.SetCurrentKey("Customer No.", "Order Date");
        SalesReq.SetRange("Order Created", false);
        IF SalesReq.FindSet(true) THEN begin
            repeat

                IF (CustNo = '') OR (CustNo <> SalesReq."Customer No.") THEN begin
                    SalesReq2.Reset();
                    SalesReq2.SetCurrentKey("Customer No.", "Order Date");
                    SalesReq2.SetRange("Customer No.", SalesReq."Customer No.");
                    SalesReq2.SetRange("Order Created", false);
                    IF SalesReq2.FindSet(true) THEN begin
                        SalesHeader.INIT();
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                        SalesHeader."No." := NoSeriesManagement.GetNextNo(SalesReceivablesSetup."Order Nos.", WorkDate, true);
                        SalesHeader.Validate("Sell-to Customer No.", SalesReq2."Customer No.");
                        SalesHeader.Validate("Posting Date", SalesReq2."Order Date");
                        SalesHeader.Validate("Document Date", SalesReq2."Order Date");
                        SalesHeader."Salesperson Code" := SalesReq2."Sales Person Code";

                        SalesHeader.Insert(TRUE);
                        LineNo := 10000;
                        repeat
                            SalesLine.INIT();
                            SalesLine."Document Type" := SalesHeader."Document Type";
                            SalesLine."Document No." := SalesHeader."No.";
                            SalesLine."Line No." := LineNo;
                            LineNo += 10000;
                            SalesLine.Validate(Type, SalesLine.type::Item);
                            SalesLine.Validate("No.", SalesReq2."Item No.");
                            SalesLine.Validate(Quantity, SalesReq2.Quantity);
                            SalesLine.Insert(True);
                            Created := true;

                            SalesReq2."Order Created" := true;
                            SalesReq2."Order No." := SalesHeader."No.";
                            SalesReq2.Modify(true);
                        until SalesReq2.Next = 0;


                    end;
                end;
                CustNo := SalesReq."Customer No.";

            until SalesReq.Next = 0;
        end
        ELse
            Error(ErrorTxt);

        IF Created then
            Message(ProcessCompleted);
    end;
}
