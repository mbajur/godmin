module Goodmin
  class ApplicationController < ActionController::Base
    include Goodmin::Helpers::Translations

    helper Goodmin::Helpers::Application
    helper Goodmin::Helpers::Forms
    helper Goodmin::Helpers::Navigation
    helper Goodmin::Helpers::Translations

    helper_method :authentication_enabled?
    helper_method :authorization_enabled?

    before_action :append_view_paths

    layout "goodmin/application"

    def welcome; end

    protected

    private

    def append_view_paths
      append_view_path Goodmin::Resolver.resolvers(controller_path)
    end

    def disable_authentication
      @_disable_authentication = true
    end

    def disable_authorization
      @_disable_authorization = true
    end

    def authentication_enabled?
      !@_disable_authentication && singleton_class.include?(Goodmin::Authentication)
    end

    def authorization_enabled?
      !@_disable_authorization && singleton_class.include?(Goodmin::Authorization)
    end
  end
end
