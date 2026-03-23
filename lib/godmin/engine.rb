module Godmin
  class Engine < ::Rails::Engine
    initializer "godmin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/assets/javascripts")
        app.config.assets.paths << root.join("vendor/assets/javascripts")
      end
    end
  end
end
