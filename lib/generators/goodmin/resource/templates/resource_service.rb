<% module_namespacing do -%>
class <%= class_name %>Service
  include Goodmin::Resources::ResourceService

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
