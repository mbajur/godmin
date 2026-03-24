module Godmin
  module Resources
    # Mixin for custom form DSL components that can be registered with
    # FormBuilder.register_component and used inside form blocks.
    #
    # To create a custom component, include this module and implement:
    #
    #   - #initialize(children, *args, **kwargs) — receives the list of child
    #     nodes (Array of AttributeNode / HtmlNode / ComponentNode) as the
    #     first argument, followed by any arguments passed in the DSL.
    #   - #render(view_context, f) — returns HTML-safe output for the component.
    #   - (optional) #attributes — returns an Array of Godmin::Resources::Attribute
    #     objects contributed by this component for strong-parameter filtering.
    #     Defaults to extracting attributes from any child nodes.
    #
    # Example:
    #
    #   class MyComponent
    #     include Godmin::Resources::FormComponent
    #
    #     def initialize(children, label:)
    #       super(children)
    #       @label = label
    #     end
    #
    #     def render(view_context, f)
    #       view_context.content_tag(:fieldset) do
    #         view_context.content_tag(:legend, @label) +
    #           view_context.render_form_nodes(children, f)
    #       end
    #     end
    #   end
    #
    #   # Register:
    #   Godmin::Resources::FormBuilder.register_component(:my_component, MyComponent)
    #
    #   # Use in a form block:
    #   form do
    #     my_component(label: "Details") do
    #       attribute :title
    #     end
    #   end
    module FormComponent
      def self.included(base)
        base.attr_reader :children
      end

      def initialize(children, *_args, **_kwargs)
        @children = children
      end

      # Override to return Attribute objects this component contributes.
      # By default, attributes are extracted recursively from child nodes.
      def attributes
        FormBuilder.extract_attributes(children)
      end
    end
  end
end
