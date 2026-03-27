module Goodmin
  module Resources
    module ResourceController
      module Singleton
        extend ActiveSupport::Concern

        def singleton_resource?
          true
        end

        def resource
          case action_name
          when "create"
            @resource_service.build_resource(resource_params)
          when "new"
            @resource_service.build_resource(nil)
          else
            @resource_service.find_singleton_resource
          end
        end

        def resource_url_array(action: nil)
          [action, *@resource_parents, resource_class.model_name.singular_route_key.to_sym].compact
        end

        def resources_url_array
          resource_url_array
        end
      end
    end
  end
end
