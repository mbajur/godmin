module Godmin
  # Godmin operates exclusively as a mounted engine (Godmin::Engine) inside the
  # host application. Controllers always live under the Godmin namespace and user
  # view overrides always live in the host app.
  class EngineWrapper
    def namespace
      Godmin
    end

    def namespaced?
      true
    end

    def namespaced_path
      ["godmin"]
    end

    # User view overrides always live in the host application, not inside the gem.
    def root
      Rails.application.root
    end
  end
end
