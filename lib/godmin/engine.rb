module Godmin
  class Engine < ::Rails::Engine
    initializer "godmin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("vendor/assets/javascripts")
      end
    end

    initializer "godmin.importmap", before: "importmap" do |app|
      Godmin.importmap.draw root.join("config/importmap.rb")
      Godmin.importmap.cache_sweeper watches: root.join("app/javascript")

      godmin_importmap = Rails.root.join("config/godmin_importmap.rb")
      if godmin_importmap.exist?
        Godmin.importmap.draw godmin_importmap
        Godmin.importmap.cache_sweeper watches: Rails.root.join("app/javascript")
      end

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Godmin.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
