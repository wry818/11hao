class CreateOrders < ActiveRecord::Migration
    def change
        create_table :orders do |t|

            t.integer :campaign_id

            t.string  :charge_id
            t.string  :balanced_hold_uri
            t.string  :balanced_debit_uri
            t.string  :balanced_refund_uri

            t.integer :status

            t.string  :fullname
            t.string  :email
            t.string  :card_type
            t.string  :card_last_four
            t.string  :card_expiration_month
            t.string  :card_expiration_year
            t.string  :address_line_one
            t.string  :address_line_two
            t.string  :address_city
            t.string  :address_state
            t.string  :address_postal_code
            t.string  :address_country
            t.string  :billing_zip_code

            t.timestamps
        end
    end
end
