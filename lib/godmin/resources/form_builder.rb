require "godmin/resources/attribute"

module Godmin
  module Resources
    class FormBuilder
      HTML_TAGS = %w[
        div span p section fieldset article header footer main
        h1 h2 h3 h4 h5 h6 ul ol li dl dt dd
      ].freeze

      attr_reader :nodes

      def initialize
        @nodes = []
      end

      def attribute(name, field: nil)
        @nodes << AttributeNode.new(Attribute.new(name, field_class: field))
      end

      HTML_TAGS.each do |tag|
        define_method(tag) do |**html_attrs, &block|
          child_builder = FormBuilder.new
          child_builder.instance_eval(&block) if block
          @nodes << HtmlNode.new(tag, html_attrs, child_builder.nodes)
        end
      end

      def attributes
        extract_attributes(@nodes)
      end

      private

      def extract_attributes(nodes)
        nodes.flat_map do |node|
          case node
          when AttributeNode then [node.attribute]
          when HtmlNode then extract_attributes(node.children)
          end
        end
      end
    end

    class AttributeNode
      attr_reader :attribute

      def initialize(attribute)
        @attribute = attribute
      end
    end

    class HtmlNode
      attr_reader :tag, :html_attrs, :children

      def initialize(tag, html_attrs, children)
        @tag = tag
        @html_attrs = html_attrs
        @children = children
      end
    end
  end
end
