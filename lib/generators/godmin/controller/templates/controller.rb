<% if namespaced? -%>
require_dependency "<%= namespaced_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= class_name %>Controller < ApplicationController
  include Godmin::Resource

  def attrs_for_index
    <%= @attributes.map(&:name).map(&:to_sym) %>
  end

  def attrs_for_form
    <%= @attributes.map(&:name).map(&:to_sym) %>
  end
end
<% end -%>
