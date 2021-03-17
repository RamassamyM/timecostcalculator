require_relative 'base_shipping'
require 'csv'

# Drayage class
class DrayageShipping < BaseShipping
  attr_accessor :port_of_destination, :place_of_delivery, :max_gross_cargo

  def initialize(attr = {})
    super(attr)
    @port_of_destination = attr[:port_of_destination]
    @place_of_delivery = attr[:place_of_delivery]
    @max_gross_cargo = attr[:max_gross_cargo]
  end

  def self.load
    super(csv_type: 'drayage_shipping')
  end

  def self.ports_of_destination
    results = []
    self.load.each do |shipping|
      results << shipping.port_of_destination
    end
    results.uniq.sort
  end

  def self.places_of_delivery
    results = []
    self.load.each do |shipping|
      results << shipping.place_of_delivery
    end
    results.uniq.sort
  end
end
