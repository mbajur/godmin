require "goodmin/resources/resource_controller/base"

module Goodmin
  module Resources
    module ResourceController
      extend ActiveSupport::Concern

      include Base

      included do
        before_action :set_resources, only: :index
      end

      def index
        respond_to do |format|
          format.html
          format.json
          format.csv
          format.turbo_stream
        end
      end

      protected

      def set_resources
        @resources = resources
        authorize(@resources) if authorization_enabled?
      end

      def resources
        @resource_service.resources(params)
      end

      def resource
        if params[:id]
          @resource_service.find_resource(params[:id])
        else
          case action_name
          when "create"
            @resource_service.build_resource(resource_params)
          when "new"
            @resource_service.build_resource(nil)
          end
        end
      end

      def new_button_visible?
        if authorization_enabled?
          policy(@resource_service.build_resource({})).new?
        else
          true
        end
      end

      def resource_url_array(action: nil)
        [action, *@resource_parents, @resource].compact
      end

      def resources_url_array
        [*@resource_parents, resource_class.model_name.route_key.to_sym]
      end
    end
  end
end
