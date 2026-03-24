require "test_helper"

module Godmin
  class FormBuilderTest < ActiveSupport::TestCase
    def test_attribute_node_for_flat_attribute
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        attribute :title
      end

      assert_equal 1, builder.nodes.length
      assert_kind_of Resources::AttributeNode, builder.nodes.first
      assert_equal :title, builder.nodes.first.attribute.name
    end

    def test_attributes_returns_flat_list
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        attribute :title
        attribute :body
      end

      attrs = builder.attributes
      assert_equal 2, attrs.length
      assert_equal [:title, :body], attrs.map(&:name)
      assert attrs.all? { |a| a.is_a?(Resources::Attribute) }
    end

    def test_html_node_wraps_children
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        div do
          attribute :title
        end
      end

      assert_equal 1, builder.nodes.length
      node = builder.nodes.first
      assert_kind_of Resources::HtmlNode, node
      assert_equal "div", node.tag
      assert_equal 1, node.children.length
      assert_kind_of Resources::AttributeNode, node.children.first
      assert_equal :title, node.children.first.attribute.name
    end

    def test_nested_html_nodes
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        div do
          div do
            attribute :foo
          end
        end
        attribute :bar
      end

      assert_equal 2, builder.nodes.length
      outer_div = builder.nodes.first
      assert_kind_of Resources::HtmlNode, outer_div
      assert_equal 1, outer_div.children.length

      inner_div = outer_div.children.first
      assert_kind_of Resources::HtmlNode, inner_div
      assert_equal "div", inner_div.tag
      assert_equal 1, inner_div.children.length
      assert_equal :foo, inner_div.children.first.attribute.name

      bar_node = builder.nodes.last
      assert_kind_of Resources::AttributeNode, bar_node
      assert_equal :bar, bar_node.attribute.name
    end

    def test_attributes_flattens_nested_nodes
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        div do
          div { attribute :foo }
        end
        attribute :bar
      end

      attrs = builder.attributes
      assert_equal 2, attrs.length
      assert_equal [:foo, :bar], attrs.map(&:name)
    end

    def test_html_node_with_html_attrs
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        div(class: "col-md-6") do
          attribute :title
        end
      end

      node = builder.nodes.first
      assert_kind_of Resources::HtmlNode, node
      assert_equal({ class: "col-md-6" }, node.html_attrs)
    end

    def test_span_and_other_tags
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        section do
          p { attribute :title }
          span { attribute :body }
        end
      end

      section_node = builder.nodes.first
      assert_kind_of Resources::HtmlNode, section_node
      assert_equal "section", section_node.tag
      assert_equal 2, section_node.children.length
      assert_equal "p", section_node.children.first.tag
      assert_equal "span", section_node.children.last.tag
    end

    def test_attribute_with_custom_field
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        attribute :body, field: Field::Text
      end

      node = builder.nodes.first
      assert_kind_of Resources::AttributeNode, node
      assert_equal Field::Text, node.attribute.field_class
    end

    def test_form_nodes_on_resource_service
      klass = Class.new do
        include Godmin::Resources::ResourceService

        form do
          div do
            attribute :title
          end
          attribute :body
        end
      end

      nodes = klass.form_nodes
      assert_equal 2, nodes.length
      assert_kind_of Resources::HtmlNode, nodes.first
      assert_kind_of Resources::AttributeNode, nodes.last

      attrs = klass.attrs_for_form
      assert_equal [:title, :body], attrs.map(&:name)
    end

    def test_form_nodes_fallback_when_no_form_block
      klass = Class.new do
        include Godmin::Resources::ResourceService
      end

      assert_equal [], klass.form_nodes
    end

    # Component registration tests

    def test_register_component_adds_dsl_method
      component_klass = Class.new do
        include Godmin::Resources::FormComponent

        def render(_view_context, _f)
          "<custom/>"
        end
      end

      builder_klass = Class.new(Resources::FormBuilder)
      builder_klass.register_component(:my_widget, component_klass)

      builder = builder_klass.new
      builder.instance_eval do
        my_widget
      end

      assert_equal 1, builder.nodes.length
      assert_kind_of Resources::ComponentNode, builder.nodes.first
      assert_kind_of component_klass, builder.nodes.first.component
    end

    def test_register_component_passes_args_to_constructor
      received = {}
      component_klass = Class.new do
        include Godmin::Resources::FormComponent

        define_method(:initialize) do |children, label:, **rest|
          super(children)
          received[:label] = label
        end

        def render(_view_context, _f) = ""
      end

      builder_klass = Class.new(Resources::FormBuilder)
      builder_klass.register_component(:my_widget, component_klass)

      builder = builder_klass.new
      builder.instance_eval { my_widget(label: "My Label") }

      assert_equal "My Label", received[:label]
    end

    def test_register_component_passes_child_nodes
      component_klass = Class.new do
        include Godmin::Resources::FormComponent
        def render(_view_context, _f) = ""
      end

      builder_klass = Class.new(Resources::FormBuilder)
      builder_klass.register_component(:my_widget, component_klass)

      builder = builder_klass.new
      builder.instance_eval do
        my_widget do
          attribute :title
          attribute :body
        end
      end

      component = builder.nodes.first.component
      assert_equal 2, component.children.length
      assert_kind_of Resources::AttributeNode, component.children.first
      assert_equal :title, component.children.first.attribute.name
    end

    def test_register_component_attributes_extracted_from_children
      component_klass = Class.new do
        include Godmin::Resources::FormComponent
        def render(_view_context, _f) = ""
      end

      builder_klass = Class.new(Resources::FormBuilder)
      builder_klass.register_component(:my_widget, component_klass)

      builder = builder_klass.new
      builder.instance_eval do
        my_widget do
          attribute :title
          attribute :body
        end
        attribute :published
      end

      attrs = builder.attributes
      assert_equal [:title, :body, :published], attrs.map(&:name)
    end

    def test_register_component_custom_attributes_method
      component_klass = Class.new do
        include Godmin::Resources::FormComponent

        def render(_view_context, _f) = ""

        def attributes
          []
        end
      end

      builder_klass = Class.new(Resources::FormBuilder)
      builder_klass.register_component(:my_widget, component_klass)

      builder = builder_klass.new
      builder.instance_eval do
        my_widget do
          attribute :title
        end
        attribute :body
      end

      # Custom attributes method returns [] so :title is excluded
      attrs = builder.attributes
      assert_equal [:body], attrs.map(&:name)
    end

    def test_extract_attributes_class_method
      nodes = [
        Resources::AttributeNode.new(Resources::Attribute.new(:title)),
        Resources::HtmlNode.new("div", {}, [
          Resources::AttributeNode.new(Resources::Attribute.new(:body))
        ])
      ]

      attrs = Resources::FormBuilder.extract_attributes(nodes)
      assert_equal [:title, :body], attrs.map(&:name)
    end
  end
end
