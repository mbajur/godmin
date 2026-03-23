require "godmin/resources/attribute"
require "godmin/resources/resource_service/associations"
require "godmin/resources/resource_service/batch_actions"
require "godmin/resources/resource_service/filters"
require "godmin/resources/resource_service/ordering"
require "godmin/resources/resource_service/pagination"
require "godmin/resources/resource_service/scopes"

module Godmin
  module Resources
    module ResourceService
      extend ActiveSupport::Concern

      class AttributeBuilder
        attr_reader :attributes

        def initialize
          @attributes = []
        end

        def attribute(name, field: nil)
          @attributes << Attribute.new(name, field_class: field)
        end
      end

      include Associations
      include BatchActions
      include Filters
      include Ordering
      include Pagination
      include Scopes

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def resource_class
        self.class.name.chomp("Service").constantize
      end

      def resources_relation
        if options[:resource_parent].present?
          parent = options[:resource_parent]
          association_name = resource_class.name.underscore.pluralize.to_sym
          reflection = parent.class.reflect_on_association(association_name)

          if reflection && (reflection.macro == :has_and_belongs_to_many ||
              (reflection.macro == :has_many && reflection.options[:through].present?))
            parent.send(association_name)
          else
            resource_class.where(parent.class.name.underscore => parent)
          end
        else
          resource_class.all
        end
      end

      def resources(params)
        apply_pagination(
          params[:page], apply_order(
            params[:order], apply_filters(
              params[:filter], apply_scope(
                params[:scope], resources_relation
              )
            )
          )
        )
      end

      def find_resource(id)
        resources_relation.find(id)
      end

      def build_resource(params)
        resources_relation.new(params)
      end

      def create_resource(resource)
        resource.save
      end

      def update_resource(resource, params)
        resource.update(params)
      end

      def destroy_resource(resource)
        resource.destroy
      end

      def attrs_for_index
        self.class.attrs_for_index
      end

      def attrs_for_show
        self.class.attrs_for_show
      end

      def attrs_for_form
        self.class.attrs_for_form
      end

      def attrs_for_export
        self.class.attrs_for_export
      end

      def display_name(record)
        record.to_s
      end

      def option_text_for_association(attribute)
        self.class.association_option_texts[attribute] || :to_s
      end

      module ClassMethods
        def index(&block)
          if block_given?
            builder = AttributeBuilder.new
            builder.instance_eval(&block)
            @attrs_for_index = builder.attributes
          end
          @attrs_for_index || []
        end

        def show(&block)
          if block_given?
            builder = AttributeBuilder.new
            builder.instance_eval(&block)
            @attrs_for_show = builder.attributes
          end
          @attrs_for_show || []
        end

        def form(&block)
          if block_given?
            builder = AttributeBuilder.new
            builder.instance_eval(&block)
            @attrs_for_form = builder.attributes
          end
          @attrs_for_form || []
        end

        def export(&block)
          if block_given?
            builder = AttributeBuilder.new
            builder.instance_eval(&block)
            @attrs_for_export = builder.attributes
          end
          @attrs_for_export || []
        end

        def attrs_for_index
          @attrs_for_index || []
        end

        def attrs_for_show
          @attrs_for_show || []
        end

        def attrs_for_form
          @attrs_for_form || []
        end

        def attrs_for_export
          @attrs_for_export || []
        end

        def association_option_text(attribute, method_name)
          @association_option_texts ||= {}
          @association_option_texts[attribute] = method_name
        end

        def association_option_texts
          @association_option_texts || {}
        end
      end
    end
  end
end
