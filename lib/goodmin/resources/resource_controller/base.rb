require "goodmin/helpers/batch_actions"
require "goodmin/helpers/filters"
require "goodmin/helpers/tables"
require "goodmin/resources/resource_controller/batch_actions"

module Goodmin
  module Resources
    module ResourceController
      module Base
        extend ActiveSupport::Concern

        include BatchActions

        included do
          helper Goodmin::Helpers::BatchActions
          helper Goodmin::Helpers::Filters
          helper Goodmin::Helpers::Tables

          before_action :set_resource_service
          before_action :set_resource_class
          before_action :set_resource_parents
          before_action :set_resource, only: [:show, :new, :edit, :create, :update, :destroy]

          helper_method :resource_url_array, :resources_url_array, :new_button_visible?
        end

        def show
          respond_to do |format|
            format.html
            format.json
            format.turbo_stream
          end
        end

        def new; end

        def edit; end

        def create
          respond_to do |format|
            if @resource_service.create_resource(@resource)
              format.html { html_response_after_create }
              format.json { render :show, status: :created, location: @resource }
              format.turbo_stream { turbo_stream_response_after_create }
            else
              format.html { html_response_after_create_failure }
              format.json { render json: @resource.errors, status: :unprocessable_entity }
              format.turbo_stream { turbo_stream_response_after_create_failure }
            end
          end
        end

        def update
          respond_to do |format|
            if @resource_service.update_resource(@resource, resource_params)
              format.html { html_response_after_update }
              format.json { render :show, status: :ok, location: @resource }
              format.turbo_stream { turbo_stream_response_after_update }
            else
              format.html { html_response_after_update_failure }
              format.json { render json: @resource.errors, status: :unprocessable_entity }
              format.turbo_stream { turbo_stream_response_after_update_failure }
            end
          end
        end

        def destroy
          @resource_service.destroy_resource(@resource)

          respond_to do |format|
            format.html { html_response_after_destroy }
            format.json { head :no_content }
            format.turbo_stream { turbo_stream_response_after_destroy }
          end
        end

        protected

        def set_resource_service
          @resource_service = resource_service
        end

        def set_resource_class
          @resource_class = resource_class
        end

        def set_resource_parents
          @resource_parents = resource_parents
        end

        def set_resource
          @resource = resource
          authorize(@resource) if authorization_enabled?
        end

        def resource_service_class
          resource_name = controller_path.split("/").last.singularize.classify
          "Goodmin::Resources::#{resource_name}Resource".constantize
        end

        def resource_service
          resource_service = resource_service_class.new

          if authentication_enabled?
            resource_service.options[:admin_user] = admin_user
          end

          if resource_parents.present?
            resource_service.options[:resource_parent] = resource_parents.last
          end

          resource_service
        end

        def resource_class
          @resource_service.resource_class
        end

        def resource_parents
          params.to_unsafe_h.each_with_object([]) do |(name, value), parents|
            if name =~ /(.+)_id$/
              parents << $1.classify.constantize.find(value)
            end
          end
        end

        def resource_params
          params.require(@resource_class.model_name.param_key.to_sym).permit(resource_params_defaults)
        end

        def resource_params_defaults
          record = @resource || @resource_class.new
          @resource_service.attrs_for_form.map do |attribute|
            if array_attribute?(attribute.name)
              { attribute.name => [] }
            else
              field = attribute.to_field(record: record, resource_service: @resource_service)
              field.permitted_attribute
            end
          end
        end

        def array_attribute?(attr_name)
          return false unless @resource_class.respond_to?(:attribute_types)

          attr_type = @resource_class.attribute_types[attr_name.to_s]
          serialized_array = (attr_type.respond_to?(:object_type) && attr_type.object_type == Array) ||
            (attr_type.respond_to?(:coder) && attr_type.coder.respond_to?(:object_class) && attr_type.coder.object_class == Array)
          native_array = if @resource_class.respond_to?(:column_for_attribute)
            column = @resource_class.column_for_attribute(attr_name)
            column.respond_to?(:array?) && column.array?
          else
            false
          end
          serialized_array || native_array
        end

        def html_response_after_create
          redirect_to redirect_after_create, notice: redirect_flash_message
        end

        def html_response_after_create_failure
          render :new
        end

        def html_response_after_update
          redirect_to redirect_after_update, notice: redirect_flash_message
        end

        def html_response_after_update_failure
          render :edit
        end

        def html_response_after_destroy
          redirect_to redirect_after_destroy, notice: redirect_flash_message
        end

        def turbo_stream_response_after_create
          redirect_to redirect_after_create, notice: redirect_flash_message
        end

        def turbo_stream_response_after_create_failure
          render :create, status: :unprocessable_entity
        end

        def turbo_stream_response_after_update
          redirect_to redirect_after_update, notice: redirect_flash_message
        end

        def turbo_stream_response_after_update_failure
          render :update, status: :unprocessable_entity
        end

        def turbo_stream_response_after_destroy
          render turbo_stream: turbo_stream.remove(dom_id(@resource))
        end

        def redirect_after_create
          redirect_after_save
        end

        def redirect_after_update
          redirect_after_save
        end

        def redirect_after_save
          resource_url_array
        end

        def redirect_after_destroy
          resources_url_array
        end

        def redirect_flash_message
          translate_scoped("flash.#{action_name}", resource: @resource.class.model_name.human)
        end
      end
    end
  end
end
