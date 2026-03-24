module Godmin
  module Helpers
    module Forms
      def form_for(record, options = {}, &block)
        super(record, {
          url: [*@resource_parents, record],
          builder: FormBuilders::FormBuilder
        }.merge(options), &block)
      end

      def render_form_nodes(nodes, f)
        safe_join(nodes.map { |node| render_form_node(node, f) })
      end

      private

      def render_form_node(node, f)
        case node
        when Resources::AttributeNode
          field = node.attribute.to_field(record: @resource, resource_service: @resource_service)
          render partial: field.class.partial_form, locals: { field: field, f: f }
        when Resources::HtmlNode
          content_tag(node.tag, node.html_attrs) do
            render_form_nodes(node.children, f)
          end
        when Resources::ComponentNode
          node.component.render(self, f)
        end
      end
    end
  end

  module FormBuilders
    class FormBuilder < ActionView::Helpers::FormBuilder
      def text_field(attribute, options = {})
        wrap_field(attribute) { super(attribute, with_form_control_class(options)) }
      end

      def text_area(attribute, options = {})
        wrap_field(attribute) { super(attribute, with_form_control_class(options)) }
      end

      def number_field(attribute, options = {})
        wrap_field(attribute) { super(attribute, with_form_control_class(options)) }
      end

      def password_field(attribute, options = {})
        wrap_field(attribute) { super(attribute, with_form_control_class(options)) }
      end

      def select(attribute, choices, options = {}, html_options = {})
        label_text = options.delete(:label)
        wrap_field(attribute, label_text: label_text) do
          super(attribute, choices, options, with_form_control_class(html_options))
        end
      end

      def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
        @template.content_tag(:div, class: "form-group") do
          @template.content_tag(:div, class: "form-check") do
            @template.concat(super(attribute, with_class(options, "form-check-input"), checked_value, unchecked_value))
            @template.concat(label(attribute, nil, class: "form-check-label"))
          end
        end
      end

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
          select("#{attribute}_id", association_collection_for_select(attribute), options, html_options)
        when :has_and_belongs_to_many, :has_many
          if many_to_many_association?(attribute)
            select("#{attribute.to_s.singularize}_ids", association_collection_for_select(attribute), { label: attribute.to_s.humanize }.merge(options), html_options.deep_merge(
              multiple: true
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

      def wrap_field(attribute, label_text: nil)
        @template.content_tag(:div, class: "form-group") do
          @template.concat(label(attribute, label_text))
          @template.concat(yield)
        end
      end

      def with_form_control_class(options)
        with_class(options, "form-control")
      end

      def with_class(options, *classes)
        existing = options[:class]
        new_class = [*classes, existing].compact.join(" ")
        options.merge(class: new_class)
      end

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
        klass = association_reflection(attribute).try(:klass)
        service = associated_service_for(klass)
        if service
          association_collection(attribute).map { |a| [service.display_name(a), a.id] }
        else
          method_name = association_option_text(attribute)
          association_collection(attribute).map { |a| [a.public_send(method_name), a.id] }
        end
      end

      def resource_service
        @template.instance_variable_get(:@resource_service)
      end

      def associated_service_for(klass)
        return nil unless klass

        service_class = Godmin::ServiceLocator.find_service_class_for(klass, context_service_class: resource_service&.class)
        service_class&.new
      rescue StandardError
        nil
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
