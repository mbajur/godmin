module Goodmin
  module Helpers
    module Navigation
      def navbar_item(resource, url = resource, show: nil, **options)
        show ||= lambda do
          resource.is_a?(String) ? true : policy(resource).index?
        end

        return unless show.call

        link_text =
          if block_given?
            capture do
              yield
            end
          else
            resource.respond_to?(:model_name) ? resource.model_name.human(count: :many) : resource
          end

        if @in_navbar_dropdown
          options[:class] = ["dropdown-item", options[:class]].compact.join(" ")
          content_tag :li do
            link_to link_text, url, options
          end
        else
          options[:class] = ["nav-link", options[:class]].compact.join(" ")
          content_tag :li, class: "nav-item" do
            link_to link_text, url, options
          end
        end
      end

      def navbar_dropdown(title)
        @in_navbar_dropdown = true
        inner = capture { yield }
        @in_navbar_dropdown = false

        dropdown_toggle = link_to title, "#", class: "nav-link dropdown-toggle", role: "button", data: { bs_toggle: "dropdown" }, aria: { expanded: "false" }
        dropdown_menu = content_tag :ul, inner, class: "dropdown-menu"

        content_tag :li, class: "nav-item dropdown" do
          concat dropdown_toggle
          concat dropdown_menu
        end
      end

      def navbar_divider
        content_tag :li do
          content_tag :hr, "", class: "dropdown-divider"
        end
      end
    end
  end
end
