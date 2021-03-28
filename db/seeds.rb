# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
begin_time = Time.now
print 'Clean DB...'
Setting.delete_all
puts 'done'
puts 'Start seeding'
print 'Loading config yaml file...'
config = YAML.load_file('db/config_csv_ardo.yml')
puts 'Done'
config.each do |type_key, type_hash|
  type_hash.each do |key, value|
    print "Create setting #{type_key} - #{key} : #{value}..."
    Setting.create(name: key, value: value, category: type_key)
    puts 'Done'
  end
end

puts "Seeding completed in #{Time.now - begin_time} sec !"