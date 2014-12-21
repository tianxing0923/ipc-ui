module ApplicationHelper
  def active_class name, expected_name, active_name = 'active'
    name == expected_name ? active_name : ''
  end
end
