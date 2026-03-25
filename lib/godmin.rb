require "importmap-rails"
require "stimulus-rails"
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
require "godmin/resources/form_components/tab"
require "godmin/version"

module Godmin
  mattr_accessor :importmap, default: Importmap::Map.new

  # Draw an additional importmap file into Godmin's importmap and optionally
  # register a JavaScript path for the cache sweeper.
  #
  # Call this from your engine's or application's initializer:
  #
  #   initializer "admin.importmap", after: "godmin.importmap" do |app|
  #     Godmin.draw_importmap Admin::Engine.root.join("config/godmin_importmap.rb"),
  #                           js_path: Admin::Engine.root.join("app/javascript")
  #     app.config.assets.paths << Admin::Engine.root.join("app/javascript") if app.config.respond_to?(:assets)
  #   end
  def self.draw_importmap(path, js_path: nil)
    importmap.draw(path)
    importmap.cache_sweeper(watches: js_path) if js_path
  end
end

Godmin::Resources::FormBuilder.register_component(:row, Godmin::Resources::FormComponents::Row)
Godmin::Resources::FormBuilder.register_component(:col, Godmin::Resources::FormComponents::Col)
Godmin::Resources::FormBuilder.register_component(:section, Godmin::Resources::FormComponents::Section)
Godmin::Resources::FormBuilder.register_component(:tab, Godmin::Resources::FormComponents::Tab)
