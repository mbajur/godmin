require "importmap-rails"
require "stimulus-rails"
require "csv_builder"
require "godmin/authentication"
require "godmin/authorization"
require "godmin/engine"
require "godmin/service_locator"
require "godmin/fields/base"
require "godmin/fields/string"
require "godmin/fields/password"
require "godmin/fields/text"
require "godmin/fields/boolean"
require "godmin/fields/date"
require "godmin/fields/date_time"
require "godmin/fields/number"
require "godmin/fields/association"
require "godmin/fields/select"
require "godmin/fields/enum"
require "godmin/fields/nested_has_one"
require "godmin/paginator"
require "godmin/resolver"
require "godmin/helpers/application"
require "godmin/helpers/forms"
require "godmin/helpers/navigation"
require "godmin/helpers/translations"
require "godmin/helpers/filters"
require "godmin/helpers/tables"
require "godmin/resources/resource"
require "godmin/resources/resource_service"
require "godmin/resources/form_component"
require "godmin/resources/form_components/row"
require "godmin/resources/form_components/col"
require "godmin/resources/form_components/section"
require "godmin/resources/form_components/tab"
require "godmin/version"

module Godmin
  mattr_accessor :importmap, default: Importmap::Map.new
end

Godmin::Resources::FormBuilder.register_component(:row, Godmin::Resources::FormComponents::Row)
Godmin::Resources::FormBuilder.register_component(:col, Godmin::Resources::FormComponents::Col)
Godmin::Resources::FormBuilder.register_component(:section, Godmin::Resources::FormComponents::Section)
Godmin::Resources::FormBuilder.register_component(:tab, Godmin::Resources::FormComponents::Tab)
