module Godmin
  module Field
    class Enum < Base
      def collection
        (record.class.defined_enums[attribute.to_s] || {}).keys.map do |key|
          [key.humanize, key]
        end
      end
    end
  end
end
