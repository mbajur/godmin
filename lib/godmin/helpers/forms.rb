module Godmin
  module Helpers
    module Forms
      def form_for(record, options = {}, &block)
        super(record, {
          url: [*@resource_parents, record],
          builder: FormBuilders::FormBuilder,
          inline_errors: false
        }.merge(options), &block)
      end
    end
  end

  module FormBuilders
    class FormBuilder < BootstrapForm::FormBuilder
      def input(attribute, options = {})
        case attribute_type(attribute)
        when :text
          text_area(attribute, options)
        when :boolean
          check_box(attribute, options)
        when :date
          date_field(attribute, options)
        when :datetime
          datetime_field(attribute, options)
        else
          text_field(attribute, options)
        end
      end

      def association(attribute, options = {}, html_options = {})
        case association_type(attribute)
        when :belongs_to
          select("#{attribute}_id", association_collection_for_select(attribute), options, html_options.deep_merge(
            data: { behavior: "select-box" }
          ))
        when :has_and_belongs_to_many, :has_many
          if many_to_many_association?(attribute)
            select("#{attribute.to_s.singularize}_ids", association_collection_for_select(attribute), { label: attribute.to_s.humanize }.merge(options), html_options.deep_merge(
              multiple: true,
              data: { behavior: "select-box" }
            ))
          else
            input(attribute, options)
          end
        else
          input(attribute, options)
        end
      end

      def date_field(attribute, options = {})
        text_field(attribute, options.deep_merge(
          value: datetime_value(attribute, options, :datepicker),
          data: { behavior: "datepicker" }
        ))
      end

      def datetime_field(attribute, options = {})
        text_field(attribute, options.deep_merge(
          value: datetime_value(attribute, options, :datetimepicker),
          data: { behavior: "datetimepicker" }
        ))
      end

      private

      def attribute_type(attribute)
        if @object.has_attribute?(attribute)
          @object.column_for_attribute(attribute).type
        end
      end

      def association_type(attribute)
        association_reflection(attribute).try(:macro)
      end

      def many_to_many_association?(attribute)
        reflection = association_reflection(attribute)
        return false unless reflection
        reflection.macro == :has_and_belongs_to_many ||
          (reflection.macro == :has_many && reflection.options[:through].present?)
      end

      def association_collection(attribute)
        association_reflection(attribute).try(:klass).try(:all)
      end

      def association_reflection(attribute)
        @object.class.reflect_on_association(attribute)
      end

      def association_collection_for_select(attribute)
        method_name = association_option_text(attribute)
        association_collection(attribute).map { |a| [a.public_send(method_name), a.id] }
      end

      def resource_service
        @template.instance_variable_get(:@resource_service)
      end

      def association_option_text(attribute)
        resource_service&.option_text_for_association(attribute) || :to_s
      end

      def datetime_value(attribute, options, format)
        value = options[:value] || @object.send(attribute)
        value.try(:strftime, @template.translate_scoped("datetimepickers.#{format}"))
      end
    end
  end
end
