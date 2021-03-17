class PurchasesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :purchase1, :purchase2, :purchase3, :purchase4, :purchase5, :purchase6]

  def index
  end

  def purchase1
    @suppliers_and_places_of_loading = PortShipping.places_of_loading_with_suppliers
    @all_places_of_delivery = Query.new.all_places_of_delivery
  end

  def purchase2
    @ports_of_destination = DrayageShipping.ports_of_destination
    @all_places_of_delivery = Query.new.all_places_of_delivery
  end

  def purchase3
    @suppliers = PortShipping.suppliers
    @all_places_of_delivery = Query.new.all_places_of_delivery
  end

  def purchase4
    @suppliers_and_places_of_loading = PortShipping.places_of_loading_with_suppliers
    @ports_of_destination = OceanShipping.ports_of_destination
  end

  def purchase5
    ports = OceanShipping.ports_of_loading_and_ports_of_destination
    @ports_of_loading = ports[:ports_of_loading]
    @ports_of_destination = ports[:ports_of_destination]
  end

  def purchase6
    places = TruckShipping.places_of_loading_and_places_of_delivery
    @places_of_loading = places[:places_of_loading]
    @places_of_delivery = places[:places_of_delivery]
    @query = Query.new(name: 'Search')
  end
end
