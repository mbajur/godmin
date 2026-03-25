module Godmin
  module Field
    class Enum < Select
      def self.partial_form
        Field::Select.partial_form
      end

      def collection
        (record.class.defined_enums[attribute.to_s] || {}).keys.map do |key|
          [key.humanize, key]
        end
      end
    end
  end
end
