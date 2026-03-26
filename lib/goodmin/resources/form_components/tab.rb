module Goodmin
  module Resources
    module FormComponents
      # Renders a form tab panel containing its child form nodes.
      #
      # Each tab has a +title+ and a derived +key+ (parameterized from the title)
      # used as the URL query parameter value to identify the active tab.
      #
      # When the resource form has tabs defined, only one tab's content is
      # rendered at a time based on the +?tab=<key>+ query parameter. A sidebar
      # with links to each tab is displayed alongside the form.
      #
      # Usage in a form block:
      #
      #   form do
      #     tab title: "General settings" do
      #       attribute :name
      #     end
      #
      #     tab title: "Config" do
      #       row do
      #         col { attribute :foo }
      #       end
      #     end
      #   end
      class Tab
        include FormComponent

        attr_reader :title, :key

        def initialize(children, title:)
          raise ArgumentError, "Tab requires a :title" if title.blank?

          super(children)
          @title = title
          @key = title.parameterize(separator: "_")
        end

        def render(view_context, f)
          view_context.render_form_nodes(children, f)
        end

        def tab_component?
          true
        end
      end
    end
  end
end
