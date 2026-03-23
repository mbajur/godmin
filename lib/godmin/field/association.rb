module Godmin
  module Field
    class Association < Base
      def belongs_to?
        macro == :belongs_to
      end

      def many_to_many?
        reflection = record.class.reflect_on_association(attribute)
        return false unless reflection
        reflection.macro == :has_and_belongs_to_many ||
          (reflection.macro == :has_many && reflection.options[:through].present?)
      end

      def has_many?
        return false unless reflection
        macro == :has_many && !many_to_many?
      end

      def select_attribute
        belongs_to? ? :"#{attribute}_id" : :"#{attribute.to_s.singularize}_ids"
      end

      def collection
        klass = reflection&.klass
        return [] unless klass

        if associated_service
          klass.all.map { |a| [display_name_for(a), a.id] }
        else
          method_name = resource_service.option_text_for_association(attribute)
          klass.all.map { |a| [a.public_send(method_name), a.id] }
        end
      end

      def display_name_for(associated_record)
        return nil unless associated_record
        service = associated_service
        service ? service.display_name(associated_record) : associated_record.to_s
      end

      def associated_service
        @associated_service ||= begin
          service_class = find_associated_service_class(reflection&.klass)
          service_class&.new
        rescue StandardError
          nil
        end
      end

      private

      def macro
        reflection&.macro
      end

      def reflection
        record.class.reflect_on_association(attribute)
      end
    end
  end
end
