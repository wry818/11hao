namespace :raisy do

    # To run this rake task, make sure the necessary SFTP credentials are in .env
    # foreman run rake raisy:load_order_data

    desc "Nightly load of Entertainment.com orders into the Raisy database"
    task :load_order_data => :environment do
        require 'csv'
        if defined?(Rails) && (Rails.env == 'development')
          Rails.logger = Logger.new(STDOUT)
        end

        Rails.logger.info "Beginning file transfer"
        Rails.logger.info "Host:  #{ENV['ENT_SFTP_HOST']}"
        Rails.logger.info "File path: #{ENV['ENT_ACCOUNT_DATA_FILEPATH']}"
        begin
            File.delete("./tmp/ent_order_data.txt") if File.exists?("./tmp/ent_order_data.txt")
            sftp = Net::SFTP.start(
                                            ENV['ENT_SFTP_HOST'],
                                            ENV['ENT_SFTP_USER'],
                                            {
                                                password: ENV['ENT_SFTP_PASSWORD'],
                                                port: ENV['ENT_SFTP_PORT']
                                            }
                                        )
            sftp.download!(ENV['ENT_ACCOUNT_DATA_FILEPATH'], "./tmp/ent_order_data.txt")

            # Average file size is 4MB, so we are comfortable reading the entire file into memory
            file = File.read("./tmp/ent_order_data.txt")

            # The file is read in the default encoding (UTF-8), however, there are invalid byte codes for this encoding,
            # so we need to remove the offending characters
            file = file.chars.select(&:valid_encoding?).join
        rescue => exception
            Rails.logger.info "Failed to transfer file: #{exception.message}"
        else
            begin
                Rails.logger.info "File transfer complete, beginning import"

                total_count = 0
                new_count = 0
                bad_count = 0
                existing_count = 0

                CSV.parse(file, headers: true, col_sep: '|') do |row|

                    # Make sure the required fields are present
                    if row['CREDITED_GROUP_ID'].present? && row['CREDITED_SELLER_ID'].present? && row['ORDER_ID'].present?

                        ent_order_params = {
                            name: row['ORDER_ID'],
                            address_line_one: row['ORDER_DATE'],
                            address_line_two: row['STATUS'],
                            address_city: row['PURCHASER_FIRST_NAME'],
                            address_state: row['PURCHASER_LAST_NAME'],
                            address_postal_code: row['PURCHASER_EMAIL'],
                            address_country: row['ORDER_TOTAL_AMT'],
                            address_country: row['UNIT_PRICE'],
                            address_country: row['ORDERED_QTY'],
                            address_country: row['CREDITED_GROUP_ID'],
                            address_country: row['CREDITED_SELLER_ID']
                        }

                        # Check to see if the campaign already exists in our database
                        if EntOrder.where(entertainment_order_id: row['ORDER_ID']).first.present?
                            existing_count += 1
                        else
                            campaign = Campaign.where(entertainment_group_id: row['CREDITED_GROUP_ID']).first
                            if campaign.present?
                                seller = Seller.where(referral_code: row['CREDITED_SELLER_ID']).first
                                if seller.present? && seller.campaign_id == campaign.id
                                    ent_order = EntOrder.new ent_order_params
                                    ent_order.campaign = campaign
                                    ent_order.seller = seller
                                    if ent_order.save
                                        new_count += 1
                                    else
                                        bad_count += 1
                                        Rails.logger.info "Data could not be saved for ORDER ID: #{row['ORDER_ID']} | GROUP ID: #{row['CREDITED_GROUP_ID']} | SELLER ID: #{row['CREDITED_SELLER_ID']}"
                                    end
                                else
                                    bad_count += 1
                                    Rails.logger.info "Seller not found for ORDER ID: #{row['ORDER_ID']} | GROUP ID: #{row['CREDITED_GROUP_ID']}"
                                end
                            else
                                bad_count += 1
                                Rails.logger.info "Campaign not found for ORDER ID: #{row['ORDER_ID']} | GROUP ID: #{row['CREDITED_GROUP_ID']}"
                            end
                        end
                    else
                        bad_count += 1
                        Rails.logger.info "Missing data for ORDER ID: #{row['ORDER_ID']} | GROUP ID: #{row['CREDITED_GROUP_ID']} | SELLER ID: #{row['CREDITED_SELLER_ID']}"
                    end

                    total_count += 1
                    Rails.logger.info "Processed: #{total_count}, #{new_count} new records imported, #{bad_count} bad records ignored, #{existing_count} existing records ignored" if total_count%100 == 0

                end
            rescue => exception
                Rails.logger.info "Failed to import file: #{exception.message}"
            else
                Rails.logger.info "Import completed successfully"
                Rails.logger.info "#{total_count} total records in file"
                Rails.logger.info "#{new_count} new records imported"
                Rails.logger.info "#{bad_count} bad records ignored"
                Rails.logger.info "#{existing_count} existing records ignored"
            end
        end

    end

end
