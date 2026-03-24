module Godmin
  module Resources
    module FormComponents
      # Renders a Bootstrap grid row wrapping its child form nodes.
      #
      # Usage in a form block:
      #
      #   form do
      #     row do
      #       col { attribute :title }
      #       col { attribute :body }
      #     end
      #   end
      class Row
        include FormComponent

        def render(view_context, f)
          view_context.content_tag(:div, class: "row") do
            view_context.render_form_nodes(children, f)
          end
        end
      end
    end
  end
end
