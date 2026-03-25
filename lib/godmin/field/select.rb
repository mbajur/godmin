module Godmin
  module Field
    class Select < Base
      def collection
        col = options[:collection]
        return [] if col.nil?
        col.respond_to?(:call) ? col.call(record) : col
      end
    end
  end
end
