class AddTaxDeductibleReceiptFlagToCampaigns < ActiveRecord::Migration
    def change
        add_column :campaigns, :tax_deductible_receipt, :boolean, null: false, default: false
    end
end
