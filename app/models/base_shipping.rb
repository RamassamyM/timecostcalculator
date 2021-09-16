# require 'yaml'
# CONFIG = YAML.load_file('/Users/michaelr/Documents/TRAVAIL/AUTOENTREPRENEUR/7 Clients/Meagan Butters - Ardo/code/services/CONFIG/config.yml')

# base class for all shipping loaders classes
class BaseShipping
  attr_accessor :transit_time, :cost, :currency, :notes

  def initialize(attr = {})
    @transit_time = attr[:transit_time]
    @cost = attr[:cost]
    @currency = attr[:currency]
    @notes = attr[:notes]
  end

  class CSVError < StandardError
    def message(message)
      "#{message} Please contact your administrator."
    end
  end

  class NotFoundCSVError < CSVError
    def message
      super("Error occurred when trying to load the CSV. File not found.")
    end
  end

  class NoPermissionCSVError < CSVError
    def message
      super("Error occurred when trying to load the CSV. Permission requirement problem.")
    end
  end

  class ParsingCSVError < CSVError
    def message
      super("Error occurred when trying to parse the CSV.")
    end
  end

  class ProgramCSVError < CSVError
    def message
      super("Sorry, we coul not process your request due to a technical problem.")
    end
  end

  def self.settings
    settings = {}
    Setting.all.each do |s|
      if settings[s.category.to_sym]
        settings[s.category.to_sym][s.name.to_sym] =  s.value
      else
        settings[s.category.to_sym] = { s.name.to_sym => s.value }
      end
    end
    settings
  end

  def self.load(csv_type:)
    begin
      settings = self.settings
      filepath = settings[:files_location][:directory_path] + settings[:filenames][csv_type.to_sym]
      settings[:csv_options][:headers] = settings[:csv_options][:headers].to_sym
      results = []
      # settings[:csv_options]
      CSV.foreach(filepath, settings[:csv_options]) do |row|
        data = {}
        settings["headers_#{csv_type}".to_sym].each do |key, value|
          begin
            case key.to_s
            when "transit_time"
              data[key] = row[value].to_i
            when "cost"
              data[key] = row[value].to_i
            when "frequency"
              data[key] = row[value].to_f
            # when "notes"
            #   data[key] = row[value] ? row[value] : ''
            else
              data[key] = row[value] ? row[value].upcase : ''
            end
            # data[key] = %w[transit_time cost].include?(key.to_s) ? row[value].to_i : row[value].upcase
          rescue StandardError => e
            puts e
            raise ParsingCSVError
          end
        end
        results << new(data).convert_to_usd(currency_rates_to_usd: settings[:currency_rates_to_usd])
      end
      results
    rescue Errno::ENOENT => e
      puts e
      raise NotFoundCSVError
    rescue Errno::EACCES => e
      puts e
      raise NoPermissionCSVError
    rescue StandardError => e
      puts e
      raise ProgramCSVError
    end
  end

  def convert_to_usd(currency_rates_to_usd:)
    return self unless currency_rates_to_usd.keys.include?(@currency.to_sym)
    print "Currency is being converted to usd..."
    puts @currency
    puts @cost
    @cost = (@cost.to_i * currency_rates_to_usd[@currency.to_sym].to_f).round
    puts @cost
    @currency = 'USD'
    self
  end
end
