<% module_namespacing do -%>
class <%= class_name %>Resource
  include Godmin::Resources::Resource

  index do
<% @attributes.each do |x| -%>
    attribute :<%= x %>
<% end -%>
  end

  show do
<% @attributes.each do |x| -%>
    attribute :<%= x %>
<% end -%>
  end

  form do
<% @attributes.each do |x| -%>
    attribute :<%= x %>
<% end -%>
  end
end
<% end -%>
