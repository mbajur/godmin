require "goodmin/resources/attribute"

module Goodmin
  module Resources
    class FormBuilder
      HTML_TAGS = %w[
        div span p fieldset article header footer main
        h1 h2 h3 h4 h5 h6 ul ol li dl dt dd
      ].freeze

      attr_reader :nodes

      def initialize
        @nodes = []
      end

      def attribute(name, field: nil, **options)
        @nodes << AttributeNode.new(Attribute.new(name, field_class: field, **options))
      end

      HTML_TAGS.each do |tag|
        define_method(tag) do |**html_attrs, &block|
          child_builder = FormBuilder.new
          result = child_builder.instance_eval(&block) if block
          child_builder.nodes << TextNode.new(result) if result.is_a?(String) && child_builder.nodes.empty?
          @nodes << HtmlNode.new(tag, html_attrs, child_builder.nodes)
        end
      end

      # Registers a custom DSL component so it can be used inside form blocks.
      #
      # @param name [Symbol] the method name available in the DSL
      # @param klass [Class] a class that includes Goodmin::Resources::FormComponent
      #
      # Example:
      #   Goodmin::Resources::FormBuilder.register_component(:my_component, MyComponent)
      def self.register_component(name, klass)
        define_method(name) do |*args, **kwargs, &block|
          child_builder = FormBuilder.new
          child_builder.instance_eval(&block) if block
          @nodes << ComponentNode.new(klass.new(child_builder.nodes, *args, **kwargs))
        end
      end

      # Extracts a flat list of Attribute objects from a node tree.
      # Used internally and by FormComponent#attributes.
      def self.extract_attributes(nodes)
        nodes.flat_map do |node|
          case node
          when AttributeNode then [node.attribute]
          when HtmlNode then extract_attributes(node.children)
          when ComponentNode then node.component.attributes
          when TextNode then []
          end
        end
      end

      # Extracts the list of Tab components from a top-level node array.
      def self.extract_tabs(nodes)
        nodes.select { |n| n.is_a?(ComponentNode) && n.component.tab_component? }.map(&:component)
      end

      def attributes
        self.class.extract_attributes(@nodes)
      end

      def tabs
        self.class.extract_tabs(@nodes)
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

    class TextNode
      attr_reader :text

      def initialize(text)
        @text = text
      end
    end

    class ComponentNode
      attr_reader :component

      def initialize(component)
        @component = component
      end
    end
  end
end
