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
  end
end
