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

        options[:class] = ["nav-link", options[:class]].compact.join(" ")

        content_tag :li, class: "nav-item" do
          link_to link_text, url, options
        end
      end

      def navbar_dropdown(title)
        dropdown_toggle = link_to "#", class: "nav-link dropdown-toggle", data: { bs_toggle: "dropdown" }, aria: { expanded: "false" } do
          concat title
        end

        dropdown_menu = content_tag :ul, class: "dropdown-menu" do
          yield
        end

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
