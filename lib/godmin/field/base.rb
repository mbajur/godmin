module Godmin
  module Field
    class Base
      attr_reader :attribute, :record, :resource_service, :options

      def initialize(attribute:, record:, resource_service:, **options)
        @attribute = attribute
        @record = record
        @resource_service = resource_service
        @options = options
      end

      def value
        record.public_send(attribute)
      end

      def hint
        hint_option = options[:hint]
        result = if hint_option.is_a?(Proc)
          hint_option.call(record)
        elsif hint_option.present?
          hint_option
        else
          i18n_hint
        end
        result&.html_safe
      end

      def find_associated_service_class(klass)
        Godmin::ServiceLocator.find_service_class_for(klass, context_service_class: resource_service.class)
      end

      def self.partial_index
        "godmin/fields/#{field_type}/index"
      end

      def self.partial_show
        "godmin/fields/#{field_type}/show"
      end

      def self.partial_form
        "godmin/fields/#{field_type}/form"
      end

      private_class_method def self.field_type
        name.demodulize.delete_suffix("Field").underscore
      end

      private

      def i18n_hint
        model_key = record.class.model_name.i18n_key
        I18n.t("activerecord.hints.#{model_key}.#{attribute}", default: nil)
      end
    end
  end
end
