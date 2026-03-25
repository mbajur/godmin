require "active_support/all"

module Godmin
  module Generators
    class Base < Rails::Generators::Base
      def self.source_paths
        %w[authentication install policy resource].map do |path|
          File.expand_path("../../../generators/godmin/#{path}/templates", __FILE__)
        end
      end

      private

      # All Godmin files live under the godmin/ namespace in the host application.
      def admin_path
        ["godmin"]
      end

      def indent(content, multiplier = 2)
        spaces = " " * multiplier
        content.each_line.map { |line| line.blank? ? line : "#{spaces}#{line}" }.join
      end

      def wrap_with_godmin_namespace(content)
        content = indent(content).chomp
        "module Godmin\n#{content}\nend\n"
      end
    end
  end
end
