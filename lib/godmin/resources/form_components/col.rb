module Godmin
  module Resources
    module FormComponents
      # Renders a Bootstrap grid column wrapping its child form nodes.
      #
      # Accepts an optional +size+ keyword argument (default: 12) which maps to
      # the Bootstrap col-md-* class.
      #
      # Usage in a form block:
      #
      #   form do
      #     row do
      #       col(size: 6) { attribute :title }
      #       col(size: 6) { attribute :body }
      #     end
      #   end
      class Col
        include FormComponent

        def initialize(children, size: 12)
          super(children)
          @size = size
        end

        def render(view_context, f)
          view_context.content_tag(:div, class: "col-md-#{@size}") do
            view_context.render_form_nodes(children, f)
          end
        end
      end
    end
  end
end
