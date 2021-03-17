require_relative 'base_shipping'
require 'csv'

# TruckShipping class
class TruckShipping < BaseShipping
  attr_accessor :place_of_loading, :place_of_delivery, :trucker, :max_gross_cargo

  def initialize(attr = {})
    super(attr)
    @place_of_loading = attr[:place_of_loading]
    @place_of_delivery = attr[:place_of_delivery]
    @trucker = attr[:trucker]
    @max_gross_cargo = attr[:max_gross_cargo]
  end

  def self.load
    super(csv_type: 'truck_shipping')
  end

  def self.places_of_delivery
    results = []
    self.load.each do |shipping|
      results << shipping.place_of_delivery
    end
    results.uniq.sort
  end

  def self.places_of_loading_and_places_of_delivery
    places_of_loading = []
    places_of_delivery = []
    self.load.each do |shipping|
      places_of_loading << shipping.place_of_loading
      places_of_delivery << shipping.place_of_delivery
    end
    { places_of_loading: places_of_loading.uniq.sort, places_of_delivery: places_of_delivery.uniq.sort }
  end
end
