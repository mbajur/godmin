module Goodmin
  module Helpers
    module Filters
      def filter_form(url: params.to_unsafe_h)
        builder = FormBuilders::FilterFormBuilder.new("", nil, self, {})
        form_tag(url, method: :get, class: "form-inline") do
          yield(builder)
        end
      end
    end
  end

  module FormBuilders
    class FilterFormBuilder < ActionView::Helpers::FormBuilder
      def filter_field(name, options, html_options = {})
        case options[:as]
        when :string
          string_filter_field(name, options, html_options)
        when :select
          select_filter_field(name, options, html_options)
        when :multiselect
          multiselect_filter_field(name, options, html_options)
        end
      end

      def string_filter_field(name, _options, html_options = {})
        label_text = @template.translate_scoped("filters.labels.#{name}", default: name.to_s.titleize)
        @template.content_tag(:div, class: "form-group filter") do
          @template.concat(@template.label_tag(name, label_text, class: "control-label"))
          @template.concat(@template.text_field_tag(
            "filter[#{name}]",
            default_filter_value(name),
            { placeholder: label_text, class: "form-control", id: name }.merge(html_options)
          ))
        end
      end

      def select_filter_field(name, options, html_options = {})
        filter_select(
          name, options, {
            name: "filter[#{name}]",
            data: {
              placeholder: @template.translate_scoped("filters.select.placeholder.one")
            }
          }.deep_merge(html_options)
        )
      end

      def multiselect_filter_field(name, options, html_options = {})
        filter_select(
          name, {
            include_hidden: false
          }.deep_merge(options), {
            name: "filter[#{name}][]",
            multiple: true,
            data: {
              placeholder: @template.translate_scoped("filters.select.placeholder.many")
            }
          }.deep_merge(html_options)
        )
      end

      def apply_filters_button
        submit @template.translate_scoped("filters.buttons.apply"), class: "btn btn-primary"
      end

      def clear_filters_button
        @template.link_to(
          @template.translate_scoped("filters.buttons.clear"),
          @template.url_for(
            @template.params.to_unsafe_h.slice(:scope, :order)
          ),
          class: "btn btn-default"
        )
      end

      private

      def filter_select(name, options, html_options)
        unless options[:collection].is_a? Proc
          raise "A collection proc must be specified for select filters"
        end

        options = options.dup

        collection = options.delete(:collection).call
        options.delete(:include_hidden)

        label_text = @template.translate_scoped("filters.labels.#{name}", default: name.to_s.titleize)

        choices =
          if collection.is_a? ActiveRecord::Relation
            @template.options_from_collection_for_select(
              collection,
              options.delete(:option_value),
              options.delete(:option_text),
              selected: default_filter_value(name)
            )
          else
            @template.options_for_select(
              collection,
              selected: default_filter_value(name)
            )
          end

        blank_option = @template.content_tag(:option, "", value: "")

        @template.content_tag(:div, class: "form-group filter") do
          @template.concat(@template.label_tag(name, label_text, class: "control-label"))
          @template.concat(@template.select_tag(
            html_options[:name] || "filter[#{name}]",
            @template.safe_join([blank_option, choices]),
            { class: "form-control", id: name }.merge(html_options.except(:name))
          ))
        end
      end

      def default_filter_value(name)
        @template.params[:filter] ? @template.params[:filter][name] : nil
      end
    end
  end
end
