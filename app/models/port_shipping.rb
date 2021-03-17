require_relative 'base_shipping'
require 'csv'

# PortShipping class
class PortShipping < BaseShipping
  attr_accessor :supplier, :place_of_loading, :port_of_loading, :forwarder

  def initialize(attr = {})
    super(attr)
    @supplier = attr[:supplier]
    @place_of_loading = attr[:place_of_loading]
    @port_of_loading = attr[:port_of_loading]
    @forwarder = attr[:forwarder]
  end

  def self.load
    super(csv_type: 'port_shipping')
  end

  def self.suppliers
    suppliers = []
    self.load.each do |shipping|
      suppliers << shipping.supplier
    end
    suppliers.uniq.sort
  end

  def self.places_of_loading_with_suppliers
    results = []
    self.load.each do |shipping|
      results << [shipping.supplier, shipping.place_of_loading]
    end
    results.uniq
  end
end
