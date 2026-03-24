pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "godmin/application", to: "godmin/application.js", preload: true
pin_all_from Godmin::Engine.root.join("app/assets/javascripts/godmin/controllers"), under: "controllers", to: "godmin/controllers"
pin_all_from Rails.root.join("app/assets/javascripts/godmin/controllers"), under: "controllers", to: "godmin/controllers"
