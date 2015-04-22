namespace :raisy do

  # To run this rake task, make sure the necessary SFTP credentials are in .env
  # foreman run rake raisy:load_account_data

  desc "Nightly load of Entertainment.com accounts into the Raisy database"
  task :load_account_data => :environment do
    require 'csv'
    if defined?(Rails) && (Rails.env == 'development')
      Rails.logger = Logger.new(STDOUT)
      Dotenv.load
    end

    Rails.logger.info "Beginning file transfer"
    Rails.logger.info "Host:  #{ENV['ENT_SFTP_HOST']}"
    Rails.logger.info "File path: #{ENV['ENT_ACCOUNT_DATA_FILEPATH']}"
    begin
      File.delete("./tmp/ent_account_data.txt") if File.exists?("./tmp/ent_account_data.txt")
      sftp = Net::SFTP.start(
          ENV['ENT_SFTP_HOST'],
          ENV['ENT_SFTP_USER'],
          {
              password: ENV['ENT_SFTP_PASSWORD'],
              port: ENV['ENT_SFTP_PORT']
          }
      )
      sftp.download!(ENV['ENT_ACCOUNT_DATA_FILEPATH'], "./tmp/ent_account_data.txt")

      # Average file size is 4MB, so we are comfortable reading the entire file into memory
      file = File.read("./tmp/ent_account_data.txt")

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
        existing_count = 0

        CSV.parse(file, headers: true, col_sep: '|') do |row|

          # Make sure the required fields are present
          if row['GROUP_ID'].present? && row['COMPANYNAME'].present? && row['CUSTOMER_ID'].present? && row['CUSTOMER'].present?

            campaign_params = {
                title: row['GROUP_ID'],
                collection_id: 1
            }

            organization_params = {
                name: row['CUSTOMER'],
                address_line_one: row['BILLTO_ADDRESS_LINE_1'],
                address_line_two: row['BILLTO_ADDRESS_LINE_2'],
                address_city: row['BILLTO_CITY'],
                address_state: row['BILLTO_STATE'],
                address_postal_code: row['BILLTO_ZIP'],
                address_country: row['BILLTO_COUNTRY'],
                deleted: false
            }

            organization = Organization.where(entertainment_customer_id: row['CUSTOMER_ID']).first

            # Check to see if the campaign already exists in our database
            campaign = Campaign.storefronts.where(entertainment_group_id: row['GROUP_ID']).first

            if organization
              existing_count += 1

              organization.update_attributes organization_params
            else
              new_count += 1

              organization = Organization.create organization_params
              organization.update_attribute(:entertainment_customer_id, row['CUSTOMER_ID'])
            end

            if campaign
              campaign.title = row['COMPANYNAME']
              campaign.active = true
              campaign.save
            else
              campaign = Campaign.create campaign_params

              campaign.entertainment_group_id = row['GROUP_ID']
              campaign.organization = organization
              campaign.campaign_type = 2
              campaign.organizer_quote = 'Please help support our fundraiser!'
              campaign.organizer_id = -1
              campaign.save

              campaign.title = row['COMPANYNAME']
              campaign.save
            end

            Country.all.each do |country|
              name = organization.address_country || ""

              if country.name.upcase == name.upcase || country.abbrev.upcase == name.upcase
                organization.country_id = country.id

                country.state_provinces.each do |state|
                  name = organization.address_state || ""

                  if state.name.upcase == name.upcase || state.abbrev.upcase == name.upcase
                    organization.state_province_id = state.id
                  end
                end
                
                organization.save
              end
            end
          else
            Rails.logger.info "Missing data for #{row['GROUP_ID']} | #{row['COMPANYNAME']} | #{row['CUSTOMER_ID']} | #{row['CUSTOMER']}"
          end

          total_count += 1
          Rails.logger.info "Imported: #{total_count}, #{new_count} new records, #{existing_count} existing records" if total_count%100 == 0

        end
      rescue => exception
        Rails.logger.info "Failed to import file: #{exception.message}"
      else
        Rails.logger.info "Import completed successfully"
        Rails.logger.info "#{total_count} total records in file"
        Rails.logger.info "#{new_count} new records imported"
        Rails.logger.info "#{existing_count} existing records updated"
      end
    end

  end

end
