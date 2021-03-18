require 'yaml'

class SearchesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  config = YAML.load_file('/Users/michaelr/Documents/TRAVAIL/AUTOENTREPRENEUR/7 Clients/Meagan Butters - Ardo/code/services/CONFIG/config.yml')
  CONTAINER_TYPE_DEFAULT = config['queries']['defaults']['container_type'].upcase.split.join

  def index
    unless params[:search_type]
      flash[:alert] = 'We cannot process your search'
      redirect_to :back
    end
    # begin
      @results = []
      @purchase_type = params[:search_type]
      case @purchase_type
      when 'fca_purchase'
        places_of_delivery = params[:places_of_delivery]
        supplier_with_place_of_loading = JSON.parse(params[:supplier_with_place_of_loading])
        places_of_delivery.each do |place_of_delivery|
          @results.concat(fca_purchases(supplier: supplier_with_place_of_loading[0],
                                        place_of_loading: supplier_with_place_of_loading[1],
                                        place_of_delivery: place_of_delivery))
        end
      when 'cif_purchase'
        places_of_delivery = params[:places_of_delivery]
        places_of_delivery.each do |place_of_delivery|
          @results.concat(cif_cfr_purchases(port_of_destination: params[:place_of_delivery],
                                            place_of_delivery: place_of_delivery))
        end
      when 'fob_purchase'
        places_of_delivery = params[:places_of_delivery]
        places_of_delivery.each do |place_of_delivery|
          @results.concat(fob_purchases(supplier: params[:supplier],
                                        place_of_delivery: place_of_delivery))
        end
      when 'export_purchase'
        ports_of_destination = params[:ports_of_destination]
        supplier_with_place_of_loading = JSON.parse(params[:supplier_with_place_of_loading])
        ports_of_destination.each do |port_of_destination|
          @results.concat(export_shipments(supplier: supplier_with_place_of_loading[0],
                                           place_of_loading: supplier_with_place_of_loading[1],
                                           port_of_destination: port_of_destination))
        end
      when 'crosstrade_purchase'
        ports_of_destination = params[:ports_of_destination]
        ports_of_destination.each do |port_of_destination|
          @results.concat(cross_trade_shipments(port_of_loading: params[:port_of_loading],
                                                port_of_destination: port_of_destination))
        end
      when 'truckload_purchase'
        places_of_delivery = params[:places_of_delivery]
        places_of_delivery.each do |place_of_delivery|
          @results.concat(truckload_freights(place_of_loading: params[:place_of_loading],
                                             place_of_delivery: place_of_delivery))
        end
      end
      respond_to do |format|
        format.html
        format.json { render json: { results: @results } }
      end
    # rescue => e
    #   flash[:alert] = 'Missing parameters: ' + e.to_s
    #   redirect_back fallback_location: purchases_path
    # end
  end

  private

  def fca_purchases(supplier:, place_of_loading:, place_of_delivery:, container_type: CONTAINER_TYPE_DEFAULT)
    # initialize results
    results = []
    # load data
    all_port_shippings = PortShipping.load
    all_drayage_shippings = DrayageShipping.load
    all_truck_shippings = TruckShipping.load
    all_ocean_shippings = OceanShipping.load
    # search all port_shippings results that match supplier and place_of_loading
    port_shippings = port_shippings(supplier: supplier,
                                    place_of_loading: place_of_loading,
                                    all_port_shippings: all_port_shippings)
    # seach after ocean freight shipping that match place_of_delivery
    after_ocean_shippings = after_ocean_shippings(place_of_delivery: place_of_delivery,
                                                  all_drayage_shippings: all_drayage_shippings,
                                                  all_truck_shippings: all_truck_shippings)
    # search all ocean_shipping that match any port_of_loading of selected port_shippings
    # and any port_of_destination of selected drayage_shippings
    port_shippings.each do |port_shipping|
      after_ocean_shippings.each do |after_ocean_shipping|
        ocean_shippings = ocean_shippings(all_ocean_shippings: all_ocean_shippings,
                                          port_of_loading: port_shipping.port_of_loading,
                                          port_of_destination: after_ocean_shipping[:port_of_destination],
                                          container_type: container_type)
        ocean_shippings.each do |ocean_shipping|
          # add each path to results
          results << merged_port_ocean_and_after_ocean_shippings(
            port_shipping: port_shipping,
            ocean_shipping: ocean_shipping,
            after_ocean_shipping: after_ocean_shipping
          )
        end
      end
    end
    # return results
    results
  end

  def cif_cfr_purchases(port_of_destination:, place_of_delivery:)
    # load data
    all_drayage_shippings = DrayageShipping.load
    all_truck_shippings = TruckShipping.load
    # search for all direct shippings with drayage only to ship to place of delivery from the port_of_destination
    results = direct_drayage_shippings(all_drayage_shippings: all_drayage_shippings,
                                       port_of_destination: port_of_destination,
                                       place_of_delivery: place_of_delivery)
    # search for all paths combining drayage and trucks shipping 
    # to arrive at place_of_deliver from the port_of_destination
    results.concat(both_drayage_and_truck_shippings(port_of_destination: port_of_destination,
                                                    place_of_delivery: place_of_delivery,
                                                    all_drayage_shippings: all_drayage_shippings,
                                                    all_truck_shippings: all_truck_shippings))
  end

  def fob_purchases(supplier:, place_of_delivery:, container_type: CONTAINER_TYPE_DEFAULT)
    # initialize results
    results = []
    # load data
    all_port_shippings = PortShipping.load
    all_drayage_shippings = DrayageShipping.load
    all_truck_shippings = TruckShipping.load
    all_ocean_shippings = OceanShipping.load
    # search all port_shippings results that match supplier and place_of_loading
    port_shippings = port_shippings(supplier: supplier, all_port_shippings: all_port_shippings)
    # seach after ocean freight shipping that match place_of_delivery
    after_ocean_shippings = after_ocean_shippings(place_of_delivery: place_of_delivery,
                                                  all_drayage_shippings: all_drayage_shippings,
                                                  all_truck_shippings: all_truck_shippings)
    # search all ocean_shipping that match any port_of_loading of selected port_shippings
    # and any port_of_destination of selected drayage_shippings
    port_shippings.each do |port_shipping|
      after_ocean_shippings.each do |after_ocean_shipping|
        ocean_shippings = ocean_shippings(all_ocean_shippings: all_ocean_shippings,
                                          port_of_loading: port_shipping.port_of_loading,
                                          port_of_destination: after_ocean_shipping[:port_of_destination],
                                          container_type: container_type)
        ocean_shippings.each do |ocean_shipping|
          # add each path to results
          results << merged_port_ocean_and_after_ocean_shippings_without_port_shipping_time_and_cost(
            port_shipping: port_shipping,
            ocean_shipping: ocean_shipping,
            after_ocean_shipping: after_ocean_shipping
          )
        end
      end
    end
    # return results
    results
  end

  def export_shipments(supplier:, place_of_loading:, port_of_destination:, container_type: CONTAINER_TYPE_DEFAULT)
    # initialize results
    results = []
    # load data
    all_port_shippings = PortShipping.load
    all_ocean_shippings = OceanShipping.load
    # search all port_shippings results that match supplier and place_of_loading
    port_shippings = port_shippings(supplier: supplier,
                                    place_of_loading: place_of_loading,
                                    all_port_shippings: all_port_shippings)
    # iterate on ports_shippings to find ocean_shippings that match
    port_shippings.each do |port_shipping|
      # search ocean_shippings that match with the port_of_loading of the port_shipping
      ocean_shippings = ocean_shippings(port_of_loading: port_shipping.port_of_loading,
                                        port_of_destination: port_of_destination,
                                        all_ocean_shippings: all_ocean_shippings,
                                        container_type: container_type)
      # iterate on ocean_shippings found to add a merge result to results
      ocean_shippings.each do |ocean_shipping|
        results << merged_port_and_ocean_shipping(port_shipping: port_shipping, ocean_shipping: ocean_shipping)
      end
    end
    # return results
    results
  end

  def cross_trade_shipments(port_of_loading:, port_of_destination:, container_type: CONTAINER_TYPE_DEFAULT)
    all_ocean_shippings = OceanShipping.load
    # search ocean_shippings that match the given port_of_loading, port_of_destination and container_type
    ocean_shippings = ocean_shippings(port_of_loading: port_of_loading,
                                      port_of_destination: port_of_destination,
                                      all_ocean_shippings: all_ocean_shippings,
                                      container_type: container_type)
    ocean_shippings.map { |shipping| convert_to_hash(shipping) }
  end

  def truckload_freights(place_of_loading:, place_of_delivery:)
    # search the truck_shippings that match given place_of_loading and place_of_delivery
    truck_shippings = TruckShipping.load.select do |shipping|
      shipping.place_of_loading == place_of_loading && shipping.place_of_delivery == place_of_delivery
    end
    truck_shippings.map { |shipping| convert_to_hash(shipping) }
  end

  def convert_to_hash(shipping)
    hash = {}
    shipping.instance_variables.each { |var| hash[var.to_s.delete("@")] = shipping.instance_variable_get(var) }
    hash
  end

  def ocean_shippings(port_of_loading:, port_of_destination:, all_ocean_shippings:, container_type:)
    all_ocean_shippings.select do |shipping|
      shipping.port_of_loading == port_of_loading &&
      shipping.port_of_destination == port_of_destination &&
      shipping.container_type == container_type
    end
  end

  def port_shippings(supplier:, all_port_shippings:, place_of_loading: nil)
    all_port_shippings.select do |shipping|
      if place_of_loading
        shipping.place_of_loading == place_of_loading && shipping.supplier == supplier
      else
        shipping.supplier == supplier
      end
    end
  end

  def after_ocean_shippings(place_of_delivery:, all_drayage_shippings:, all_truck_shippings:)
    # search direct drayage_shippings that match place_of_delivery
    # and are converted in a merged drayage+truck shipping
    direct_drayage_shippings = direct_drayage_shippings(place_of_delivery: place_of_delivery,
                                                        all_drayage_shippings: all_drayage_shippings)
    # search drayage_shippings+truck_shippings that match place_of_delivery
    both_drayage_and_truck_shippings = both_drayage_and_truck_shippings(place_of_delivery: place_of_delivery,
                                                                        all_drayage_shippings: all_drayage_shippings,
                                                                        all_truck_shippings: all_truck_shippings)
    # add drayage_and_truck_shippings to results of direct_drayage_shippings and return
    direct_drayage_shippings.concat(both_drayage_and_truck_shippings)
  end

  def direct_drayage_shippings(place_of_delivery:, all_drayage_shippings:, port_of_destination: nil)
    direct_drayage_shippings = all_drayage_shippings.select do |shipping|
      if port_of_destination
        shipping.port_of_destination == port_of_destination && shipping.place_of_delivery == place_of_delivery
      else
        shipping.place_of_delivery == place_of_delivery
      end
    end
    # harmonize format for direct drayage shipping with format for both drayage and truck shipping
    direct_drayage_shippings.map { |shipping| merged_drayage_and_truck_shippings(drayage_shipping: shipping) }
  end

  def both_drayage_and_truck_shippings(place_of_delivery:, all_drayage_shippings:, all_truck_shippings:, port_of_destination: nil)
    # initialize results
    results = []
    # find only truck_shipping that match place_of_delivery
    truck_shippings = all_truck_shippings.select { |shipping| shipping.place_of_delivery == place_of_delivery }
    # iterate on selected truck_shippings
    truck_shippings.each do |truck_shipping|
      # find drayage_shippings whose place_of-delivery match the place_of_loading of truck_shipping
      drayage_shippings = all_drayage_shippings.select do |drayage_shipping|
        if port_of_destination
          drayage_shipping.port_of_destination == port_of_destination && 
            drayage_shipping.place_of_delivery == truck_shipping.place_of_loading
        else
          drayage_shipping.place_of_delivery == truck_shipping.place_of_loading
        end
      end
      # iterate on all paths found to merge drayage and truck shippings in one format and add to results
      drayage_shippings.each do |drayage_shipping|
        results << merged_drayage_and_truck_shippings(drayage_shipping: drayage_shipping, truck_shipping: truck_shipping)
      end
    end
    # return results
    results
  end

  def merged_port_ocean_and_after_ocean_shippings(port_shipping:, ocean_shipping:, after_ocean_shipping:)
    calculated_time_and_cost(port_shipping, ocean_shipping, after_ocean_shipping)
      .merge(merged_port_ocean_after_ocean_shipping_except_time_and_cost(port_shipping: port_shipping,
                                                                         ocean_shipping: ocean_shipping,
                                                                         after_ocean_shipping: after_ocean_shipping))
  end

  def merged_port_ocean_and_after_ocean_shippings_without_port_shipping_time_and_cost(port_shipping:,
                                                                                      ocean_shipping:,
                                                                                      after_ocean_shipping:)
    calculated_time_and_cost(ocean_shipping, after_ocean_shipping)
      .merge(merged_port_ocean_after_ocean_shipping_except_time_and_cost(port_shipping: port_shipping,
                                                                         ocean_shipping: ocean_shipping,
                                                                         after_ocean_shipping: after_ocean_shipping))
  end

  def merged_port_ocean_after_ocean_shipping_except_time_and_cost(port_shipping:, ocean_shipping:, after_ocean_shipping:)
    {
      supplier: port_shipping.supplier,
      place_of_loading: port_shipping.place_of_loading,
      forwarder: port_shipping.forwarder,
      port_of_loading: port_shipping.port_of_loading,
      # port_of_loading_ocean: ocean_shipping.port_of_loading,
      carrier: ocean_shipping.carrier,
      country_of_origin: ocean_shipping.country_of_origin,
      country_of_destination: ocean_shipping.country_of_origin,
      container_type: ocean_shipping.container_type,
      expiry: ocean_shipping.expiry,
      port_of_destination: ocean_shipping.port_of_destination,
      max_gross_cargo_drayage: after_ocean_shipping[:max_gross_cargo_drayage],
      intermediate_place_of_loading: after_ocean_shipping[:intermediate_place_of_loading],
      trucker: after_ocean_shipping[:trucker],
      max_gross_cargo_truck: after_ocean_shipping[:max_gross_cargo_truck],
      place_of_delivery: after_ocean_shipping[:place_of_delivery]
    }
  end

  def merged_port_and_ocean_shipping(port_shipping:, ocean_shipping:)
    calculated_time_and_cost(ocean_shipping, port_shipping)
      .merge({
               supplier: port_shipping.supplier,
               place_of_loading: port_shipping.place_of_loading,
               forwarder: port_shipping.forwarder,
               port_of_loading: port_shipping.port_of_loading,
               carrier: ocean_shipping.carrier,
               country_of_origin: ocean_shipping.country_of_origin,
               country_of_destination: ocean_shipping.country_of_origin,
               container_type: ocean_shipping.container_type,
               expiry: ocean_shipping.expiry,
               port_of_destination: ocean_shipping.port_of_destination
            })
  end

  def merged_drayage_and_truck_shippings(drayage_shipping:, truck_shipping: nil)
    # if truck_shipping is not provided, create an empty one to make the merge
    truck_shipping ||= TruckShipping.new(transit_time: 0, currency: 'USD', cost: 0)
    # merge all data
    calculated_time_and_cost(drayage_shipping, truck_shipping)
      .merge({
               port_of_destination: drayage_shipping.port_of_destination,
               max_gross_cargo_drayage: drayage_shipping.max_gross_cargo,
               intermediate_place_of_loading: truck_shipping.place_of_loading,
               trucker: truck_shipping.trucker,
               max_gross_cargo_truck: truck_shipping.max_gross_cargo,
               place_of_delivery: truck_shipping.place_of_delivery || drayage_shipping.place_of_delivery
            })
  end

  def calculated_time_and_cost(*shippings)
    { transit_time: merged_transit_time(shippings) }.merge(merged_costs_and_currencies(shippings))
  end

  def merged_transit_time(shippings)
    # transit_timee are added
    result = shippings.reduce do |item1, item2|
      transit_time1 = item1.class == Hash ? item1[:transit_time] : item1.transit_time
      transit_time2 = item2.class == Hash ? item2[:transit_time] : item2.transit_time
      { transit_time: transit_time1 + transit_time2 }
    end
    result[:transit_time]
  end

  def merged_costs_and_currencies(shippings)
    # add costs only if they are in the same currency or return a string showing the 2 costs
    shippings.reduce do |item1, item2|
      cost1 = item1.class == Hash ? item1[:cost] : item1.cost
      cost2 = item2.class == Hash ? item2[:cost] : item2.cost
      currency1 = item1.class == Hash ? item1[:currency] : item1.currency
      currency2 = item2.class == Hash ? item2[:currency] : item2.currency
      if currency1 == currency2
        { cost: cost1 + cost2, currency: currency1 }
      else
        { cost: "#{cost1} + #{cost2}",
          currency: "#{currency1} + #{currency2}" }
      end
    end
  end
end