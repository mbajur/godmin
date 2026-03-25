require "godmin/helpers/application"
require "godmin/helpers/forms"
require "godmin/helpers/navigation"
require "godmin/helpers/translations"

module Godmin
  # Base controller class for all Godmin admin controllers.
  # All controllers inside module Godmin inherit from this class directly.
  class ApplicationController < ActionController::Base
    include Godmin::Helpers::Translations

    helper Godmin::Helpers::Application
    helper Godmin::Helpers::Forms
    helper Godmin::Helpers::Navigation
    helper Godmin::Helpers::Translations

    helper_method :authentication_enabled?
    helper_method :authorization_enabled?
    helper_method :engine_wrapper

    before_action :append_view_paths

    layout "godmin/application"

    def welcome; end

    private

    def engine_wrapper
      Godmin::EngineWrapper.new
    end

    def append_view_paths
      append_view_path Godmin::Resolver.resolvers(controller_path, engine_wrapper)
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
  end
end
