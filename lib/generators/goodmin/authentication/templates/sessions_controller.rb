<% if namespaced? -%>
require_dependency "<%= File.join(namespaced_path, "application_controller") %>"

<% end -%>
<% module_namespacing do -%>
class SessionsController < ApplicationController
  include Goodmin::Authentication::SessionsController
end
<% end -%>
