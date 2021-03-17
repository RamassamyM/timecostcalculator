module ApplicationHelper
  def is_home
    currentpage_belongs_to?([['pages', 'home']])
  end

  def currentpage_belongs_to?(arrays_of_pages)
    arrays_of_pages.find do |controller_action|
      controller_name == controller_action[0] && action_name == controller_action[1]
    end
  end
end