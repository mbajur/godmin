require "importmap-rails"
require "stimulus-rails"
require "bootstrap_form"
require "csv_builder"
require "godmin/application_controller"
require "godmin/authentication"
require "godmin/authorization"
require "godmin/engine"
require "godmin/engine_wrapper"
require "godmin/service_locator"
require "godmin/field/base"
require "godmin/field/string"
require "godmin/field/text"
require "godmin/field/boolean"
require "godmin/field/date"
require "godmin/field/date_time"
require "godmin/field/number"
require "godmin/field/association"
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
require "godmin/version"

module Godmin
end

Godmin::Resources::FormBuilder.register_component(:row, Godmin::Resources::FormComponents::Row)
Godmin::Resources::FormBuilder.register_component(:col, Godmin::Resources::FormComponents::Col)
Godmin::Resources::FormBuilder.register_component(:section, Godmin::Resources::FormComponents::Section)
