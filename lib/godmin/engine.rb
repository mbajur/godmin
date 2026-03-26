module Godmin
  class Engine < ::Rails::Engine
    isolate_namespace Godmin

    initializer "godmin.autoload_paths", before: :set_autoload_paths do |app|
      godmin_app_dir = app.root.join("app/godmin")
      if godmin_app_dir.exist?
        Rails.autoloaders.main.push_dir(godmin_app_dir, namespace: Godmin)
        app.config.eager_load_paths << godmin_app_dir.to_s
      end
    end

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

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Godmin.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
