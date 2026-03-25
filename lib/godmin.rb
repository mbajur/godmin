require "importmap-rails"
require "stimulus-rails"
require "csv_builder"
require "godmin/authentication"
require "godmin/authorization"
require "godmin/engine"
require "godmin/helpers/application"
require "godmin/helpers/batch_actions"
require "godmin/helpers/filters"
require "godmin/helpers/forms"
require "godmin/helpers/navigation"
require "godmin/helpers/tables"
require "godmin/helpers/translations"
require "godmin/service_locator"
require "godmin/field/base"
require "godmin/field/string"
require "godmin/field/password"
require "godmin/field/text"
require "godmin/field/boolean"
require "godmin/field/date"
require "godmin/field/date_time"
require "godmin/field/number"
require "godmin/field/association"
require "godmin/field/select"
require "godmin/field/enum"
require "godmin/field/nested_has_one"
require "godmin/paginator"
require "godmin/resolver"
require "godmin/resources/resource_controller"
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
