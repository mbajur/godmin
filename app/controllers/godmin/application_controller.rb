module Godmin
  # Base controller class for all Godmin admin controllers.
  # All controllers inside module Godmin inherit from this class directly.
  class ApplicationController < ActionController::Base
    include Godmin::Helpers::Translations

    protect_from_forgery with: :exception

    helper Godmin::Helpers::Application
    helper Godmin::Helpers::Forms
    helper Godmin::Helpers::Navigation
    helper Godmin::Helpers::Translations

    helper_method :authentication_enabled?
    helper_method :authorization_enabled?
    helper_method :godmin_root_path
    helper_method :godmin_sign_in_path
    helper_method :godmin_session_path

    before_action :append_view_paths

    layout "godmin/application"

    def welcome; end

    private

    def append_view_paths
      append_view_path Godmin::Resolver.resolvers(controller_path)
    end

    def disable_authentication
      @_disable_authentication = true
    end

    def disable_authorization
      @_disable_authorization = true
    end

    def authentication_enabled?
      !@_disable_authentication && singleton_class.include?(Godmin::Authentication)
    end

    def authorization_enabled?
      !@_disable_authorization && singleton_class.include?(Godmin::Authorization)
    end

    # Returns the path to the Godmin admin root page.
    # Override in your application controller when using namespace routing, e.g.:
    #   def godmin_root_path = main_app.admin_root_path
    # NOTE: When namespace routing is used (engine has no routes), falls back to the main
    # application root. Override this method for a proper admin-section root link.
    def godmin_root_path
      Godmin::Engine.routes.routes.any? ? root_path : main_app.root_path
    end

    # Returns the path to the Godmin sign-in page.
    # Override in your application controller when using namespace routing, e.g.:
    #   def godmin_sign_in_path = main_app.new_admin_session_path
    def godmin_sign_in_path
      Godmin::Engine.routes.routes.any? ? new_session_path : "/"
    end

    # Returns the path to the Godmin session resource (used for sign-out).
    # Override in your application controller when using namespace routing, e.g.:
    #   def godmin_session_path = main_app.admin_session_path
    def godmin_session_path
      Godmin::Engine.routes.routes.any? ? session_path : "/"
    end
  end
end
