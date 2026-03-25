require "godmin/generators/base"

module Godmin
  module Generators
    class NamedBase < Base
      argument :name, type: :string

      private

      def class_name
        @_class_name ||= name.classify
      end

      def class_path
        @_class_path ||= name.classify.deconstantize.split("::").map(&:underscore)
      end

      def file_name
        @_file_name ||= class_name.demodulize.underscore
      end
    end
  end
end
