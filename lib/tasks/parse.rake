require 'csv'
# require 'logger'
# log = Logger.new( 'log.txt', 'daily' )
# log.debug "Once the log becomes at least one"
# log.debug "day old, it will be renamed and a"
# log.debug "new log.txt file will be created."

namespace :parse do
  desc "Parse CSV ocean freight, check for expiry and enqueue expiry emails in jobs "
  task enqueue_expiry_emails_from_csv_ocean_freight: :environment do
    puts 'Starting rake task for parsing and sending expiry emails'
    settings = BaseShipping.settings
    puts 'Loading settings from database'
    filepath = settings[:files_location][:directory_path] + settings[:filenames][:ocean_shipping]
    settings[:csv_options][:headers] = settings[:csv_options][:headers].to_sym
    puts 'starting parsing CSV...'
    CSV.foreach(filepath, settings[:csv_options]) do |row|
      begin
        if DateTime.strptime(row['Expiry'], '%d/%m/%y') == Date.today + 10.days
          puts "ENQUEUE email for ===== #{row['Expiry']}"
          email_to = ''
          if settings[:expiry_email][:ocean_freight_csv_column_for_email] && row[settings[:expiry_email][:ocean_freight_csv_column_for_email]]
            email_to = row[settings[:expiry_email][:ocean_freight_csv_column_for_email]]
          else
            email_to = settings[:expiry_email][:default]
          end
          puts "Email to: #{email_to}"
          ExpiryMailer.alert(data: row.to_hash, email_to: email_to).deliver_later
        else
          puts "NOT expiry for === #{row['Expiry']}"
        end
      rescue StandardError => e
        # todo : use logger
        puts "ALERT: #{e.message} for === #{row['Expiry']}"
      end
    end
    puts "Parsing and enqueuing emails done."
    puts "finish"
  end
end
