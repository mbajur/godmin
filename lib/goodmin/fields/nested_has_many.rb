module Goodmin
  module Fields
    class NestedHasMany < Base
      def associated_records
        record.public_send(attribute)
      end

      def new_record
        @new_record ||= associated_model_class&.new
      end

      def associated_service
        @associated_service ||= associated_service_class&.new
      end

      def nested_form_nodes
        associated_service&.form_nodes || []
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
