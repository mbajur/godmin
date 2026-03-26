require "importmap-rails"
require "stimulus-rails"
require "csv_builder"
require "goodmin/authentication"
require "goodmin/authorization"
require "goodmin/engine"
require "goodmin/service_locator"
require "goodmin/fields/base"
require "goodmin/fields/string"
require "goodmin/fields/password"
require "goodmin/fields/text"
require "goodmin/fields/boolean"
require "goodmin/fields/date"
require "goodmin/fields/date_time"
require "goodmin/fields/number"
require "goodmin/fields/association"
require "goodmin/fields/select"
require "goodmin/fields/enum"
require "goodmin/fields/nested_has_one"
require "goodmin/paginator"
require "goodmin/resolver"
require "goodmin/helpers/application"
require "goodmin/helpers/forms"
require "goodmin/helpers/navigation"
require "goodmin/helpers/translations"
require "goodmin/helpers/filters"
require "goodmin/helpers/tables"
require "goodmin/resources/resource"
require "goodmin/resources/resource_service"
require "goodmin/resources/form_component"
require "goodmin/resources/form_components/row"
require "goodmin/resources/form_components/col"
require "goodmin/resources/form_components/section"
require "goodmin/resources/form_components/tab"
require "goodmin/version"

module Goodmin
  mattr_accessor :importmap, default: Importmap::Map.new
end

Goodmin::Resources::FormBuilder.register_component(:row, Goodmin::Resources::FormComponents::Row)
Goodmin::Resources::FormBuilder.register_component(:col, Goodmin::Resources::FormComponents::Col)
Goodmin::Resources::FormBuilder.register_component(:section, Goodmin::Resources::FormComponents::Section)
Goodmin::Resources::FormBuilder.register_component(:tab, Goodmin::Resources::FormComponents::Tab)
