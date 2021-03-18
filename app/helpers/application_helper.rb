module ApplicationHelper
  def is_home
    currentpage_belongs_to?([['pages', 'home']])
  end

  def currentpage_belongs_to?(arrays_of_pages)
    arrays_of_pages.find do |controller_action|
      controller_name == controller_action[0] && action_name == controller_action[1]
    end
  end

  def important_column(key)
    [:transit_time, :cost, :currency, 'transit_time', 'cost', 'currency'].include?(key)
  end

  def place_column(key)
    [
      :place_of_loading,
      :port_of_loading,
      :port_of_destination,
      :place_of_delivery,
      :intermediate_place_of_loading,
      'place_of_loading',
      'port_of_loading',
      'port_of_destination',
      'place_of_delivery',
      'intermediate_place_of_loading'
    ].include?(key)
  end
end
