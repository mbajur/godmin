module Godmin
  module Field
    class Base
      attr_reader :attribute, :record, :resource_service

      def initialize(attribute:, record:, resource_service:)
        @attribute = attribute
        @record = record
        @resource_service = resource_service
      end

      def value
        record.public_send(attribute)
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
        name.demodulize.underscore
      end
    end
  end
end
