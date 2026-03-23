module Admin
  class Engine < ::Rails::Engine
    isolate_namespace Admin

    initializer "admin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/assets/javascripts")
      end
    end
  end
end
