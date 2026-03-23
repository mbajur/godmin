module Godmin
  module Field
    class NestedHasOne < Base
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

      private

      def reflection
        record.class.reflect_on_association(attribute)
      end

      def associated_model_class
        reflection&.klass
      end

      def associated_service_class
        return nil unless associated_model_class

        "#{associated_model_class.name}Service".safe_constantize
      end
    end
  end
end
