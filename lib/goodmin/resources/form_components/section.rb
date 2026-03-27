module Goodmin
  module Resources
    module FormComponents
      # Renders a titled, described section wrapping its child form nodes.
      #
      # Accepts optional +title+ and +description+ keyword arguments which are
      # rendered above a +<div>+ that wraps the section's child nodes. The entire
      # output is wrapped in an outer +<div>+.
      #
      # Both +title+ and +description+ can be a static string or a +Proc+. When
      # a +Proc+ is provided it is called at render time with the form's object
      # (the resource record) as its sole argument, allowing dynamic content.
      #
      # Usage in a form block:
      #
      #   form do
      #     section(title: "Details", description: "Fill in the details below.") do
      #       attribute :title
      #       attribute :body
      #     end
      #
      #     section(description: ->(record) { "Editing #{record.name}" }) do
      #       attribute :title
      #     end
      #   end
      #
      # +section+ may also be nested inside +col+ and +row+:
      #
      #   form do
      #     row do
      #       col(size: 6) do
      #         section(title: "Left column") { attribute :title }
      #       end
      #       col(size: 6) do
      #         section(title: "Right column") { attribute :body }
      #       end
      #     end
      #   end
      class Section
        include FormComponent

        def initialize(children, title: nil, description: nil)
          super(children)
          @title = title
          @description = description
        end

        def render(view_context, f)
          record = f.object
          title = @title.is_a?(Proc) ? @title.call(record) : @title
          description = @description.is_a?(Proc) ? @description.call(record) : @description

          view_context.content_tag(:div) do
            parts = []
            parts << view_context.content_tag(:h4, title) if title.present?
            parts << view_context.content_tag(:p, description) if description.present?
            parts << view_context.content_tag(:div) { view_context.render_form_nodes(children, f) }
            view_context.safe_join(parts)
          end
        end
      end
    end
  end
end
