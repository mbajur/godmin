module Godmin
  module Field
    class Select < Base
      def collection
        col = options[:collection]
        return [] if col.nil?
        col.respond_to?(:call) ? col.call(record) : col
      end

      def select_options
        options.fetch(:options, {})
      end

      def select_html_options
        { class: "form-control" }.merge(options.fetch(:html_options, {}))
      end
    end
  end
end
