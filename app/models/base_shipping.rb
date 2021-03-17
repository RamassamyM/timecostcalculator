require 'yaml'
CONFIG = YAML.load_file('/Users/michaelr/Documents/TRAVAIL/AUTOENTREPRENEUR/7 Clients/Meagan Butters - Ardo/code/services/CONFIG/config.yml')
# base class for all shipping loaders classes
class BaseShipping
  attr_accessor :transit_time, :cost, :currency

  def initialize(attr = {})
    @transit_time = attr[:transit_time]
    @cost = attr[:cost]
    @currency = attr[:currency]
  end

  def self.load(csv_type:)
    results = []
    CSV.foreach(filepaths[csv_type], csv_options) do |row|
      data = {}
      csv_headers[csv_type].each do |key, value|
        data[key.to_sym] = %w[transit_time cost].include?(key) ? row[value].to_i : row[value].upcase.split(' ').join('')
      end
      results << new(data).convert_to_usd
    end
    results
  end

  def self.csv_options
    { col_sep: CONFIG['csv_options']['col_sep'],
      quote_char: CONFIG['csv_options']['quote_char'],
      headers: CONFIG['csv_options']['headers'] }
  end

  def self.filepaths
    filepaths = {}
    CONFIG['filenames'].each do |key, value|
      filepaths[key] = CONFIG['folderpath'] + value
    end
    filepaths
  end

  def self.csv_headers
    CONFIG['headers']
  end

  def convert_to_usd
    return self unless CONFIG['currency_rates_to_usd'].keys.include?(@currency)

    @cost = (@cost.to_i * CONFIG['currency_rates_to_usd'][@currency]).round
    @currency = 'USD'
    self
  end
end
