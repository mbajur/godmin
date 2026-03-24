module Godmin
  module Resources
    module FormComponents
      # Renders a titled, described section wrapping its child form nodes.
      #
      # Accepts optional +title+ and +description+ keyword arguments which are
      # rendered above a +<div>+ that wraps the section's child nodes.
      #
      # Usage in a form block:
      #
      #   form do
      #     section(title: "Details", description: "Fill in the details below.") do
      #       attribute :title
      #       attribute :body
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
          parts = []
          parts << view_context.content_tag(:h3, @title) if @title.present?
          parts << view_context.content_tag(:p, @description) if @description.present?
          parts << view_context.content_tag(:div) { view_context.render_form_nodes(children, f) }
          view_context.safe_join(parts)
        end
      end
    end
  end
end
