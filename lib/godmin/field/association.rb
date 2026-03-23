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

      def select_attribute
        belongs_to? ? :"#{attribute}_id" : :"#{attribute.to_s.singularize}_ids"
      end

      def collection
        klass = reflection&.klass
        return [] unless klass

        service_class = "#{klass.name}Service".safe_constantize
        if service_class
          service = service_class.new
          klass.all.map { |a| [service.display_name(a), a.id] }
        else
          method_name = resource_service.option_text_for_association(attribute)
          klass.all.map { |a| [a.public_send(method_name), a.id] }
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
