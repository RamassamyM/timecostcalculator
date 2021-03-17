require_relative 'base_shipping'
require 'csv'

# OceanShipping class
class OceanShipping < BaseShipping
  attr_accessor :carrier,
                :country_of_origin,
                :country_of_destination,
                :port_of_loading,
                :port_of_destination,
                :container_type,
                :expiry

  def initialize(attr = {})
    super(attr)
    @carrier = attr[:carrier]
    @country_of_origin = attr[:country_of_origin]
    @country_of_destination = attr[:country_of_destination]
    @port_of_loading = attr[:port_of_loading]
    @port_of_destination = attr[:port_of_destination]
    @container_type = attr[:container_type]
    @expiry = attr[:expiry]
  end

  def self.load
    super(csv_type: 'ocean_shipping')
  end

  def self.ports_of_destination
    results = []
    self.load.each do |shipping|
      results << shipping.port_of_destination
    end
    results.uniq.sort
  end

  def self.ports_of_loading
    results = []
    self.load.each do |shipping|
      results << shipping.port_of_loading
    end
    results.uniq.sort
  end

  def self.ports_of_loading_and_ports_of_destination
    ports_of_loading = []
    ports_of_destination = []
    self.load.each do |shipping|
      ports_of_loading << shipping.port_of_loading
      ports_of_destination << shipping.port_of_destination
    end
    { ports_of_loading: ports_of_loading.uniq.sort, ports_of_destination: ports_of_destination.uniq.sort }
  end
end
