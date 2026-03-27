module Goodmin
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

      def render_form_nodes_for(nodes, f, record:, resource_service:)
        old_resource = @resource
        old_resource_service = @resource_service
        @resource = record
        @resource_service = resource_service
        render_form_nodes(nodes, f)
      ensure
        @resource = old_resource
        @resource_service = old_resource_service
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
        when Resources::TextNode
          node.text
        end
      end
    end
  end
end
