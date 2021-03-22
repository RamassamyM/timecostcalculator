# require 'yaml'
# CONFIG = YAML.load_file('/Users/michaelr/Documents/TRAVAIL/AUTOENTREPRENEUR/7 Clients/Meagan Butters - Ardo/code/services/CONFIG/config.yml')

# base class for all shipping loaders classes
class BaseShipping
  attr_accessor :transit_time, :cost, :currency

  def initialize(attr = {})
    @transit_time = attr[:transit_time]
    @cost = attr[:cost]
    @currency = attr[:currency]
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
    settings = self.settings
    filepath = settings[:files_location][:directory_path] + settings[:filenames][csv_type.to_sym]
    settings[:csv_options][:headers] = settings[:csv_options][:headers].to_sym
    results = []
    # settings[:csv_options]
    CSV.foreach(filepath, settings[:csv_options]) do |row|
      data = {}
      settings["headers_#{csv_type}".to_sym].each do |key, value|
        data[key] = %w[transit_time cost].include?(key.to_s) ? row[value].to_i : row[value].upcase.split(' ').join('')
      end
      results << new(data).convert_to_usd(currency_rates_to_usd: settings[:currency_rates_to_usd])
    end
    results
  end

  def convert_to_usd(currency_rates_to_usd:)
    return self unless currency_rates_to_usd.keys.include?(@currency)

    @cost = (@cost.to_i * currency_rates_to_usd[@currency].to_f).round
    @currency = 'USD'
    self
  end
end
