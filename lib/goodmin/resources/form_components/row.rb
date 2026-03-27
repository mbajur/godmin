module Goodmin
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
      #
      # Components such as +section+ may also be used as children:
      #
      #   form do
      #     row do
      #       col(size: 6) do
      #         section(title: "Left") { attribute :title }
      #       end
      #       col(size: 6) do
      #         section(title: "Right") { attribute :body }
      #       end
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
