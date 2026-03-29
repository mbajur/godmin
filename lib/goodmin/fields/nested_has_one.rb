module Goodmin
  module Fields
    class NestedHasOne < BaseNested

      def associated_record
        @associated_record ||= begin
          existing = record.public_send(attribute)
          return existing if existing

          build_method = :"build_#{attribute}"
          record.public_send(build_method) if record.respond_to?(build_method)
        end
      end

      def associated_service
        @associated_service ||= associated_service_class&.new
      end

      def nested_attributes
        associated_service&.attrs_for_form || []
      end

      def nested_form_nodes
        associated_service&.form_nodes || []
      end

      protected

      def nested_record_instance
        associated_model_class&.new
      end

      private

      def reflection
        record.class.reflect_on_association(attribute)
      end

      def associated_model_class
        reflection&.klass
      end

      def associated_service_class
        find_associated_service_class(associated_model_class)
      end
    end
  end
end
