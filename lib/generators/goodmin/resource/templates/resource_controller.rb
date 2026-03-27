<% if namespaced? -%>
<% module_namespacing do -%>
class <%= class_name.pluralize %>Controller < Goodmin::BaseController
  include Goodmin::Resources::ResourceController
end
<% end -%>
<% else -%>
module Goodmin
  class <%= class_name.pluralize %>Controller < Goodmin::BaseController
    include Goodmin::Resources::ResourceController
  end
end
<% end -%>
