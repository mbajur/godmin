module Godmin
  class ApplicationController < ActionController::Base
    include Godmin::Helpers::Translations

    helper Godmin::Helpers::Application
    helper Godmin::Helpers::Forms
    helper Godmin::Helpers::Navigation
    helper Godmin::Helpers::Translations

    helper_method :authentication_enabled?
    helper_method :authorization_enabled?

    before_action :append_view_paths

    layout "godmin/application"

    def welcome; end

    protected

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
  end
end
