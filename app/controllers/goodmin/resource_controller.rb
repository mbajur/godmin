require "goodmin/helpers/batch_actions"

module Goodmin
  class ResourceController < ApplicationController
    include Goodmin::Resources::Resource::BatchActions

    helper Goodmin::Helpers::BatchActions
    helper Goodmin::Helpers::Filters
    helper Goodmin::Helpers::Tables

    before_action :set_resource_service
    before_action :set_resource_class
    before_action :set_resource_parents
    before_action :set_resources, only: :index
    before_action :handle_batch_action, only: :update, if: -> { params[:batch_action].present? }
    before_action :set_resource, only: [:show, :new, :edit, :create, :update, :destroy]

    def index
      respond_to do |format|
        format.html
        format.json
        format.csv
      end
    end

    def show
      respond_to do |format|
        format.html
        format.json
      end
    end

    def new; end

    def edit; end

    def create
      respond_to do |format|
        if @resource_service.create_resource(@resource)
          format.html { redirect_to redirect_after_create, notice: redirect_flash_message }
          format.json { render :show, status: :created, location: @resource }
        else
          format.html { render :edit }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @resource_service.update_resource(@resource, resource_params)
          format.html { redirect_to redirect_after_update, notice: redirect_flash_message }
          format.json { render :show, status: :ok, location: @resource }
        else
          format.html { render :edit }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @resource_service.destroy_resource(@resource)

      respond_to do |format|
        format.html { redirect_to redirect_after_destroy, notice: redirect_flash_message }
        format.json { head :no_content }
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

    def set_resources
      @resources = resources
      authorize(@resources) if authorization_enabled?
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

    def resource_params
      params.require(@resource_class.model_name.param_key.to_sym).permit(resource_params_defaults)
    end

    def resource_params_defaults
      @resource_service.attrs_for_form.map do |attribute|
        association = @resource_class.reflect_on_association(attribute.name)

        if association && association.macro == :belongs_to
          association.foreign_key.to_sym
        elsif association && (many_to_many_association?(association) || has_many_association?(association))
          { "#{attribute.name.to_s.singularize}_ids".to_sym => [] }
        elsif association && nested_attributes_accepted?(attribute.name)
          { "#{attribute.name}_attributes".to_sym => nested_attribute_permit_list(association) }
        else
          attribute.name
        end
      end
    end

    def nested_attributes_accepted?(attribute_name)
      @resource_class.method_defined?("#{attribute_name}_attributes=")
    end

    def nested_attribute_permit_list(association)
      service_class = Goodmin::ServiceLocator.find_service_class_for(association.klass, context_service_class: @resource_service.class)
      attrs = service_class&.attrs_for_form || []
      [:id] + attrs.map(&:name)
    end

    def many_to_many_association?(association)
      association.macro == :has_and_belongs_to_many ||
        (association.macro == :has_many && association.options[:through].present?)
    end

    def has_many_association?(association)
      association.macro == :has_many && !association.options[:through].present?
    end

    def redirect_after_create
      redirect_after_save
    end

    def redirect_after_update
      redirect_after_save
    end

    def redirect_after_save
      [*@resource_parents, @resource]
    end

    def redirect_after_destroy
      [*@resource_parents, resource_class.model_name.route_key.to_sym]
    end

    def redirect_flash_message
      translate_scoped("flash.#{action_name}", resource: @resource.class.model_name.human)
    end

    def handle_batch_action
      action = params[:batch_action].to_sym
      ids = params[:id].to_s.split(",")
      records = @resource_class.where(id: ids)

      @resource_service.batch_action(action, records)

      redirect_path = if respond_to?("redirect_after_batch_action_#{action}", true)
        send("redirect_after_batch_action_#{action}")
      else
        [*@resource_parents, @resource_class.model_name.route_key.to_sym]
      end

      redirect_to redirect_path
    end

    private

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
