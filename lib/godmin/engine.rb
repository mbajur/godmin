module Godmin
  class Engine < ::Rails::Engine
    initializer "godmin.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.paths << root.join("vendor/assets/javascripts")

        Rails::Engine.subclasses.reject { |e| e <= Godmin::Engine || e <= Rails::Application }.each do |engine|
          js_path = engine.root.join("app/javascript")
          app.config.assets.paths << js_path if js_path.exist?
        end
      end
    end

    initializer "godmin.importmap", before: "importmap" do |app|
      Godmin.importmap.draw root.join("config/importmap.rb")
      Godmin.importmap.cache_sweeper watches: root.join("app/javascript")

      Rails::Engine.subclasses.reject { |e| e <= Godmin::Engine || e <= Rails::Application }.each do |engine|
        js_path = engine.root.join("app/javascript")
        Godmin.importmap.cache_sweeper watches: js_path if js_path.exist?
      end

      ActiveSupport.on_load(:action_controller_base) do
        before_action { Godmin.importmap.cache_sweeper.execute_if_updated }
      end
    end
  end
end
