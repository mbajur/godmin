<% module_namespacing do -%>
class <%= class_name.pluralize %>Controller < Goodmin::BaseController
  include Goodmin::Resources::ResourceController
end
<% end -%>
