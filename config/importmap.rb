pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "godmin/application", to: "godmin/application.js", preload: true
pin_all_from Godmin::Engine.root.join("app/javascript/godmin/controllers"), under: "controllers", to: "godmin/controllers"
