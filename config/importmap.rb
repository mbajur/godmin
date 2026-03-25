pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "godmin/application", to: "godmin/application.js", preload: true
pin_all_from Godmin::Engine.root.join("app/javascript/godmin/controllers"), under: "controllers", to: "godmin/controllers"

Rails::Engine.subclasses.reject { |e| e <= Godmin::Engine || e <= Rails::Application }.each do |engine|
  controllers_path = engine.root.join("app/javascript/godmin/controllers")
  pin_all_from controllers_path, under: "controllers", to: "godmin/controllers" if controllers_path.exist?
end

pin_all_from Rails.root.join("app/javascript/godmin/controllers"), under: "controllers", to: "godmin/controllers"
