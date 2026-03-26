module Goodmin
  class Engine < ::Rails::Engine
    isolate_namespace Goodmin

    initializer "goodmin.autoload_paths", before: :set_autoload_paths do |app|
      goodmin_app_dir = app.root.join("app/goodmin")
      if goodmin_app_dir.exist?
        Rails.autoloaders.main.push_dir(goodmin_app_dir, namespace: Goodmin)
        app.config.eager_load_paths << goodmin_app_dir.to_s
      end
    end

    initializer "goodmin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("vendor/assets/javascripts")
      end
    end

    initializer "goodmin.importmap", before: "importmap" do |app|
      Goodmin.importmap.draw root.join("config/importmap.rb")
      Goodmin.importmap.cache_sweeper watches: root.join("app/javascript")

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Goodmin.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
