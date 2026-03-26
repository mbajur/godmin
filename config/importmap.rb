pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin "goodmin/application", to: "goodmin/application.js", preload: true
pin_all_from Goodmin::Engine.root.join("app/javascript/goodmin/controllers"), under: "controllers", to: "goodmin/controllers"
