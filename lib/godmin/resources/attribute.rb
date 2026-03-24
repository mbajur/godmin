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

        if record.class.respond_to?(:reflect_on_association) && record.class.reflect_on_association(name)
          Field::Association
        elsif record.class.respond_to?(:has_attribute?) && record.class.has_attribute?(name.to_s)
          column = record.class.column_for_attribute(name)
          case column.type
          when :text then Field::Text
          when :boolean then Field::Boolean
          when :date then Field::Date
          when :datetime, :timestamp then Field::DateTime
          when :integer, :float, :decimal then Field::Number
          else Field::String
          end
        else
          Field::String
        end
      end
    end
  end
end
