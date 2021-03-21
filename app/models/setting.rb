require 'yaml'
CONFIG_FILE_PATH = File.join(__dir__, '../../config/config_csv_ardo.yml')

# setting model
class Setting
  def initialize(filepath: CONFIG_FILE_PATH)
    @setting = YAML.load_file(filepath)
  end

  def read
    puts @setting
    @setting
  end

  def write(new_fields = {}, filepath: CONFIG_FILE_PATH)
    new_fields.each do |key, value|
      @setting[key] = value
    end
    File.open(filepath, 'w') do |file|
      file.write @setting.to_yaml
    end
  end
end