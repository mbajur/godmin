module Godmin
  module Helpers
    module Forms
      def form_for(record, options = {}, &block)
        super(record, {
          url: [*@resource_parents, record]
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
end
