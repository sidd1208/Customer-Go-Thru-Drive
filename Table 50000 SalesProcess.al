table 50000 "Sales Requisition"
{
    DataClassification = ToBeClassified;
    Caption = 'Sales Requisition';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(2; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                Customer.GET("Customer No.");
                "Customer Name" := Customer.Name + Customer."Name 2";
            end;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item where(Blocked = const(false));

            trigger OnValidate()
            begin
                Item.Get("Item No.");
                "Item Description" := Item.Description + Item."Description 2";
            end;
        }

        field(4; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Sales Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
        }
        field(6; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(7; "Order Created"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(9; "Customer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Item Description"; Text[100])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Salesperson Email"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PK2; "Customer No.", "Order Date")
        {

        }
    }

    var
        Customer: Record Customer;
        Item: Record Item;
        SalesReq: Record "Sales Requisition";

    trigger OnInsert()
    begin
        IF SalesReq.FindLast() then
            "Entry No." := SalesReq."Entry No." + 1
        ELSE
            "Entry No." := 1;

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}