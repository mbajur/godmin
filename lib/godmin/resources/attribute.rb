module Godmin
  module Resources
    class Attribute
      attr_reader :name, :field_class, :options

      def initialize(name, field_class: nil, **options)
        @name = name
        @field_class = field_class
        @options = options
      end

      def to_field(record:, resource_service:)
        resolved_field_class(record).new(
          attribute: name,
          record: record,
          resource_service: resource_service,
          **options
        )
      end

      private

      def resolved_field_class(record)
        return field_class if field_class

        if record.class.respond_to?(:reflect_on_association) && (reflection = record.class.reflect_on_association(name))
          reflection.macro == :has_one ? Fields::NestedHasOne : Fields::Association
        elsif record.class.respond_to?(:defined_enums) && record.class.defined_enums.key?(name.to_s)
          Fields::Enum
        elsif record.class.respond_to?(:has_attribute?) && record.class.has_attribute?(name.to_s)
          column = record.class.column_for_attribute(name)
          case column.type
          when :text then Fields::Text
          when :boolean then Fields::Boolean
          when :date then Fields::Date
          when :datetime, :timestamp then Fields::DateTime
          when :integer, :float, :decimal then Fields::Number
          else Fields::String
          end
        else
          Fields::String
        end
      end
    end
  end
end
