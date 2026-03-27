require "test_helper"

module Goodmin
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
        article do
          p { attribute :title }
          span { attribute :body }
        end
      end

      article_node = builder.nodes.first
      assert_kind_of Resources::HtmlNode, article_node
      assert_equal "article", article_node.tag
      assert_equal 2, article_node.children.length
      assert_equal "p", article_node.children.first.tag
      assert_equal "span", article_node.children.last.tag
    end

    def test_attribute_with_custom_field
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        attribute :body, field: Fields::Text
      end

      node = builder.nodes.first
      assert_kind_of Resources::AttributeNode, node
      assert_equal Fields::Text, node.attribute.field_class
    end

    def test_attribute_with_extra_options
      builder = Resources::FormBuilder.new
      val = ->(record) { record.foo }
      builder.instance_eval do
        attribute :body, field: Fields::Text, value: val, label: "Custom"
      end

      attr = builder.nodes.first.attribute
      assert_equal val, attr.options[:value]
      assert_equal "Custom", attr.options[:label]
    end

    def test_form_nodes_on_resource_service
      klass = Class.new do
        include Goodmin::Resources::ResourceService

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
        include Goodmin::Resources::ResourceService
      end

      assert_equal [], klass.form_nodes
    end

    # Component registration tests

    def test_register_component_adds_dsl_method
      component_klass = Class.new do
        include Goodmin::Resources::FormComponent

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
        include Goodmin::Resources::FormComponent

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
        include Goodmin::Resources::FormComponent
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
        include Goodmin::Resources::FormComponent
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
        include Goodmin::Resources::FormComponent

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

    # Row / Col built-in components

    def test_row_component_produces_component_node
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        row do
          attribute :title
        end
      end

      assert_equal 1, builder.nodes.length
      assert_kind_of Resources::ComponentNode, builder.nodes.first
      assert_kind_of Resources::FormComponents::Row, builder.nodes.first.component
    end

    def test_row_component_children_are_passed
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        row do
          attribute :title
          attribute :body
        end
      end

      component = builder.nodes.first.component
      assert_equal 2, component.children.length
      assert_equal :title, component.children.first.attribute.name
      assert_equal :body, component.children.last.attribute.name
    end

    def test_col_component_produces_component_node
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        col { attribute :title }
      end

      assert_equal 1, builder.nodes.length
      assert_kind_of Resources::ComponentNode, builder.nodes.first
      assert_kind_of Resources::FormComponents::Col, builder.nodes.first.component
    end

    def test_col_component_default_size
      builder = Resources::FormBuilder.new
      builder.instance_eval { col { attribute :title } }

      col = builder.nodes.first.component
      assert_equal 6, col.instance_variable_get(:@size)
    end

    def test_col_component_custom_size
      builder = Resources::FormBuilder.new
      builder.instance_eval { col(size: 6) { attribute :title } }

      col = builder.nodes.first.component
      assert_equal 6, col.instance_variable_get(:@size)
    end

    def test_row_col_attributes_are_extracted
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        row do
          col(size: 6) { attribute :title }
          col(size: 6) { attribute :body }
        end
        attribute :published
      end

      attrs = builder.attributes
      assert_equal [:title, :body, :published], attrs.map(&:name)
    end

    # Section built-in component

    def test_section_component_produces_component_node
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        section { attribute :title }
      end

      assert_equal 1, builder.nodes.length
      assert_kind_of Resources::ComponentNode, builder.nodes.first
      assert_kind_of Resources::FormComponents::Section, builder.nodes.first.component
    end

    def test_section_component_stores_title_and_description
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        section(title: "Details", description: "Fill in below.") { attribute :title }
      end

      component = builder.nodes.first.component
      assert_equal "Details", component.instance_variable_get(:@title)
      assert_equal "Fill in below.", component.instance_variable_get(:@description)
    end

    def test_section_component_title_and_description_default_to_nil
      builder = Resources::FormBuilder.new
      builder.instance_eval { section { attribute :title } }

      component = builder.nodes.first.component
      assert_nil component.instance_variable_get(:@title)
      assert_nil component.instance_variable_get(:@description)
    end

    def test_section_component_children_are_passed
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        section do
          attribute :title
          attribute :body
        end
      end

      component = builder.nodes.first.component
      assert_equal 2, component.children.length
      assert_equal :title, component.children.first.attribute.name
      assert_equal :body, component.children.last.attribute.name
    end

    def test_section_attributes_are_extracted
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        section(title: "Details") do
          attribute :title
          attribute :body
        end
        attribute :published
      end

      attrs = builder.attributes
      assert_equal [:title, :body, :published], attrs.map(&:name)
    end

    def test_section_component_description_can_be_a_proc
      builder = Resources::FormBuilder.new
      desc_proc = ->(record) { "Dynamic: #{record}" }
      builder.instance_eval do
        section(description: desc_proc) { attribute :title }
      end

      component = builder.nodes.first.component
      assert_equal desc_proc, component.instance_variable_get(:@description)
    end

    def test_section_component_title_can_be_a_proc
      builder = Resources::FormBuilder.new
      title_proc = ->(record) { "Dynamic: #{record}" }
      builder.instance_eval do
        section(title: title_proc) { attribute :title }
      end

      component = builder.nodes.first.component
      assert_equal title_proc, component.instance_variable_get(:@title)
    end

    def test_section_render_calls_proc_description_with_form_object
      record = Object.new
      desc_proc = ->(r) { "Editing #{r.object_id}" }

      builder = Resources::FormBuilder.new
      builder.instance_eval { section(description: desc_proc) { attribute :title } }
      component = builder.nodes.first.component

      view_context = build_section_view_context
      f = build_form_stub(record)

      output = component.render(view_context, f)
      assert_includes output, "Editing #{record.object_id}"
    end

    def test_section_render_calls_proc_title_with_form_object
      record = Object.new
      title_proc = ->(r) { "Title for #{r.object_id}" }

      builder = Resources::FormBuilder.new
      builder.instance_eval { section(title: title_proc) { attribute :title } }
      component = builder.nodes.first.component

      view_context = build_section_view_context
      f = build_form_stub(record)

      output = component.render(view_context, f)
      assert_includes output, "Title for #{record.object_id}"
    end

    # Tab built-in component

    def test_tab_component_produces_component_node
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        tab(title: "General") { attribute :title }
      end

      assert_equal 1, builder.nodes.length
      assert_kind_of Resources::ComponentNode, builder.nodes.first
      assert_kind_of Resources::FormComponents::Tab, builder.nodes.first.component
    end

    def test_tab_component_stores_title_and_derives_key
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        tab(title: "General settings") { attribute :title }
      end

      component = builder.nodes.first.component
      assert_equal "General settings", component.title
      assert_equal "general_settings", component.key
    end

    def test_tab_component_children_are_passed
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        tab(title: "General") do
          attribute :title
          attribute :body
        end
      end

      component = builder.nodes.first.component
      assert_equal 2, component.children.length
      assert_equal :title, component.children.first.attribute.name
      assert_equal :body, component.children.last.attribute.name
    end

    def test_tab_component_is_identified_as_tab
      component = Resources::FormComponents::Tab.new([], title: "Test")
      assert component.tab_component?
    end

    def test_tab_supports_nested_dsl_components
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        tab(title: "Config") do
          row do
            col(size: 6) { attribute :foo }
            col(size: 6) { attribute :bar }
          end
        end
      end

      component = builder.nodes.first.component
      assert_equal 1, component.children.length
      assert_kind_of Resources::ComponentNode, component.children.first
      assert_kind_of Resources::FormComponents::Row, component.children.first.component
    end

    def test_form_builder_tabs_returns_tab_components
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        tab(title: "General") { attribute :title }
        tab(title: "Config") { attribute :body }
        attribute :published
      end

      tabs = builder.tabs
      assert_equal 2, tabs.length
      assert tabs.all? { |t| t.is_a?(Resources::FormComponents::Tab) }
      assert_equal ["General", "Config"], tabs.map(&:title)
    end

    def test_form_builder_tabs_returns_empty_when_no_tabs
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        attribute :title
        attribute :body
      end

      assert_equal [], builder.tabs
    end

    def test_tab_attributes_are_included_in_attrs_for_form
      builder = Resources::FormBuilder.new
      builder.instance_eval do
        tab(title: "General") { attribute :title }
        tab(title: "Config") do
          row do
            col { attribute :body }
          end
        end
        attribute :published
      end

      attrs = builder.attributes
      assert_equal [:title, :body, :published], attrs.map(&:name)
    end

    def test_form_tabs_on_resource_service
      klass = Class.new do
        include Goodmin::Resources::ResourceService

        form do
          tab(title: "General") { attribute :title }
          tab(title: "Config") { attribute :body }
        end
      end

      tabs = klass.form_tabs
      assert_equal 2, tabs.length
      assert_equal "general", tabs.first.key
      assert_equal "config", tabs.last.key

      attrs = klass.attrs_for_form
      assert_equal [:title, :body], attrs.map(&:name)
    end

    def test_form_tabs_returns_empty_when_no_tabs_defined
      klass = Class.new do
        include Goodmin::Resources::ResourceService

        form do
          attribute :title
        end
      end

      assert_equal [], klass.form_tabs
    end

    private

    def build_section_view_context
      view_context = Object.new
      view_context.define_singleton_method(:content_tag) do |_tag, content = nil, &block|
        block ? block.call : content.to_s
      end
      view_context.define_singleton_method(:safe_join) { |parts| parts.join }
      view_context.define_singleton_method(:render_form_nodes) { |_children, _f| "" }
      view_context
    end

    def build_form_stub(record)
      f = Object.new
      f.define_singleton_method(:object) { record }
      f
    end
  end
end
